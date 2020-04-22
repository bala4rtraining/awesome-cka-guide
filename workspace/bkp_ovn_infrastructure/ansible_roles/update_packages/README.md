Update userspace libraries Description
========================================

update_packages role updates packages for existing servers.  List of packages
were provided by DSE team for remediating qualys findings.  This playbook also disables
secure boot on servers whcih can be later patched for kernel libraries.

Assumptions
-----------

1. While implementing this playbook, there was no route to artifactory.trusted.visa.com.
Created a reverse proxy from host to connect to artifactory.
2. This step is not required if connectivity to artifactory already exists.

Run playbook:
--------------

```
ansible-playbook -i <inventory-file> update_packates.yml -u root --private-key=<key file>
```
For test inventory, use inventory-file=../ansible_roles/tests/test_reset_env


Tweeks:
-------

eno49 interface does not come up on reboot of server.  This would require to start interface on
every reboot.  Temporary changes made to file rc.local to bring up the interface.

TBD:
----

1. Check why reboot does not bring up interface.  This is because init.d network scripts are not being monitored by
systemctl.
2. Faster updates to packages:
   - Host a repository in Data Center which pulls updates from Visa DC regularly
   - Any patching should happen through this server that is set as local yum repo


Appendix:
---------

If reverse proxy was run to connect to artifactory, run remove_damage.yml file at the end of this
playbook run.

```
ansible-playbook -i <inventory-file> remove_damage.yml -u root --private-key=<key file>
```
Please note that, this playbook does not update Cumulus switches.

For patching test/cert/prod inventories, update packages in patch_libraries_test, patch_libraries_cert, and patch_libraries_prod respectively