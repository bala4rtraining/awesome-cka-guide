Nomad Parameterized Jobs
===
About
---
Nomad parameterized jobs are a collection of [parameterized job](https://www.nomadproject.io/docs/job-specification/parameterized.html). In short, a parameterized job is a deferred nomad job, that will be run when a dispatch call for that particular job is received. In the dispatch call, the caller can specify parameters that can be different from the other dispatch calls of the same job. This will grant us flexibility on rerunning the same job, but has different parameter without resubmitting the job specification to Nomad.

Dependencies
---
Before we can deploy these parameterized jobs, the following must exist in the cluster:
- Nomad client cluster
- Nomad server cluster

Tasks
---
The following tasks should be run on all servers where Nomad client is running:
- **deploy_bridge_ea_fetch_package.yml** : Installs the BridgeEA package.
- **deploy_cfprocessor_package.yml** : Installs the CFProcessor (Collection File Processor) package.

The following tasks should be run on any of the server where Nomad client or server is running, as long as they all belong to the same Nomad cluster:
- **submit_bridge_ea_fetch_job.yml** : Registers the BridgeEA fetch job to Nomad cluster.
- **submit_cfprocessor_job.yml** : Registers the CFProcessor job to Nomad cluster.
- **submit_consolidator_job.yml** : Registers the Consolidator job to the Nomad cluster.

The reason Consolidator doesn't have a deploy package task, is because Consolidator executable is downloaded right away when we're dispatching the parameterized job. This might change in the future.

Configuration
---
Below are configurations that can be overridden.

### Consolidator variables
|   Variable                         |  Default Value                              | Description                                                      |
| :---------------------------------:|:-------------------------------------------:|:-----------------------------------------:|
| consolidator_version               |  "0.1.0-rc1"                                | Consolidator version      |
| consolidator_group                 | "batch_processing"                          | Kafka consumer group  |
| consolidator_topics                | "settlement"                                | Kafka topics |
| consolidator_kafka_timeout         | 10000                                       | Kafka timeout |
| consolidator_events_channel_enable | true                                        | Kafka flag to enable events channel |
| consolidator_rebalance_enable      | true                                        | Kafka flag to enable rebalance |
| consolidator_backoff_min           | 100                                         | Backoff minimum period in millisecond |
| consolidator_backoff_max           | 3000                                        | Backoff maximum period in millisecond |
| consolidator_backoff_factor        | 2                                           | Duration will be multiplied by this number |
| consolidator_backoff_jitter        | true                                        | Add randomization to the backoff duration when enabled. |
| bridge_ea_fetch_install_dir        | "/opt/app/bridgeeafetch/bin"                | Installation directory for BridgeEA fetch package |
| bridge_ea_fetch_version            | "bridgeeafetch-0.1.0-rc1.el7.centos.x86_64" | BridgeEA fetch version |
| bridge_ea_fetch_group              | "bridgeea_processing"                       | Bridge EA fetch Kafka consumer group|
| bridge_ea_fetch_topics             | "settlement"                                | Bridge EA fetch Kafka topics |
| bridge_ea_fetch_hadoop_username    | "hdfs"                                      | HDFS username to be used for Bridge EA fetch | 
| bridge_ea_fetch_hadoop_directory   | "/bridgeeafetch"                            | Bridge EA fetch HDFS root directory |
| bridge_ea_fetch_file_perm          | "0744"                                      | Bridge EA fetch file permission |
| cfprocessor_install_dir            |  "/opt/app/cfprocessor"                     | Installation directory for CFProcessor |
| cfprocessor_version                | "cfprocessor-0.1.0-rc1.el7.centos.x86_64"   | CFProcessor version |
