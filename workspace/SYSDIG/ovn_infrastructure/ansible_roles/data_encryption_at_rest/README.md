data_encryption_at_rest Description
==================

data_encryption_at_rest role:
1. Create data encryption keys
2. Encrypts it on file system.

Pre-requisites to test locally:
-------------------------------

1. Virtualbox
2. Vagrant

Steps(test locally):
---------------------

Run
```
   vagrant up
   vagrant provision test-hostmachine
```
This will run the playbook on the virtual machine


Run playbook:
--------------
1. For higher environments, CERT and PROD, set "createDEK" in copy_encrypted_dek.yml to true.
2. For other environments, set "createDEK" in copy_encrypted_dek.yml to false.
3. 1. and 2. determine if DEK is created locally or pulled from repository.

```
ansible-playbook -i <inventory-file> copy_encrypted_dek.yml
```

Appendix:
---------
Architecture/Implementation details: https://visawiki.trusted.visa.com/display/OVN/Encryption+and+KMS

Vagrantfile

```
# -*- mode: ruby -*-
# vi: set ft=ruby :

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.
Vagrant.configure(2) do |config|
  # The most common configuration options are documented and commented below.
  # For a complete reference, please see the online documentation at
  # https://docs.vagrantup.com.

  # Every Vagrant development environment requires a box. You can search for
  # boxes at https://atlas.hashicorp.com/search.
  config.vm.box = "centos/7"

  # Proxy settings
  config.proxy.http     = "http://userproxy.visa.com:80"
  config.proxy.https    = "http://userproxy.visa.com:443"
  config.proxy.no_proxy = "localhost,127.0.0.1,127.0.1.1,127.0.1.1*,local.home"
  
  config.vm.define "test-hostmachine" do |machine|
    machine.vm.hostname="test-hostmachine"
   # machine.vm.synced_folder "./","/vagrant_ansible"
    machine.vm.network :private_network, ip: "192.168.10.14"

    machine.vm.provision "shell", path:"load_guest_additions.sh"

    machine.vm.provision :ansible do |ansible|
      ansible.playbook = "../../ansible_ovn/copy_encrypted_dek.yml"
      ansible.limit="all"
      ansible.verbose= true
      ansible.inventory_path="test/hosts"
    end
    
  end
end

```

load_guest_additions.sh

```
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
```

test/hosts file

```
[nomad_client]
192.168.10.14
```

## HSM playbook notes

Name: install_safenet_protectapp_jce.yml

Description:

This playbook will install SafeNet ProtectApp JCE libraries
and install client certs in Java Keystore.

This playbook can be called by dispatching from the main task
in the future. 

The unit tests have been done on the 3 nomad nodes in the dev env:
sl73ovnapd162,sl73ovnapd163, sl73ovnapd164
