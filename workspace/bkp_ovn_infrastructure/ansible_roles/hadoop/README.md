hadoop
=========

*_hadoop_* role provides: 
* Cloudera Hadoop (CDH) installation for a cluster
* Configuration of `Prometheus` based monitoring using Prometheus JMX Exporter for namenode and datanode.

Requirements
------------

* OVN dev environment (playbook works with both RHEL7 or Centos7)
* 3rd party Cloudera RPMs are stored in OVNGIT
* JMX Exporter Jar and configuration file should be installed on Hadoop nodes by JMX Exporter role. 

Role Variables
--------------

**Hadoop**

| var                     | default                                  | 
|-------------------------|------------------------------------------|
| hadoop_reinstall        | False                                    | 
| hadoop_namenode_port    | 8020                                     |
| hadoop_dfs_name_dir     | /opt/app/hadoop-hdfs/dfs/name            |
| hadoop_datanode_port    | 11999                                    |
| hadoop_dfs_data_dir     | /opt/app/hadoop-hdfs                     |
| hadoop_enable_kerberos  | false                                    |
| hadoop_enable_tls       | false                                    |

**JMX Exporter**

| var                                 | default                            | 
|-------------------------------------|------------------------------------|
| hadoop_namenode_jmxexporter_port    |   9104                             | 
| hadoop_datanode_jmxexporter_port    |   9105                             |
| jmx_exporter_config_dir             |   /etc/prometheus/jmx_exporter     |
| jmx_exporter_archive_base           |   /opt/app/prometheus/jmx_exporter |

**Dispatch Actions**

`hadoop` role supports following dispatch actions.

| Action                       | Description                                                                   | 
|------------------------------|-------------------------------------------------------------------------------|
| start-all                    | Stops all hadoop related service in specific order                            | 
| stop-all                     | Starts all hadoop related service in specific order                           |
| clean                        | Cleans hadoop installation, erase all data                                    |
| zkfc-deploy                  | Deploys zkfc client on namenodes                                              |
| namenode-deploy              | Deploys namenode on nodes                                                     |
| datanode-deploy              | Deploys datanode on nodes                                                     |
| journalnode-deploy           | Deploys journalnode on nodes                                                  |
| update-config                | Update config files (/etc/hadoop/conf) for all hdfs nodes              |


Dependencies
------------

- All nodes should have `/opt/app` partition.

Notes
-----

- Run `stop_hadoop_cluster.yml` before `hadoop.yml` for making changes in existing cluster.
- Run `clean_hadoop.yml` before `hadoop.yml` with `hadoop_reinstall` flag  for reinstalling the cluster. [**WARN: Deletes data**]
- Run `hadoop_enable_tls.yml` with `--extra-vars="{ hadoop_enable_tls: True }"` and environment specific serect file for enabling TLS on exisiting hadoop cluster.
- Run `update_hadoop_config.yml` to make changes in exisiting cluster without redeploying all components.

Example Playbook
----------------

```
- hosts: hdfs_HA_All_nodes
  roles:
    - hadoop
```

Author Information
------------------

* vkondise@visa.com
* ryeung@visa.com
* ppadmaka@visa.com
* mmukesh@visa.com
