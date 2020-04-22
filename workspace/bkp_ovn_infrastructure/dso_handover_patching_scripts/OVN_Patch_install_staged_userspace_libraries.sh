#
# Purpose:  This script is usefull to update userspace libraries from staged directory in indonesia servers through jenkins.
#           it will use the credentails stored in jenkins keystore to connect to remote servers.
#           it will use the ovncd user for deployment
#
# Requires: Configure the jenkins job with below parameters.
#           Multi-line String Parameter		: HOST
#           Multi-line String Parameter		: PACKAGES
#           Boolean Parameter		: VALIDATE
#           Boolean Parameter		: UPDATE
#           Source Code Management : None
#
# Use the below shell script in Bulid section for patching activities.

#!/bin/bash
set -x
echo Patching userspace Libraries
echo
echo Host on which deployment needs to be done
echo "========================================"
echo $HOST
echo
echo Packages to be installed
echo "========================================"
echo $PACKAGES
echo
echo Validation for Packages
echo "========================================"
echo $VALIDATE
echo
echo Update the Packages
echo "========================================"
echo $UPDATE
echo

# This is Prevalidation to check what are the packages that are installed
if $VALIDATE
then
for host in $HOST
do
  echo Pre_Validating packages in $host
  echo "=================================================================================================="
  #Do the ssh once to the server and check the installed rpm's and pre-validation steps
  ssh -i "${ovncd_ssh_key}" -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no ovncd@$host "sudo bash -s \"$PACKAGES\"" <<- 'EOF'
     LOG_DIRECTORY=/tmp
     LOGFILE_NAME=$LOG_DIRECTORY/userspace_libraries_pre_validate_$(date +%Y-%m-%d_%H_%M).log
     echo | tee -a $LOGFILE_NAME
     echo " Server Reboot status(UPTIME) " | tee -a $LOGFILE_NAME
     echo "==================================================================" | tee -a $LOGFILE_NAME
     uptime | awk '{print $3,$4}' | tee -a $LOGFILE_NAME
     echo | tee -a $LOGFILE_NAME
     echo " CURRENT Redhat userspace Version " | tee -a $LOGFILE_NAME
     echo "==================================================================" | tee -a $LOGFILE_NAME
     uname -sr | tee -a $LOGFILE_NAME
     echo | tee -a $LOGFILE_NAME
     echo " File system size " | tee -a $LOGFILE_NAME
     echo "==================================================================" | tee -a $LOGFILE_NAME
     df -Th | tee -a $LOGFILE_NAME
     echo | tee -a $LOGFILE_NAME      
     for i in $1
      do
      	  #Fetch just the name of the rpm and not the version if the name is glibc-2.17-222.el7
          #rpmName will be glibc-
          rpmName="$(echo $i | egrep -o '^([a-zA-Z]*-?){10,}')"
          echo Pre_Validating $i package | tee -a $LOGFILE_NAME
          echo Pre_Installed Version of $rpmName | tee -a $LOGFILE_NAME
          echo "==============================================================" | tee -a $LOGFILE_NAME
          rpm -qa | grep $rpmName | tee -a $LOGFILE_NAME
          echo | tee -a $LOGFILE_NAME
      done
EOF
done
fi

# if the update is checked, update the packages from locally.

if $UPDATE
then
for host in $HOST
do
  echo Updating packages in $host
  echo "=================================================================================================="
  #Do the ssh once to the server and update the rpm's
  ssh -i "${ovncd_ssh_key}" -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no ovncd@$host "sudo bash -s \"$PACKAGES\"" <<- 'EOF'
      LOG_DIRECTORY=/tmp
      LOGFILE_NAME=$LOG_DIRECTORY/userspace_libraries_update_$(date +%Y-%m-%d_%H_%M).log
      STAGING_DIRECTORY=/opt/app/data/staging_packages
      mkdir $STAGING_DIRECTORY
          echo Updating $package package | tee -a $LOGFILE_NAME
          echo "==============================================================" | tee -a $LOGFILE_NAME
          yum -y localupdate $STAGING_DIRECTORY/*.rpm | tee -a $LOGFILE_NAME
          echo | tee -a $LOGFILE_NAME
EOF
done

for host in $HOST
do
  echo Post_Validating packages in $host
  echo "=================================================================================================="
  #Do the ssh once to the server and check the installed rpm's
  ssh -i "${ovncd_ssh_key}" -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no ovncd@$host "sudo bash -s \"$PACKAGES\"" <<- 'EOF'
      LOG_DIRECTORY=/tmp
      LOGFILE_NAME=$LOG_DIRECTORY/userspace_libraries_post_validate_$(date +%Y-%m-%d_%H_%M).log
      for package in $1
      do
          echo Post_Validating $package package | tee -a $LOGFILE_NAME
          echo "==============================================================" | tee -a $LOGFILE_NAME
          rpm -qa | grep $package | tee -a $LOGFILE_NAME
          echo | tee -a $LOGFILE_NAME
      done
EOF
done
fi

