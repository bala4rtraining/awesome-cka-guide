CAS_Tools
=========

This role installs and starts either a Cas-tools server or Cas-tools cli on nodes in the OVN environment.


Requirements
------------
Exectuable binary (for example: cas-tool-server and cas-tool-cli) is created in CentOS/RHEL and is stored in artifactory as a tarball. It is created as part of jenkins buid job for cas_tools.
The jenkins job is: https://sl73ovnapd112:8443/jenkins-ci/job/ovn_cas_tools_build/


Role Variables
--------------
|   Variable            |   Default Value                             |   Description                                       |
| :--------------------:|:-------------------------------------------:|:---------------------------------------------------:|
|   cas_tool_server     |   true                                      |   If true install server, else install cli.         |
|   cas_tool_version    |   "0.1.0"                                   |   Variable showing the cas_tools version.           |
|   cas_tool_tarball    |   "ovn_cas_tools-v0.1.0-linux-amd64.tar.gz" |   The name cas_tools tarball.                       |
|   cas_tool_http_port  |   "7443"                                    |   The port on which cas_tools will listen           |
|   cas_tool_scheme     |   http                                      |   Scheme for cas_tool, http or https                |
|   cas_tool_kafka_topic|   xdc_sync                                  |   Kafka topic to use for XDC replication.           |

Dependencies
------------
Cas_Tool require running instances of nomad server, riak cluster, kafka brokers.
Cas_Tool connects to nomad, riak and kafka services for the purpose of job scheduling, metadata querying, and XDC sync respectively
It also requires certificates to be stored, if we want to run it securely.


Example Playbook
----------------

```yml
- name: Deploy CAS_Tool Server
  hosts: default
  gather_facts: yes
  sudo: yes
  roles:
    - cas_tool
  vars:
    cas_tool_server: true
```

License
-------

N/A



Author Information
------------------

Rohit More (rmore@visa.com)

References
----------
* https://stash.trusted.visa.com:7990/projects/OP/repos/ovn_cas_tools/browse
* https://visawiki/display/OVN/Clearing+Operations+-+Storyboard OVN Clearing Passthrough Storyboard and high level design

