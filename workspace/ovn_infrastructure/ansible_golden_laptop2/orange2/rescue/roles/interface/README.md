Role Name
=========

interface

Requirements
------------

This role sets up the 3 interfaces on the rescue server

* 1G to eth0 on OOB SW (for OOB SW install and config)
* 1G to swp1 on OOB SW (for OOB Server and other switches install and config, not for server as OOB Server connects to iLO)
* 10G to a border switch (for server install and config)


Role Variables
--------------
ovn_common_<site>.yml
