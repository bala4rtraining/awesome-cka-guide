#!/usr/bin/env bash

#===============================================================================================
#date : 09/09/2019
#title : start.sh
#description : This script retrieves the repositories needed for godoc by initiating a series 
# of git clone commands
#author		 : priyshar, gabaguil
#usage		 : start.sh
#===============================================================================================
# Note: the bitbucket service user key is stored in bitbucket_api.conf file which is mounted to 
# the docker container. This credential is then accessed by this script using the source call
# found below
source /opt/app/conf/bitbucket_api.conf 
if [ -z "$BITBUCKET_API_KEY" ]; then
    echo '***   BITBUCKET_API_KEY does not exist   ***'
    echo '***   Please verify that credential file was mounted successfully   ***'
    echo '***   Script failed with exit code 1   ***'
    exit 1
fi

set -x
go version
go env
export GOROOT=/go && cd /go/src/visa.com/ && \
    eval $(ssh-agent -s) && chmod 400 /ssh_key &&  ssh-add /ssh_key && \
    ls -lrt && ./pull.sh "$BITBUCKET_API_KEY" clone 
echo "Cloned all the repos in the container"


