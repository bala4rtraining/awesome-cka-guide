# Datastax Cassandra 4.8.6

Datastax involve several enhancing features and to customize these features we need to modify
conf folder content files. So the most of our task is to configure and customize these files
via Ansible templates.

The current dse version supports
solr (text processing engine),\
spark (processing power enhancer with distributed computing),\
tomcat (for web publishing),\
logging (via log4j),\
hadoop2-client,\
graph (supporting graph engine) ..etc

Along with cassandra; dse; dse-multi; driver (primarily supports api to participate in communication via gossip protocol, events, cluster connections to session and overall management ).

conf folder under resources folders are:

`/dse/resources ls -l`


drwxr-xr-x@ 15 xyzxyzxyz  2066069167  510 Oct 17 12:39 cassandra/conf\
drwxr-xr-x@  5 xyzxyzxyz  2066069167  170 Oct 17 12:39 dse/conf\
drwxr-xr-x@  6 xyzxyzxyz  2066069167  204 Oct 17 12:39 graph/conf\
drwxr-xr-x@  9 xyzxyzxyz  2066069167  306 Oct 17 12:39 hadoop2-client/conf\
drwxr-xr-x@  4 xyzxyzxyz  2066069167  136 Oct 17 12:39 log4j-appender/logback.xml\
drwxr-xr-x@ 16 xyzxyzxyz  2066069167  544 Oct 17 12:39 solr/conf\
drwxr-xr-x@ 16 xyzxyzxyz  2066069167  544 Oct 17 12:39 spark/conf\
drwxr-xr-x@  9 xyzxyzxyz  2066069167  306 Oct 17 12:39 tomcat/conf

## Getting started
---
We have installed the cassandra at `{{dse_home}}`

To start the service manually we can get to `bin` path of installed location and execute it the following way, i.e.


```

{{dse_home}}/bin/dse cassandra -f

-f is used to run in the foreground.

#Once all the nodes are up, you can check the status of cluster by the following command.

{{dse_home}}/bin/nodetool status

#UN - Up and Normal, which is the normal behavior of the node, indicating the node has joined the cluster and normal.

#Login to `cqlsh` to execute cql queries and verify the replication factor.

{{dse_home}}/bin/cqlsh (ipaddress of that node)

```

`Cassandra.yaml` is the one which we touch most. This is where the majority of the settings of given node are set.
Seed Address in cassandra.yaml should have atleast one ip address from each datacenter for replication factor.

`cassandra-env.sh` is an exec file where we set java env variables including how much of the memory we are going to allocate to JVM( we may not touch this)


Because our teams do not use Spark, Solr and tomcat specifics, we did not map the respective folder areas.
rsc_ is introduced to identify these folder variables shown below. Though Solr and Spark are not implemented
the relevant areas of their conf content files have the updated configuration to an extent; Not validated in
full.

Under Ansible implementation, the task is sub-tasked further to have clarity and ease in maintenance.\
In task roles, we do not use Ansible features of pre-task and post-task.\
Node wise upgrade feature is not considered for now.

Variables used in this context are:

|Var                   |Path                        |
|------------------------------|------------------------------------------------|
|rsc_dse_conf_foldr_path:      | "{{dse_home}}/resources/dse/conf"        |
|rsc_spark_foldr_path:         | "{{dse_home}}/resources/spark"            |
|rsc_cassandra_conf_foldr_path:| "{{dse_home}}/resources/cassandra/conf"    |
|rsc_tomcat_conf_foldr_path:   |"{{dse_home}}/resources/tomcat/conf"        |
where `{{dse_home}}` provides the relative path to the installed location.

**Note:**\
Our installation is via tar ball, we do not use rpm method of installation. Adopting RPM method would create writes into their customized folders of various standard paths, which in turn would disable our customization and folder mapping.\
We require Oracle JDK as mandate with version greater than 1.8 ver.

All variables within the conf files are extensively documented by DataStax.\
Variables introduced as such are structured and can be accessed with prefix notation of role name and module section all over.
With this approach, we can quickly drill down to debug focus area.\
Ex: ovn_datastax['dse']['solr_status'] to read solr_status.\
All associated variables are grouped into separate sections, thus eliminating variable prefix conflict at section level.

Furthermore, variables that are prominent in our install scripts are:

|Var             | Description                                        |
|--------------------|------------------------------------------------------------------------------------------|
|java_home:          |Oracle JDK installed home.                                |
|system_service_dir: |Systemd conf path to start and stop services.                        |
|current_node_ip:    |Ansible node ip that is currently active in the running state.                |
|wrk_foldr :         |Relative path root                                    |
|dse_base_ver:       |Version number of the datastax                                |
|foodcritip_var:     |Key file data encode base64 format                            |
|foodcritiq_var:     |Key file data encode base64 format                            |
|seed_addr_lst:      |Comma separated ip number list to start Gossip protocol. Two required for on cluster.    |

The community edition specific datastax.repo file in the path /etc/yum.repos.d should be removed,
and referred as repos_filename and repos_filepath in our context.

These below variables have exhaustive documentation within the file where we set.\
Documentation is unaltered and is intact. (Refer resources/cassandra/conf/* )

|Var                   | Default                |
|----------------------------------|------------------------------------|
|cluster_name:                     |"test_cassandra"                 |
|num_tokens:                       |"256"                |
|concurrent_writes:                |"32"                |
|snitch_mode:                      |"GossipingPropertyFileSnitch"    |
|listen_address:                   |"{{current_node_ip}}"        |
|rpc_address:                      |"{{current_node_ip}}"        |
|concurrent_compactors:            |"2"                    |
|system_service_foldr:             |"{{ system_service_dir }}"        |
|compaction_throughput_mb_per_sec: |"16"                |
|read_request_timeout_in_ms:       |"5000"                |
|write_request_timeout_in_ms:      |"2000"                |
|seedlist:                         |"{{seed_addr_lst}}"            |
|rack:                             |"RAC1"                |

Spark, Solr and tomcat specific areas are disabled.\
Required changes to enable spark and solr are in place though we do not use.

|Var                   |Path                        |
|------------------------------|------------------------------------------------|
|rsc_dse_conf_foldr_path:      | "{{dse_home}}/resources/dse/conf"        |
|rsc_spark_foldr_path:         | "{{dse_home}}/resources/spark"            |
|rsc_cassandra_conf_foldr_path:| "{{dse_home}}/resources/cassandra/conf"    |
rsc_tomcat_conf_foldr_path:    |"{{dse_home}}/resources/tomcat/conf"        |

Setup for startup boot file is implemented.\
startup_onboot:                "/etc/init.d/dse.init"

Numa is disabled with variable numa.

Cassandra will utilize these below data folders which are configured/referred in cassandra.yml
Under a subsection req_folders.
```
req_foldrs:
data_file_directories:      "{{dse_home}}/cassandra/data"
saved_caches_directory:     "{{dse_home}}/cassandra/saved_caches"
commitlog_directory:        "{{dse_home}}/cassandra/commitlog"
runtime_foldr:              "{{dse_home}}/cassandra/run/cassandra"
log_directory:              "{{dse_home}}/cassandra/log"
backup_directory:           "{{dse_home}}/cassandra/backup"
locks_foldr:                "{{dse_home}}/cassandra/lock/subsys"
heapdump_directory:         "{{dse_home}}/cassandra/data/heapdump"
hints_foldr:                "{{dse_home}}/cassandra/data/hints"
cql_cmd_foldr:              "{{dse_home}}/cql_commands"
```
Below are the standard ports used.

* 7199 - JMX (was 8080 pre Cassandra 0.8.xx)
* 7000 - Internode communication (not used if TLS enabled)
* 7001 - TLS Internode communication (used if TLS enabled)
* 9160 - Thrift client API
* 9042 - CQL native transport port

A provision and implementation is made to support datastax agent.\
As the datastax Opscenter is ready, we can connect web interface for display activities.






