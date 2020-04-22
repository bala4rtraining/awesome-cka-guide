Update kernel libraries Description
========================================

kernel_updates role updates kernel libraries to v514.  List of packages
were provided by DSE team for remediating qualys findings.

Assumptions
-----------

1. While implementing this playbook, there was no route to artifactory.trusted.visa.com.
Created a reverse proxy from host to connect to artifactory.
2. This step is not required if connectivity to artifactory already exists.

Run playbook:
--------------

```
ansible-playbook -i <inventory-file> kernel_updates.yml -u root --private-key=<key file>
```
For test inventory, use inventory-file=../ansible_roles/tests/test_reset_env
Please note that, this playbook does not update Cumulus switches.

For patching test/cert/prod inventories, update packages in kernel_libraries_test, kernel_libraries_cert, and kernel_libraries_prod respectively