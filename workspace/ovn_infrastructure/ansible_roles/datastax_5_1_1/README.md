
# DSE 5.1.1
---
Datastax involve several enhancing features and to customize these features we need to modify
conf folder content files. So the most of our task is to configure and customize these files
via Ansible templates.

## Requirements
Oracle Java SE Runtime Environment 8 (JDK) (1.8.0_40 minimum) or OpenJDK 8. Earlier or later versions are not supported.


## Role dispatch modes.

|  dispatch name                | description                                                                           |
|-------------------------------|---------------------------------------------------------------------------------------|
|prereq_common                  | install all the prereqs required                                                      |
|prereq_dse                     | prereqs required for dse such as user creation, working dir creation,.. etc           |
|prereq_cassandra               | create pid folder and logfolders for cassandra                                        |
|install_dse                    | downloading and untaring the tar-ball dse.                                            |
|install_dse_agent              | downloading and untaring the tar-ball dse-agent                                       |
|config_dse                     | config all the conf flies in dse/conf. Also, init script for dse.                     |
|config_cassandra               | config all the conf flies in cassandra/conf. importantly cassandra.yaml, etc.         |
|config_dse_agent               | config dse-agent                                                                      |
|config_miscellaneous           | misc config for tomcat, etc.                                                          |
|start_dse                      | systemd for dse                                                                       |

## Dependencies
The tarballs for DSE 5.1.1 are stored on the artifactory.
Firewall is open for the ports.

## Overview

The current dse version supports\
solr (text processing engine),\
spark (processing power enhancer with distributed computing),\
tomcat (for web publishing),\
logging (via log4j),\
hadoop2-client,\
graph (supporting graph engine) ..etc

The major difference between DSE 4.8.6 and Datastax 5.1.1 is that, Cassandra version has been changed from Apache Cassandra 2.1.13 to Apache Cassandra 3.10.0

There are lot of enhanced features between the Apache **2.X** and **3.X**  versions. One difference between is the  **TimeWindowCompactionStrategy (TWCS)**. TWCS is similar to **DateTieredCompactionStrategy (DTCS)** with simpler settings. In our case Jaeger has the compatibility issue with Cassandra 2.X.

All the changes / latest release notes for v5.1.1 can be found at [latest release notes for Datastax 5.1.1 ](http://docs.datastax.com/en/dse/5.1/dse-admin/datastax_enterprise/releaseNotes/RNdse.html#RNdse)

Current version's conf folder under resources folders are:
Along with cassandra; dse; dse-multi; driver (primarily supports api to participate in communication via
gossip protocol, events, cluster connections to session and overall management ).

`dse_home/dse/resources ls -l`
where dse_home provides the relative path to the installed location.

cassandra/conf/*
dse/conf/*
graph/conf/*
hadoop2-client/conf/*
log4j-appender/logback.xml
solr/conf/*
spark/conf/*
tomcat/conf/*


Because our teams do not use Spark, Solr and tomcat specifics, we did not map the respective folder areas.
rsc_ is introduced to identify these folder variables shown below. Though Solr and Spark are not implemented
the relevant areas of their conf content files have the updated configuration to an extent; Not validated in
full.

Under Ansible implementation, the task is sub-tasked further to have clarity and ease in maintenance.\
In task roles, we do not use Ansible features of pre-task and post-task.
Node wise upgrade feature is not considered for now.

Variables used in this context are:

| Var                             |  Path                                    |
|---------------------------------|------------------------------------------|
|  rsc_dse_conf_foldr_path:       |  "{{dse_home}}/resources/dse/conf"       |
|  rsc_spark_foldr_path:          |  "{{dse_home}}/resources/spark"          |
|  rsc_cassandra_conf_foldr_path: |  "{{dse_home}}/resources/cassandra/conf" |
|  rsc_tomcat_conf_foldr_path:    |   "{{dse_home}}/resources/tomcat/conf"   |


**Note:-**
Our installation is via tar ball, we do not use rpm method of installation. Adopting RPM method would create writes
into their customized folders of various standard paths, which in turn would disable our customization and folder
mapping. We require Oracle JDK as mandate with version greater than 1.8 ver.

All variables within the conf files are extensively documented by DataStax.\
Variables introduced as such are structured and can be accessed with prefix notation of role name and module
section all over. With this approach, we can quickly drill down to debug focus area.\
Ex: dstax511_ovn_datastax['dstax511_dse']['solr_status'] to read solr_status.\
All associated variables are grouped into separate sections, thus eliminating variable prefix conflict at section level.

Furthermore, variables that are prominent in our install scripts are:

|Var                                | Description                                                       |
|-----------------------------------|-------------------------------------------------------------------|
|java_home:                         |   Oracle JDK installed home.                                      |
|dstax511_system_service_dir:       |    Systemd conf path to start and stop services.                  |
|current_node_ip:                   |   Ansible node ip that is currently active in the running state.  |
|dstax511_wrk_foldr :               |    Relative path root                                             |
|dstax511_dse_base_ver:             |    Version number of the DataStax                                 |
|foodcritip_var:                    |   Key file data, in base64 encoded format                         |
|foodcritiq_var:                    |   Key file data, in base64 encoded format                         |
|dstax511_seed_addr_lst:            |    Comma separated ip number list to start Gossip protocol.       |

Seeds in `cassandra.yaml` has the seed information. Seeds help the gossip protocol to take place. Best practice is to have at least one node from each datacenter in this list.

The community edition specific datastax.repo file in the path /etc/yum.repos.d should be removed,
and referred as repos_filename and repos_filepath in our context.

These below variables have exhaustive documentation within the file where we set.\
Documentation is unaltered and is intact. (Refer resources/cassandra/conf/* )

|   Var                                         |   Default                      |
|-----------------------------------------------|--------------------------------|
|    dstax511_cluster_name:                     |  "test_cassandra"              |
|    dstax511_num_tokens:                       | "256"                          |
|    dstax511_concurrent_writes:                |  "32"                          |
|    dstax511_snitch_mode:                      |  "GossipingPropertyFileSnitch" |
|    dstax511_listen_address:                   |  "{{current_node_ip}}"         |
|    dstax511_rpc_address:                      |  "{{current_node_ip}}"         |
|    dstax511_concurrent_compactors:            |   "2"                          |
|    dstax511_system_service_foldr:             |  "{{ system_service_dir }}"    |
|    dstax511_compaction_throughput_mb_per_sec: |"16"                            |
|    dstax511_read_request_timeout_in_ms:       |"5000"                          |
|    dstax511_write_request_timeout_in_ms:      |"2000"                          |
|    dstax511_seedlist:                         |"{{dstax511_seed_addr_lst}}"    |
|    rack:                                      |"RAC1"                          |

Spark, Solr and tomcat specific areas are disabled.
Required changes to enable spark and solr are in place though we do not use.

|                                  |  Path                                       |
|----------------------------------|---------------------------------------------|
|    rsc_dse_conf_foldr_path:      | "{{dse_home}}/resources/dse/conf"           |
|    rsc_spark_foldr_path:         | "{{dse_home}}/resources/spark"              |
|    rsc_cassandra_conf_foldr_path:| "{{dse_home}}/resources/cassandra/conf"     |
|    rsc_tomcat_conf_foldr_path:   | "{{dse_home}}/resources/tomcat/conf"        |

Setup for startup boot file is implemented.\
dstax511_startup_onboot:                "/etc/init.d/dse.init"

Numa is disabled with variable numa.

Cassandra will utilize these below data folders which are configured/referred in cassandra.yml
under a subsection req_folders.
```
dstax511_req_foldrs:
dstax511_data_file_directories:      "{{dse_home}}/cassandra/data"
dstax511_saved_caches_directory:     "{{dse_home}}/cassandra/saved_caches"
dstax511_commitlog_directory:        "{{dse_home}}/cassandra/commitlog"
dstax511_runtime_foldr:              "{{dse_home}}/cassandra/run/cassandra"
dstax511_log_directory:              "{{dse_home}}/cassandra/log"
dstax511_backup_directory:           "{{dse_home}}/cassandra/backup"
dstax511_locks_foldr:                "{{dse_home}}/cassandra/lock/subsys"
dstax511_heapdump_directory:         "{{dse_home}}/cassandra/data/heapdump"
dstax511_hints_foldr:                "{{dse_home}}/cassandra/data/hints"
dstax511_cql_cmd_foldr:              "{{dse_home}}/cql_commands"
```

## Example playbook
```
- include: ../ovn_vars.yml ovn_vars_hosts
- name: start deploying datastax opscenter
hosts: cassandra_servers
gather_facts: yes
roles:
  - role: datastax_5_1_1
    dispatch:
      - prereq_common
      - prereq_dse
      - prereq_cassandra
      - prereq_dse_agent
      - install_dse
      - install_dse_agent
      - config_dse
      - config_cassandra
      - config_dse_agent
      - config_miscellaneous
      - start_dse

```


Few of the installation is done in defaults. For [ recommended production settings ](http://docs.datastax.com/en/dse/5.1/dse-admin/datastax_enterprise/config/configRecommendedSettings.html#configRecommendedSettings__setra-settings) we can refer here.
Below are the standard ports used.

* 7199 - JMX (was 8080 pre Cassandra 0.8.xx)
* 7000 - Internode communication (not used if TLS enabled)
* 7001 - TLS Internode communication (used if TLS enabled)
* 9160 - Thrift client API
* 9042 - CQL native transport port

A provision and implementation is made to support datastax agent.
As the datastax Opscenter is ready, we can connect web interface for display activities.


