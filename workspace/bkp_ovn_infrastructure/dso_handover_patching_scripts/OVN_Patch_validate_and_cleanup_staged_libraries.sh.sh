#
# Purpose:  This script is usefull to take backup of staging packings and validate and cleanup the staged packages in indonesia servers through jenkins.
#           it will use the credentails stored in jenkins keystore to connect to remote servers.
#           it will use ovncd user
#
# Requires: Configure the jenkins job with below parameters.
#           Multi-line String Parameter         : HOST
#           Boolean Parameter           : BACKUP
#           Boolean Parameter           : VALIDATE
#           Boolean Parameter           : REMOVE
#           Source Code Management : None
#
#

#!/bin/bash
set +x
echo validating and cleaning staged Libraries
echo
echo Host on which deployment needs to be done
echo "========================================"
echo $HOST
echo
echo "Backup for Packages"
echo "========================================"
echo $BACKUP
echo
echo "Validate for Packages"
echo "========================================"
echo $VALIDATE
echo
echo "Remove for Packages"
echo "========================================"
echo $REMOVE

# This is used to validate the staged packages in servers.
if $BACKUP
then
for host in $HOST
do
  echo Backup started $host
  echo "=================================================================================================="
  ssh -i "${ovncd_ssh_key}" -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no ovncd@$host "bash -s" <<- 'EOF'
	 LOG_DIRECTORY=/tmp
     LOGFILE_NAME=$LOG_DIRECTORY/validate_staged_libraries_$(date +%Y-%m-%d_%H_%M).log
     STAGING_DIRECTORY="/opt/app/data/staging_packages"
     STAGING_DIRECTORY_BACKUP="/opt/app/data/staging_packages_backup"
     sudo touch /tmp/fileslist.txt
     sudo chmod 646 /tmp/fileslist.txt
     sudo ls -ltr $STAGING_DIRECTORY/ | awk '{print $9}' > /tmp/fileslist.txt
     sudo sed -i '/^$/d' /tmp/fileslist.txt
	   echo " Backup started for $STAGING_DIRECTORY directory " | tee -a $LOGFILE_NAME
     echo "=============================================================" | tee -a $LOGFILE_NAME
     echo | tee -a $LOGFILE_NAME
      		  sudo mkdir -p "$STAGING_DIRECTORY_BACKUP"
            for file in `cat /tmp/fileslist.txt`; do sudo cp -rf ${STAGING_DIRECTORY}/$file ${STAGING_DIRECTORY_BACKUP}/; done
     echo | tee -a $LOGFILE_NAME
     echo " Backup done for $STAGING_DIRECTORY directory " | tee -a $LOGFILE_NAME
     echo "==========================================================" | tee -a $LOGFILE_NAME
     echo | tee -a $LOGFILE_NAME            
EOF
done
fi


if $VALIDATE
then
for host in $HOST
do
  echo Validations started $host
  echo "=================================================================================================="
  ssh -i "${ovncd_ssh_key}" -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no ovncd@$host "bash -s" <<- 'EOF'
	 LOG_DIRECTORY=/tmp
     LOGFILE_NAME=$LOG_DIRECTORY/validate_staged_libraries_$(date +%Y-%m-%d_%H_%M).log
     STAGING_DIRECTORY="/opt/app/data/staging_packages"
     STAGING_DIRECTORY_BACKUP="/opt/app/data/staging_packages_backup"
     echo | tee -a $LOGFILE_NAME
     echo " List of packgaes available in $STAGING_DIRECTORY directory " | tee -a $LOGFILE_NAME
     echo "========================================================================" | tee -a $LOGFILE_NAME
     sudo ls -ltr $STAGING_DIRECTORY | tee -a $LOGFILE_NAME
     echo
     echo " List of packgaes available in $STAGING_DIRECTORY_BACKUP directory " | tee -a $LOGFILE_NAME
     echo "===============================================================================" | tee -a $LOGFILE_NAME
     sudo ls -lrt $STAGING_DIRECTORY_BACKUP | tee -a $LOGFILE_NAME      
EOF
done
fi

# This is used to empty the staging directory and remove more than 30 days Packages from backup directory in servers.
if $REMOVE
then
for host in $HOST
do
  echo Removing started $host
  echo "=================================================================================================="
  ssh -i "${ovncd_ssh_key}" -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no ovncd@$host "bash -s" <<- 'EOF'
	 LOG_DIRECTORY=/tmp
     LOGFILE_NAME=$LOG_DIRECTORY/validate_staged_libraries_$(date +%Y-%m-%d_%H_%M).log
     STAGING_DIRECTORY="/opt/app/data/staging_packages"
     STAGING_DIRECTORY_BACKUP="/opt/app/data/staging_packages_backup" 
     echo | tee -a $LOGFILE_NAME
     echo " Removing the more than 60 days packgaes available in $STAGING_DIRECTORY_BACKUP directory " | tee -a $LOGFILE_NAME
     echo "=====================================================================================================" | tee -a $LOGFILE_NAME
     sudo find $STAGING_DIRECTORY_BACKUP/ -type f -name "*.rpm" -mtime +60 -exec rm -f {} \;
     echo
     echo " List of packgaes available in $STAGING_DIRECTORY_BACKUP directory " | tee -a $LOGFILE_NAME
     echo "============================================================================================" | tee -a $LOGFILE_NAME
     sudo ls -ltr $STAGING_DIRECTORY_BACKUP | tee -a $LOGFILE_NAME
     echo | tee -a $LOGFILE_NAME
     echo
     echo " Removing all the packgaes available in $STAGING_DIRECTORY directory " | tee -a $LOGFILE_NAME
     echo "=============================================================================================" | tee -a $LOGFILE_NAME
     #for file in `cat /tmp/fileslist.txt`; do sudo rm -rf ${STAGING_DIRECTORY}/$file; done
     sudo rm -rf $STAGING_DIRECTORY/
     sudo mkdir -p "$STAGING_DIRECTORY"
     echo
     echo | tee -a $LOGFILE_NAME
     echo | tee -a $LOGFILE_NAME
     echo " List of packgaes available in $STAGING_DIRECTORY directory " | tee -a $LOGFILE_NAME
     echo "=============================================================================================" | tee -a $LOGFILE_NAME
     sudo ls -ltr $STAGING_DIRECTORY | tee -a $LOGFILE_NAME     
EOF
done
fi
