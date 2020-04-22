Profile
=====

This role includes tasks to deploy or remove a version of the compiled erlang profile modules to the specified environment. The profile will be updated on servers in the mediator, switch, and ftps_server group.
After the profile has been deployed or removed from a particular host, the erlang application will detect the addition or removal of the new profile and automatically use the latest, activated version. As a result, a restart of the consuming erlang application is not required.
The deploy / remove playbooks are typically only called manually in lower environments when a specific version is needed for testing. Profile build / deployment is managed by an automated process that will deploy daily when updated data is received from the source (DB2).

Requirements
-----

When calling the deploy_profile playbook, you must pass the profile_tarball variable. The profile will be deployed from Artifactory, so the profile_tarball must match a version available there. (https://artifactory.trusted.visa.com/webapp/#/artifacts/browse/tree/General/ovn/profile) The profile_tarball version is generated based on the environment name, date, and build number from the profile_build job.
When calling the remove_profile playbook, a profile_version variable must be specified. This should match the activation timestamp which is used as the directory where the profile is stored. To see a list of all versions deployed, run the following command on a switch, mediator or ef_sync server.

```
[root@sl73ovnapd122 ~]# ls -l /opt/profile/
drwxr-xr-x  3 root root 4096 Jul 26 10:41 201807261039
drwxr-xr-x  3 root root 4096 Aug 31 05:24 201808310523
drwxr-xr-x  3 root root 4096 Sep  4 23:20 201809042319
drwxr-xr-x  3 root root 4096 Sep  5 18:50 201809051849
drwxr-xr-x  3 root root 4096 Sep  6 23:45 201809062344


```
Dispatch Table
-----
[deploy] | [remove]

Role Variables
-----

| var                         |  default   | desc
|-----------------------------|------------|--------------------------------------------------------------------------------------------|
| profile_tarball             |  N / A     | Used for deployment. Version as stored in Artifactory.                                     |
| profile_version             | N / A      | Used for removal. Should match the directory name that represents the activation timestamp.|


Example Playbook
--------------

```yaml

Deploy
ansible_ovn/deploy_profile.yml -i ovn_infrastructure/inventories/test/dc1 --extra-vars profile_tarball=test_profile_20180906_206.tar

Remove
ansible-playbook ansible_ovn/remove_profile.yml -i inventories/test/dc1 --extra-vars profile_version=201804130138

```

Dependencies
-----
None

Licence
----
None

Author
----
* Zack Petersen  <zpeterse@visa.com>