#!/bin/bash
# File: jenkinsloader.sh
# Purpose:
#     This script fetches jobs from artifactory and puts them in the current CD appliance.
# To run script:
#     ./jenkinsjobloader.sh -j $jobname
# Requirements:
#     Prerequisite of the script is jq being installed on the machine.
# Options:
#     -j: Copy a single job name, This should be followed by a job name.
#     -a: Copy all jobs from artifactory.

all_jobs=0
one_job=0
display_all=0

artifactory_url='https://artifactory.trusted.visa.com'

while getopts "j:a" name
do
  case $name in
    j)
      job_to_create="$OPTARG"
      one_job=1
      ;;
    a)
      all_jobs=1
      ;;
    \?)
      echo "Valid cases include"
      echo "./jenkinsjobloader.sh -j name_of_job (To deploy a single job)"
      echo "./jenkinsjobloader.sh -a (To deploy all jobs)"
      exit 1
      ;;
  esac
done

shift $(($OPTIND -1))

branch=$1
environment_name=$2
echo $environment_name
if [ "$environment_name" == "cert" ]; then
  artifactory_url='https://10.184.254.25:8088'
elif [ "$environment_name" == "indonesia" ]; then
  artifactory_url='https://10.184.254.27:8080'
elif [ $environment_name == "cambodia" ]; then
  artifactory_url='https://10.184.254.27:8080'
fi

echo "artifactory_url="$artifactory_url
if [[ $one_job -eq 1 ]]; then
  if [[ -d temp ]]; then
    rm -rf temp
  fi
  mkdir temp
  curr_dir=$(pwd)
  cd temp
  mkdir script
  curl -o temp.json -XGET $artifactory_url/api/storage/ovn-app-el7/
  jq .children[].uri temp.json | sed 's/^"\///g' | sed 's/"$//g' > ovn-app-el7.txt
  tarball="$(grep 'jenkinsCDjobs-'$branch'-build' ovn-app-el7.txt | sort -V | tail -1)"
  echo $tarball
  curl -O https://artifactory.trusted.visa.com:443/ovn-app-el7/"{$tarball}" script/
  tar -xvf *.gz -C script/ >/dev/null
  cd script
  if [[ -d $job_to_create ]]; then
    cp -a "./"$job_to_create /var/lib/jenkins/jobs
    cd $curr_dir
    rm -rf temp
    echo "Loaded the job - $job_to_create successfully."
  else
    echo "No such job named $job_to_create exists."
    echo "The existing jobs are"
    ls
    cd $curr_dir
    rm -rf temp
    exit 1
  fi

elif [[ $all_jobs -eq 1 ]]; then
  if [[ -d temp ]]; then
    rm -rf temp
  fi
  mkdir temp
  curr_dir=$(pwd)
  cd temp
  mkdir script
  curl -o temp.json -XGET $artifactory_url/api/storage/ovn-app-el7/ >/dev/null
  jq .children[].uri temp.json | sed 's/^"\///g' | sed 's/"$//g' > ovn-app-el7.txt
  tarball="$(grep 'jenkinsCDjobs-master-build' ovn-app-el7.txt | sort -V | tail -1)"
  curl -O https://artifactory.trusted.visa.com:443/ovn-app-el7/"{$tarball}" script/
  tar -xvf *.gz -C script/
  cd script
  (cp -a . /var/lib/jenkins/jobs/)
  cd $curr_dir
  rm -rf temp
else
  exit 1
fi
