#!/usr/bin/env bash

# File: stop_docker_after_x_hours.sh
# Purpose:
#     There are some containers reside on our Jenkins slave machine who doesn't automatically stop after the job is done.
#     Since our cleaning stage job only check on those stopped containers, we want the admins to have the power to stop these
#       "stubborn" containers by given a predefined TTL during the CI process.
# To run script:
#     ./stop_docker_after_x_hours.sh 6
#     If any container(s) is up and running more than 6 hours, stop it(them)
# Arguments:
#     hour: stop docker containers live longer than the input hour
#
# Script maintainer: NAOVNDEVOPS@visa.com
#

HOUR=$1
DOCKER_STATUS_FILE="docker_ps.txt"
STOP_COMMAND="docker stop"

stop_docker_after_x_hours() {
    while read -r line; do
        arr=($line)
        WARNING_MSG="${arr[0]} will be stop since it is up and running for ${arr[1]} ${arr[2]}, longer than our defined TTL, which is $HOUR hours."

        if [[ ${arr[2]} == "weeks" ]] && [[ $((${arr[1]} * 7 * 24)) -gt $HOUR ]]; then
            echo $WARNING_MSG
            $STOP_COMMAND ${arr[0]}
        elif [[ ${arr[2]} == "days" ]] && [[ $((${arr[1]} * 24)) -gt $HOUR ]]; then
            echo $WARNING_MSG
            $STOP_COMMAND ${arr[0]}
        elif [[ ${arr[2]} == "hours" && ${arr[1]} -gt $HOUR ]]; then
            echo $WARNING_MSG
            $STOP_COMMAND ${arr[0]}
        fi   
    done < $DOCKER_STATUS_FILE
}

main() {
    if [ -z "$HOUR" ]; then
        echo '***   This script will need one parameter   ***'
        echo '***   Example: sh jenkins-sh/stop_docker_after_x_hours.sh 6   ***'
        echo '***   Job failed with exit code 1   ***'
        exit 1
    fi

    docker ps | egrep 'weeks ago|days ago|hours ago' | awk '{print $1 " " $8 " " $9}' > $DOCKER_STATUS_FILE
    echo "--- Current docker status ---"
    docker ps

    stop_docker_after_x_hours $HOUR
    
    echo "--- After stop old containers ---"
    docker ps
    rm $DOCKER_STATUS_FILE
}

main
