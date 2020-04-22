# OVN Golden Laptop Automation (Phase I)


## Overview

This is a Phase I implementation of OVN Golden Laptop (OGL) in sprint 21.
This implementation uses Ansible scripts to set up a Cento7-based OGL and then
runs the OGL to set up routing and switching on Cumulus switches in a 2spine-3leaf topology.
The scripts are verified using a realistic testbed built with Virtualbox VMs. The Phase II implementation
will add capabilities to boot strap and configure OVN HP servers.


The main purpose of OGL is to bootstrap and configure the OVN internal infrastructure including
Cumulus switches and HP servers. 

_**Please note that a few packages, e.g., tftp and httpd, are not being used in this phase. 
They have been installed as placeholders to prepare for the next phase. Reviewers may choose
to ignore them for the time being.**_


## Ansible Playbook Workflow

_**Please note that the following workflow may change in the future should requirements change**_

The workflow can be divided several steps:

* Step 1: Prepare a new Centos7 server as the target OGL machine. The playbook will need to know its MAC address on the interface that connects to the OGL
* Step 2: Run the Ansible script in OVN git repo (ovn\_infrastructure/ansible\_golden_laptop) to set up the OGL
* Step 3: Prepare Cumulus switches for the 2spine-3leaf topology
* Step 4: Run Ansible script on the OGL to set up a 2spine-3leaf Cumulus switch topology

Preparation of the OGL machine and Cumulus switches are out of the scope of this document. 

## File Structure

There two types of Ansible files: one type of files that are used to setup the OGL and
the other type of files that are copied to the OGL by the first type and runs on the OGL to setup the Cumulus switches. They are organized as the following:

* ovn\_infrastructure/ansible\_golden_laptop
 * ansible.cfg
 * site.yml (main playbook file)
 * provision.yml (included by site.yml. It installs list of basic packages, e.g. DHCP/TFTP/HTTPD, on the OGL)
 * OGL_host ( OGL machine IP and port )
 * group_vars (global variables for the OGL used by more than one roles)

* ovn\_infrastructure/ansible\_golden_laptop/roles
 * dhcpd ( role that handles DHCP server installation on OGL )
 * httpd ( role that handles HTTP server installation on OGL to be used in next phase )
 * tftp (  role that handles TFTP server installation on OGL to be used in next phase )
 * goldenlaptop ( role that handles a few more OGL specific configurations)
 > * files/cumulus  ( contains Ansible scripts to be copied to the OGL for running against Cumulus switches)
 > * group_vars ( global vars to be used by more than one roles in the Ansible scripts running on OGL targeting Cumulus switches, they define the 2spine-3leaf topology )
 > * roles/leafs ( role to handle leaf switch configuration )
 > * roles/spines (role to handle spine switch configuration )



## TODOs

The followings are items that need to be improved in future sprints

  * **Cumulus Installation**

  Right now it's not possible to simulate using a VM the installation of a Cumulus switch.
  Cumulus Network will release in the near future a new VM template for this purpose
  
  * **OVN Repo**
  
  Right now 3rd party packages, e.g, DHCP server, Ansible etc, are installed on the OGL by direct
  access to the Centos repo hosted on the Internet. In the future, they will be installed
  from an OVN Repo.
  
  Right now PXElinux files are stored in git repo. They also need to be downloaded from the OVN Repo 
  server in the future.

  * Firewall configurations
  
  * SELinux configuration

  * NTP Install and Configuration


  
  



