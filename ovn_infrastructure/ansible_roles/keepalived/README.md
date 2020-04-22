Role Name
=========

Name: keepalived

The purpose is to use keepalived (e.g. VRRP) to achieve HAproxy failover.

This is critical role for OVN infrastructure as the HAproxy is the gateway into OVN operations.
The basic theory of operation is like this: Two HAproxy instances are running on two separate servers,
both are in the same VLAN on the two OVN border leaf switches. There are no preferences among these two HAproxy
instances. Anyone can be the primary. A virtual IP address in the same VLAN is bounded to the primary HAproxy and
should be exposed to any external entity that needs to connect to OVN applications such as mediators. In case the
primary fails (e.g, process crash, OS crash, server crash etc), the VIP is shifted and bounded to
the secondary transparent the the external entity.

Please note that existing TCP connection will expreience a very brief pause during the failover.

Caveat: This has yet to be tested on real hardware platform but only in simulation. 


Requirements
------------

This role assumes the following:

* Centos7.1 OS
* HAproxy installed
* Keepalived and HAproxy run on the same servers for primary and secondary in the same VLAN


Role Variables
--------------

Use default vars in the default/main.yml. Use the inventory file to specify the following two vars.
For example,

[haproxy]
10.13.200.18
10.13.200.19

[haproxy:vars]
haproxy_interface=xxx
haproxy_virtual_ip=10.13.200.20

Note: haproxy_interface is environment dependent, therefore for VM, interface will be of type eth* and for hardware it will be eno**
      Add haproxy_interface for all environments in ovn_vars


Dependencies
------------

The role itself doesn't depend on HAproxy. Today it's primarily used for HAproxy failover but
can be extended to monitor others if necessary.

Example Playbook
----------------

#
# Test keepalived
#
- name: Setup keepalived
  hosts: haproxy
  roles: 
    - keepalived


Author Information
------------------
weili@visa.com
