#!/bin/bash

Changes='Step 1.
/etc/audit/rules.d/docker.rules (Append)
 -w /var/lib/docker -k docker -p rwxa                OVN-8889
 -w /etc/docker -k docker -p rwxa                    OVN-8890
 -w /usr/bin/docker-containerd -k docker -p rwxa     OVN-8892
 -w /usr/bin/docker-runc -k docker -p rwxa           OVN-8893

Step 2.
 chmod 644 /usr/lib/systemd/system/docker.service    OVN-8891

Step 3.
 Add --disable-legacy-registry to OPTIONS variable in /etc/sysconfig/docker
 Or add disable-legacy-registry : true to /etc/docker/daemon.json in valid JSON format    OVN-8895

Step 4.
 chmod 444 /etc/docker/certs.d//                     OVN-8896'

echo "=================================================================="

LOG_DIRECTORY=/tmp
LOGFILE_NAME=$LOG_DIRECTORY/docker_tsr_$(date +%Y-%m-%d_%H_%M).log

echo | tee -a $LOGFILE_NAME
echo Patching Docker TSR findings | tee -a $LOGFILE_NAME
echo "==================================================================" | tee -a $LOGFILE_NAME
echo Changes that need to be done
echo "$Changes" | tee -a $LOGFILE_NAME
echo | tee -a $LOGFILE_NAME
echo "==================================================================" | tee -a $LOGFILE_NAME
echo "Taking Backup of /etc/docker/daemon.json and /etc/audit/rules.d/docker.rules file - if they exist - in /tmp/backup_tsr/" | tee -a $LOGFILE_NAME
echo | tee -a $LOGFILE_NAME
mkdir /tmp/backup_tsr/
file1='/etc/audit/rules.d/docker.rules'
s1=0
ls $file1
if [ $? -eq 0 ]; then
 cp $file1 /tmp/backup_tsr/
 echo "Copied $file1 file into /tmp/backup_tsr/" | tee -a $LOGFILE_NAME
else
 echo "$file1 file dosn't exist" | tee -a $LOGFILE_NAME
 s1=1
fi

file2='/etc/docker/daemon.json'
s2=0
ls $file2
if [ $? -eq 0 ]; then
 cp $file2 /tmp/backup_tsr/
 echo "Copied $file2 file into /tmp/backup_tsr/" | tee -a $LOGFILE_NAME
else
 echo "$file2 file dosn't exist" | tee -a $LOGFILE_NAME
 s2=1
fi

echo | tee -a $LOGFILE_NAME
echo "==================================================================" | tee -a $LOGFILE_NAME
echo "EXecuting Step1."  | tee -a $LOGFILE_NAME

if [ $s1 -eq 0 ]; then
 echo "Before Changes $file1 contents are"  | tee -a $LOGFILE_NAME
 ls -ltr $file1 | tee -a $LOGFILE_NAME
 cat $file1 | tee -a $LOGFILE_NAME
else
 echo "$file1 file dosn't exist"  | tee -a $LOGFILE_NAME
fi

echo '-w /var/lib/docker -k docker -p rwxa' >> $file1
echo '-w /etc/docker -k docker -p rwxa' >> $file1
echo '-w /usr/bin/docker-containerd -k docker -p rwxa' >> $file1
echo '-w /usr/bin/docker-runc -k docker -p rwxa' >> $file1

if [ $s1 -eq 1 ]; then
 chmod 600 $file1
fi

echo "After Changes $file1 contents are"  | tee -a $LOGFILE_NAME
ls -ltr $file1 | tee -a $LOGFILE_NAME
cat $file1 | tee -a $LOGFILE_NAME

echo | tee -a $LOGFILE_NAME
echo "==================================================================" | tee -a $LOGFILE_NAME
echo "EXecuting Step2."  | tee -a $LOGFILE_NAME

echo "Before Changes - permissions are : "  | tee -a $LOGFILE_NAME
ls -ltr /usr/lib/systemd/system/docker.service | tee -a $LOGFILE_NAME

chmod 644 /usr/lib/systemd/system/docker.service

echo "After Changes - permissions are :"   | tee -a $LOGFILE_NAME
ls -ltr /usr/lib/systemd/system/docker.service | tee -a $LOGFILE_NAME

echo | tee -a $LOGFILE_NAME

echo "==================================================================" | tee -a $LOGFILE_NAME
echo "EXecuting Step3."  | tee -a $LOGFILE_NAME

if [ $s2 -eq 0 ]; then
 echo "Before Changes $file2 contents are " | tee -a $LOGFILE_NAME
 ls -ltr $file2 | tee -a $LOGFILE_NAME
 cat $file2 | tee -a $LOGFILE_NAME
else
 echo " $file2 file dosn't exist " | tee -a $LOGFILE_NAME
fi

if [ $s2 -eq 0 ]; then
 sed -i '$s/.$/,"disable-legacy-registry": true }/' $file2
else
 echo '{ "disable-legacy-registry": true }' >> $file2
 chmod 600 $file2
fi

echo "After Changes $file2 contents are"  | tee -a $LOGFILE_NAME
ls -ltr $file2 | tee -a $LOGFILE_NAME
cat $file2 | tee -a $LOGFILE_NAME

echo | tee -a $LOGFILE_NAME
echo "==================================================================" | tee -a $LOGFILE_NAME
echo "EXecuting Step4. "  | tee -a $LOGFILE_NAME

echo "Before Changes - permissions are :  " | tee -a $LOGFILE_NAME
ls -ltr /etc/docker/cert* | tee -a $LOGFILE_NAME

chmod 444 -R /etc/docker/cert*

echo "After Changes - permissions are :  " | tee -a $LOGFILE_NAME
ls -ltr /etc/docker/cert* | tee -a $LOGFILE_NAME

echo | tee -a $LOGFILE_NAME

echo "==================================================================" | tee -a $LOGFILE_NAME
echo "================================ D O N E =========================" | tee -a $LOGFILE_NAME
