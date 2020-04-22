# HAproxy nodes network configuration

## Purpose

This playbook plays a simple role to set up networking
for HAproxy nodes in OVN cluster. It will run
from the OVN Goldenlaptop.

In the redundancy design with two HAproxy servers,
each HAproxy node has a single interface 
connected to one of the border leaf switches. They needs to be
within the same VLAN after they
are installed with Centos 7.1 OS by the Goldenlaptop.

The HAproxy and keepalived packages can then be run
from Jenkins to set up the redundant HAproxy instances
at a later time.





