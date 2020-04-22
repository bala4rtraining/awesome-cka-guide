Nomad
=====

This role deploys Nomad server(s) and client(s) on a node in the OVN environment. 

Nomad server app 'nomad' and its configuration files will get installed in folder "/opt / nomad_x.x.x / server / ".
Role can start Nomad servers in HA mode based on the inventory label group hosts.

Nomad client app 'nomad' and its configuration files will get installed in folder "/opt / nomad_x.x.x/ client / ". Role can start Nomad clients in HA mode based on the inventory label group hosts.

Both client and server applications are configured to  run as service and the description files are written to "/etc/systemd/system/". Use systemctl command to control the running service or to start the service.

Role has below dispatch routines and are

* nomad_ servers 
* nomad_ clearing _clients 
* nomad_ vss_ clients

The main deploy (deploy_ nomad) invoke will sequence each of the above mentioned
dispatch routines. The current order of invoking is, nomad_ servers; nomad_ clearing_ clients and 
nomad_ vss_ clients. The order is not a mandate.

Requirements
------------
Tarball is expected to be available through artifactory.


Role Variables
--------------

|       Variable name         	|                    Description                  | default value |
|:-----------------------------:|:------------------------------------------------:|----------------|
| nomad_version                	| The nomad version to install.|0.6.0|
| nomad_tarball                 | Nomad tarball name | nomad_{{nomad_version}}_linux_amd64.zip |
| nomad_ artifact_ url         	| The standard URL to pull the required artifact | https://artifactory.trusted.visa.com/ovn/repo/|
| settlement_ compute_ code    	| Is a custom variable used by vss. Used to set custom meta section. | true|

Dependencies
------------
None.


Example Playbook
----------------
	- name: start nomad servers
  	  hosts: nomad_server
      gather_facts: yes
     roles:
       - { role: nomad, dispatch: ['nomad_servers'] }
	- name: start clearing/deploy nomad clients
      hosts: nomad_client
      gather_facts: yes
      roles:
        - { role: nomad, dispatch: ['nomad_clearing_clients'] }
    - name: start vss nomad clients
      hosts: ovn_vss_servers 
      gather_facts: yes
      roles:
        - { role: nomad, dispatch: ['nomad_vss_clients'] }

License
-------
N/A


Author Information
------------------
Michael Quinlan (miquinla@visa.com)

References
-----------
* [Nomad overview](https://www.nomadproject.io/)

