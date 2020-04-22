#!/usr/bin/bash

#===============================================================================
#
#          FILE: prom_test_data_generator.sh
#
#
#          JIRA:  OVN-5914
#         NOTES:  To be run only in lower environments to create test data
#        AUTHOR:  rupekuma@visa.com
#       VERSION:  1.0.0
#       CREATED: 18 Jan 2018
#      REVISION:  ---
#===============================================================================

declare -i  g_OPTIONS_LENGTH=$#
declare     g_OPTIONS=$*

function usage () {
        echo      "usage: $0 options"
        echo      "OPTIONS:"
        echo      "   -m        Metric name"
        echo      "   -t        Mmetric type (counter/gauge)"
        echo      "   -i        Initial value of metric"
        echo      "   -d        Time duration (in sec)"
        echo      "   -p        statsd listening port (optional)"
        echo      "   -r        ramp up value (if counter, by default 1) / maximum value (if gauge)"
}

function parseOptions () {

    local __option=$1

    while getopts :m:t:i:d:p:r: __option
    do
        case $__option in
            m) metricName="$OPTARG" ;;
            t) metricType="$OPTARG" ;;
            i) min="$OPTARG" ;;
            d) duration="$OPTARG" ;;
            p) portNumber="$OPTARG" ;;
            r) ramp="$OPTARG" ;;
        --) shift; break ;;

        \:) usage; exit ;;
        \?) echo "Unrecognized option -$OPTARG"; exit ;;
        esac
    done

    verifyOptions
}


function verifyOptions () {
    # check if no options passed
        [[ ( $g_OPTIONS_LENGTH -eq 0 ) ]] \
                && echo "options cannot be empty" \
                && usage \
                && exit 1

        [[ ( -z "$metricName" ) ]]  \
                && echo "must specify Metric Name" \
                && exit 1

        [[ ( -z "$metricType" ) ]]  \
                && echo "must specify metric type" \
                && exit 1

        [[ ( -z "$min" ) ]]  \
                && echo "must specify initial value" \
                && exit 1

        [[ ( -z "$duration" ) ]]  \
                && echo "must specify duration" \
                && exit 1

        [[ ( -z "$portNumber" ) ]]  \
                && portNumber=9125

      if [ -z $ramp ]
      then
       if [  "$metricType" == "gauge" ]
       then
        echo "Please specify max value"
        exit 1
       elif [ "$metricType" == "counter" ]
       then
        ramp=1
       fi
      fi


}


function main()
{
  if [ "$metricType" == "gauge" ]
    then
      SECONDS=0
      while (( $SECONDS < $duration ))
      do
        number=$(shuf -i ${min}-${ramp} -n 1)
        echo "${metricName}:${number}|g"|nc -w 1 -u 127.0.0.1 ${portNumber}
      done
    elif [ "$metricType" == "counter" ]
    then
      SECONDS=0
      number=$((${min} + ${ramp}))
      echo "${metricName}:${number}|c"|nc -w 1 -u 127.0.0.1 ${portNumber}
      while (( $SECONDS < $duration ))
      do
       echo $ramp
        echo "${metricName}:${ramp}|c"|nc -w 1 -u 127.0.0.1 ${portNumber}
        sleep 10
      done
     else
      echo "Wrong option"

  fi
}


parseOptions $g_OPTIONS
main
