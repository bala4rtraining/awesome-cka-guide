#
# Purpose:  This script is usefull to stage the kernel libraries in indonesia servers through jenkins.
#           it will use the credentails stored in jenkins keystore to connect to remote servers.
#           it will use the ovncd user for deployment
#
# Requires: Configure the jenkins job with below parameters.
#           Multi-line String Parameter		: HOST
#           Multi-line String Parameter		: PACKAGES
#           Boolean Parameter		: STAGE
#           Source Code Management : None
#
# Use the below shell script in Bulid section for patching activities.



#!/bin/bash
set -x
echo Patching kernel Libraries
echo
echo Host on which deployment needs to be done
echo "========================================"
echo $HOST
echo
echo Packages to be installed
echo "========================================"
echo $PACKAGES
echo
echo Staging the pacakges locally
echo "========================================"
echo $STAGE
echo

# if the STAGE is checked, download the packages locally

if $STAGE
then
for host in $HOST
do
  echo Updating packages in $host
  echo "=================================================================================================="
  #Do the ssh once to the server and update the rpm's
  ssh -i "${ovncd_ssh_key}" -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no ovncd@$host "sudo bash -s \"$PACKAGES\"" <<- 'EOF'
      LOG_DIRECTORY=/tmp
      LOGFILE_NAME=$LOG_DIRECTORY/kernel_libraries_update_$(date +%Y-%m-%d_%H_%M).log
      STAGING_DIRECTORY=/opt/app/data/staging_packages
      mkdir $STAGING_DIRECTORY
      for package in $1
      do
          echo Staging $package package | tee -a $LOGFILE_NAME
          echo "==============================================================" | tee -a $LOGFILE_NAME
          yum update --downloadonly --downloaddir=$STAGING_DIRECTORY $package | tee -a $LOGFILE_NAME
          echo | tee -a $LOGFILE_NAME
      done
EOF
done
fi

