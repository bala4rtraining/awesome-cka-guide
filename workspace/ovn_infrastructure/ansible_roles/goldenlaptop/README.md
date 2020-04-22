# Role Description

This role further handles OVN Golden Laptop (OGL) specific
configuration items. This includes

* Install Ansible and related packages needed by the OGL to run Ansible scripts on the OGL
* Configure the OGL interface used by DHCP server
* Configure /etc/hosts file used by Ansible scripts
* Copy OGL Ansible scripts to the OGL
* Install Cumulus auto-provisioning script on the OGL
* Install OGL's SSH pub key onto the proper directoy in OGL for Cumulus switch to retrieve it when the auto-provisioning script is run on the switch

For an overview of OGL go to [OGL](../../ansible_golden_laptop/README.md)


