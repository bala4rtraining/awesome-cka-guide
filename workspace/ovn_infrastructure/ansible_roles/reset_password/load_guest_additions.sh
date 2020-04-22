##                                                                                                                                                      
## Filename   : load_guest_additions.sh                                                                                                                 
## Description: Load VirtualBox Guest Additions onto CentOS VM.  This will be used for vagrant box                                                      
## Summary    : Downloads pre-requisites required to install VirtualBox Guest Additions.                                                                
##              Install current kernel version specific devel and header packages                                                                       
## Assumption : VirtualBox 5.0_24 version is installed                                                                                                  
## Usecase    : VirtuaBox Guest additions is required to mount host filesystem onto guest                                                               
##                                                                                                                                                      

#!/bin/bash                                                                                                                                             

KERN_VER=`uname -r`
yum install -y gcc kernel-devel-$KERN_VER kernel-headers-$KERN_VER dkms make bzip2 perl

KERN_DIR=/usr/src/kernels/$KERN_VER
export KERN_DIR

curl -O http://download.virtualbox.org/virtualbox/5.0.24/VBoxGuestAdditions_5.0.24.iso
sudo mkdir /media/VBoxGuestAdditions
sudo mount -o loop,ro VBoxGuestAdditions_5.0.24.iso /media/VBoxGuestAdditions
sudo sh /media/VBoxGuestAdditions/VBoxLinuxAdditions.run
rm VBoxGuestAdditions_5.0.24.iso
sudo umount /media/VBoxGuestAdditions
sudo rmdir /media/VBoxGuestAdditions
