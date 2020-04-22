#!/bin/bash

#
# This is a Q&D shellscript that will create a new cacerts file from the JRE cacerts file
# and it will append the CACerts from the VISA internal certificates that are provided.
#

new_cacerts_file=cacerts.new
centos_cacerts_file=/usr/java/jdk1.8.0_152/jre/lib/security/cacerts
myosx_cacerts_file=/Library/Java/JavaVirtualMachines/jdk1.8.0_161.jdk/Contents/Home/jre/lib/security/cacerts
base_cacerts_file=$centos_cacerts_file
# If you don't know where the cacerts file is then use: find / -name cacerts 2>/dev/null | grep 'jre/lib/security'

# this is an alternative when you want to use the ones checked into our repo
#visacacerts_dir=ovn_infrastructure/ansible_automation/roles/tools/files
# this is the default for a CENTOS system
visacacerts_dir=/etc/pki/ca-trust/source/anchors

java_keystore_file_password=changeit

generate_cer() {
   local infile=$1
   local filename=$(basename $1)
   local tempfile=$filename.cer
   local crtalias="${filename%.*}"
   openssl x509 -outform der -in $infile -out $tempfile
   keytool -importcert -noprompt -trustcacerts -keystore $new_cacerts_file -storepass $java_keystore_file_password -alias $crtalias -file $tempfile
   rm $tempfile
}

cp $base_cacerts_file $new_cacerts_file
for filename in $visacacerts_dir/*.crt; do
   generate_cer $filename
done

echo "== Summary NEW =="
keytool -list -keystore $new_cacerts_file -storepass $java_keystore_file_password | head
echo "== Summary OLD =="
keytool -list -keystore $base_cacerts_file -storepass $java_keystore_file_password | head
echo "================="
echo "File created: $new_cacerts_file"
echo "From file: $base_cacerts_file"