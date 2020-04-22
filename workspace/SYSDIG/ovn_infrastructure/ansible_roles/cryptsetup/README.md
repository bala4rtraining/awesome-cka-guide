# Overview
This role installs and configures dmcrypt based file system encryption on nodes in the OVN environment.

# Pre-requisites
An uninitialized logical disk partition generated through BIOS/UEFI menus.

# Ansible Role Variables

* **ovngit\_ref\_centos**: OVNGIT repo branch name
* **cryptsetuprpms**: cryptsetup rpms to be installed for OVNGIT repo branch
* **storagedevname**: Name of uninitialized storage device exposed to OS 
* **storagepartitionnum**: Partition number to allocate to overlay logical volume and filesystem to uninitialized storage device
* **cryptvgname**: Name of dmcrypt Volume Group Number that is created on top of storage device partition
* **cryptlvname**: Name of dmcrypt Logical Volume that is create on top of Volume Group 
* **cryptstoragesize**: Size of storage allocated to dmcrypt Logical Volume (and ultimately file system). Default is 4GBytes
* **cryptsectorsize**: Size of sectors (1 sector = 512 Bytes) allocated to dmcrypt Logical Volume. Default is 5GBytes = 10485760 sectors
* **cryptfstype**: Type of Filesystem created for dmcrypt Logical Volume 
* **cryptmntdir**: Mount directory for dmcrypt Logical Volume (and ultimately filesystem) 

# Example Playbook
    hosts: cryptsetup_nodes
      become: true
      become_method: sudo
      roles:
        - cryptsetup 
      vars:
        storagedevname: "/dev/sdb"
        storagepartitionnum: 3
        cryptstoragesize: "40GB"
        cryptsectorsize: 1048576000
        cryptmntdir: "/opt/app/lib"

**NOTE**: Vagrantfile provided in role to run in local dev environment (client laptop)

# Author Information
OVNDEV (ovndev@visa.com)
