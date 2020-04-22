OVN Chaos Testing
=========

This role installs and starts OVN Chaos Testing daemons on nodes in the OVN environment.


Requirements
------------
The Erlang distribution for the Chaos Testing daemon must be created and archived.


Role Variables
--------------
'name' is used to specify a part of the Erlang node name for the Erlang daemon and the user it runs under.
'source' is the filesystem location of the Erlang release tarball. 


Dependencies
------------
Java runtime.  (will be installed if it isn't present)


Example Playbook
----------------

    hosts: ovn_vm
      become: true
      roles:
        - chaos
      vars:
        name: fdaemon
        source: "files/fdaemon.tar.gz"
        coordinator_ip: "127.0.0.1"
        default_iface: "{{ ansible_default_ipv4.alias }}"

License
-------

N/A



Author Information
------------------

Nathan Aschbacher (naschbac@visa.com)
Anton Panasenko (apanasen@visa.com)
Michael Quinlan (miquinla@visa.com)