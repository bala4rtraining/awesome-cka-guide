elasticsearch
=========

This role has two dispatch paths , jreupgrade and deployelastic.

  # jreupgrade
           
  This path will remove old jre version and install new jre version.
  It will also do a rolling restart of the elastic search node while doing it.
  It takes two variables elasticsearch_jre_oldversion and elasticsearch_jre_version.
  elasticsearch_jre_oldversion version you want to remove.This should be the name represented in the yum repository.
  elasticsearch_jre_version new version you want to add, make sure the name is added properly.
  for example if you want to add oracle java 1.8.0_131 it should be "jre1.8.0_131".
  if you want to add open jdk 1.8 it should be "java-1.8.0-openjdk".
  # deployelastic
  
  This will install or upgrade elastic search. As a part of installation it also tries to install jre if not present.
  The variable elasticsearch_jre_version will be used to determine the JRE to be installed.
  It can also do a upgrade of elastic search from one version to another. Please provide the appropriate 
  values for the variables elasticsearch_oldversion and elasticsearch_rpms . The version specified by
  elasticsearch_rpms will be installed .

Requirements
------------

The RPM(s) + dependencies are in OVNGIT; when updating the latest RPM, update the name in the defaults/main.yml.


Role Variables
--------------
| var                             |  default   | desc
|---------------------------------|------------|--------------------------------------------------------------------------------|
| eserv_type                      |  default   | set = lbonly in inventory when used for loadbalance                            |
| elasticsearch_heapsize          |  4g        | should be set depending on available resources, e.g. https://www.elastic.co/guide/en/elasticsearch/reference/current/heap-size.html |                |
| elasticsearch_jre_oldversion    |  java-1.8.0-openjdk	| the old  version of jre on the machine that has to be removed. This is applicable for jre upgrade task.
| elasticsearch_jre_version       |  jre1.8.0_131 | the version of jre on the machine  that has to be installed.  This is for jre upgrade and deploy elastic task. 
| elasticsearch_port              |  9200      | Port on which elastic search  listens.
| elasticsearch_oldversion        |  5.0.0     | The versoin of elasticsearch which has to be removed .
| rolling_upgrade                 |  false     | If the variable is set to true , the playbook will do a rolling upgrade of elastic search



Dependencies
------------
Java runtime.  (jre1.8.0_131  will be installed if it isn't present by default for the path deployelastic)
 
Notes
-----
Please make sure to set "serial: 1" in the playbook when invoking the role with variable rolling_upgrade set as true.Please refer the example given below.

Example Playbook
----------------

```yaml
#for deploying elastic
    - hosts: servers
      roles:
       - {role: elasticsearch, dispatch: ['deployelastic']}

#for upgrading elastic search from version 5.0.0 to 5.5.1
    - hosts: servers
      roles:
       - {role: elasticsearch, dispatch: ['deployelastic']}
      vars:
       elasticsearch_oldversion: 5.0.0
       elasticsearch_rpms:
        - elasticsearch-5.5.1

#for rolling upgrading elastic search from version 5.0.0 to 5.5.1
    - hosts: servers
      serial: 1
      roles:
       - {role: elasticsearch, dispatch: ['deployelastic']}
      vars:
       rolling_upgrade: True
       elasticsearch_oldversion: 5.0.0
       elasticsearch_rpms:
        - elasticsearch-5.5.1


#for upgrading jre and rolling restart of the elastic search

    - hosts: servers
      serial: 1
      roles:
       - {role: elasticsearch, dispatch: ['jreupgrade']}
      vars:
       elasticsearch_jre_oldversion: java-1.8.0-openjdk
       elasticsearch_jre_version: jre1.8.0_131
       rolling_upgrade: True

#for upgrading jre with out rolling restart

    - hosts: servers
      roles:
       - {role: elasticsearch, dispatch: ['jreupgrade']}
      vars:
       elasticsearch_jre_oldversion: java-1.8.0-openjdk
       elasticsearch_jre_version: jre1.8.0_131
       rolling_upgrade: False

```

License
-------

N/A



Author Information
------------------

Nathan Aschbacher (naschbac@visa.com
Robert Yeung (ryeung@visa.com)
