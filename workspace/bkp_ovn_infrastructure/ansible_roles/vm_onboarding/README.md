vm_onboarding Description
========================================

vm_onboarding role installs the RPMs on top of the standard Visa Centos7 SOE. If we need to update/modify the RPMs, vm_onboarding/files/packages file has to be modified.Current SOE version level is CentOS Linux release 7.4.1708 .


Assumptions
-----------
hostnames need to be added to the inventory & hostnames are passed as a extra vars while executing the playbook.

Packages list path
-----------------------
vm_onboarding/files/packages


Run playbook:
--------------

```
ansible-playbook ansible_ovn/deploy_vmonboarding.yml -i ansible_middleware/inventories/mware/dc1/hosts -u root --private-key=<key file> --extra-vars '{ target_hosts: "sl73ovnapd278.visa.com" }'
```
