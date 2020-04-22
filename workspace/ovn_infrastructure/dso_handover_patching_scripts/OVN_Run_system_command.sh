#
# Purpose:  This script is usefull to run the commands in indonesia servers through jenkins.
#           it will use the credentails stored in jenkins keystore to connect to remote servers.
#
# Requires: Configure the jenkins job with below parameters.
#           Multi-line String Parameter		: HOST
#           String Parameter	: COMMAND
#           Source Code Management : None
#
# Note: This Script can be use only for read-only system commands while doing patching activities.
#       Ex: uname, rpm -qa, uptime, etc..

#!/bin/bash

echo Run_system_command
echo
echo List of hosts to execute the command
echo "========================================"
echo $HOST
echo
echo Command to be executed on hosts
echo "========================================"
echo $COMMAND
echo


for host in $HOST
do
  echo Executing the command "'$COMMAND'" in $host
  echo "=================================================================================================="
  ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -q root@$host "${COMMAND}"
  echo
done