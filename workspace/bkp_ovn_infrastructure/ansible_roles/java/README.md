Java & Openjdk - Installation and upgradation
=========

This role has to dispatch Openjdk or OracleJre update

  # oraclejre upgrade
           
  This path will remove earlier oraclejre version and install new oralcejre version.
  It takes these variables jre_name,jre_version,OracleJre_older_version and OracleJre_latest_version_number.
  For earlier version you want to remove.It should be the name represented in the yum repository.
  jre_name new version you want to add, make sure the name is added properly.
  jre_version should be the name of the java version like "jre1.8.0_152".
  OracleJre_older_version should be the name of existing java version like "jre1.0.0_31"
  OracleJre_latest_version_number is created for checking with existing version installed in the machine and its should be only number like "1.8.0_152".

  # Openjdk upgrade

  This path will remove earlier oraclejre version and install new oralcejre version.
  It takes these variables OpenJdk_older_version,OpenJdk_latest_version and OpenJdk_latest_version_number
  Rpm name should the name represented in the yum repository.
  OpenJdk_latest_version should be the name of the openjdk version like "java-1.9.0-openjdk".
  OpenJdk_older_version should be the name of existing openjdk version like "java-1.8.0-openjdk"
  OpenJdk_latest_version_number is created for checking with existing version installed in the machine and its should be only number like "1.8.0_161".

Dependencies
------------
Java runtime.  (jre1.8.0_152  will be installed)
java-1.8.0-openjdk.
 
Notes
-----
Please make sure to set hosts in the playbook when invoking the role. Please refer the example given below.

Example Playbook
----------------

```yaml
#for oraclejre update
    - hosts: servers
      roles:
       - {role: java, dispatch: ['oraclejre-update']}

#for openjdk update
    - hosts: servers
      roles:
       - {role: java, dispatch: ['openjdk-update']}

#for openjdk to oraclejre upgrade
    - hosts: servers
      roles:
       - {role: java, dispatch: ['openjdk-to-oraclejre-update']}

#for validate java type
    - hosts: servers
      roles:
       - {role: java, dispatch: ['validate-java-type']}


```

License
-------

N/A

