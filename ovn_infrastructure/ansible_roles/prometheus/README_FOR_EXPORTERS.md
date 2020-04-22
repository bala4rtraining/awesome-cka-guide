prometheus_exporter
===================

These tasks install and start prometheus exporters on nodes in the OVN environment. Below dispatch actions which can be used to install required exporter on the node.
List of exporters:
* node_exporter - Collects system level metrics ex. cpu, memory, network, disk
* statsd_exporter - Collects metrics from statsd port ex. nomad metrics, erlang service metrics
* udp_repeater - Collects metrics on 8125 udp port and emits on 9125 and 9126 port. It is required to run heka and statsd_exporter together.

* jmx_exporter - jmx exporter is used to collect JMX metrics from all Java
  based services/daemons. This runs as java agent that is invoked with
  -javaganet <java agent.jar> option along with Java service we are only
  installing agent jar and agent config file in this playbook. Actual
  invocation of this will be configured along with actual Java service that
  we are going to monitor.

* Elasticsearch exporter - Collects metrics about elasticsearch e.g. cluster status, get requests, number of docs
  in index, number of indices, number of shards, etc.

* Pushgateway exporter - It allow ephemeral and batch jobs to expose their metrics to Prometheus.

* Haproxy exporter - Collects metrics about Haproxy e.g. backend server status, frontend server status, requests etc.

* Process exporter - Collects metrics about non systemd processes e.g. tripwire


Going ahead we will add more exporters for jmx, kafka

Logs for node_exporter are redirected to syslog with level as info. Startup logs are under /var/log/prometheus/node_exporter.


Requirements
------------
* 3rd party node_exporter-0.14.0.linux-amd64 tarball stored in artifactory
* 3rd party udp_repeater-1.0.0.linux-amd64 tarball stored in artifactory
* 3rd party statsd_exporter-0.4.0.linux-amd64 tarball stored in artifactory
* 3rd party node_exporter-0.14.0.linux-amd64 tarball which is stored in artifactory
* 3rd party jmx_prometheus_javaagent0.9.linux-amd64 tarball which is stored in artifactory
* 3rd party elasticsearch_exporter-1.0.1.linux-amd64 tarball which is stored in artifactory
* 3rd party pushgateway-0.4.0.linux-amd64 tarball which is stored in artifactory
* 3rd party haproxy_exporter-0.7.1.linux-amd64 tarball which is stored in artifactory
* 3rd party process-exporter-0.1.0.linux-amd64 tarball which is stored in artifactory


Role Variables
--------------

UDP repeater exporter
-------------

|      Variable                  |   Default value  |                Description                 |
|:------------------------------:|:----------------:|:------------------------------------------:|
| udp_repeater_listen_port       |       8125       |        Port where udp_repeater will listen |
| udp_repeater_exporter_port     |       9125       |      Port where statd_exporter will listen |
| udp_repeater_heka_port         |       9126       |                Port where heka will listen |


statsd exporter
-------------
|      Variable                  | Default value    |                Description                 |
|:------------------------------:|:----------------:|:------------------------------------------:|
| statsd_exporter_port           |       9102       | Port where statsd_exporter will be running |
| statsd_exporter_log_level      |       INFO       |                    Node_exporter log level |
| statsd_exporter_listen_address |  127.0.0.1:9125  |  Address where statsd_exporter will listen |


node exporter
-------------
|      Variable           | Default value |                Description               |
|:-----------------------:|:-------------:|:----------------------------------------:|
| node_exporter_port      |      9100     | Port where node_exporter will be running |
| node_exporter_log_level |      INFO     |                  Node_exporter log level |


JMX Exporter for HDFS
---------------------

|    Variable                                   | Value  |  Description                 |
|:---------------------------------------------:|:------:|:----------------------------:|
| hadoop_namenode_jmxexporter_port              |  9104  |  JMX export port for namenode|
| hadoop_resource_manager_jmxexporter_port      |  9105  |  JMX export port for res mgr |
| hadoop_datanode_jmxexporter_port              |  9106  |  JMX export port for datanode|
| hadoop_node_manager_jmxexporter_port          |  9107  |  JMX export port for node mgr|


Elasticsearch Exporter
---------------------

|    Variable                                   | Value   |  Description                                          |
|:---------------------------------------------:|:-------:|:-----------------------------------------------------:|
| elasticsearch_exporter_address                |  :9108  |  port over which elasticsearch exporter emits metrics |



FluentD Exporter
---------------------

|    Variable                                   | Value   |  Description                                          |
|:---------------------------------------------:|:-------:|:-----------------------------------------------------:|
| fluentd_exporter_address                      |  :9113  |  port over which fluentd exporter emits metrics       |


Pushgateway Exporter
--------------------

|    Variable                                   | Value   |  Description                                          |
|:---------------------------------------------:|:-------:|:-----------------------------------------------------:|
| pushgateway_exporter_address                  |  :9110  |  port over which pushgateway exporter emits metrics   |
| pushgateway_persistence_file                  |  Empty  |  For persistence specify file else stored in memory   |
| pushgateway_exporter_log_level                |  INFO   |  Pushgateway log level                                |

Haproxy Exporter
----------------

|    Variable                                   | Default Value   |  Description                                          |
|:---------------------------------------------:|:---------------:|:-----------------------------------------------------:|
| haproxy_exporter_address                      |  :9109          |  port over which haproxy exporter emits metrics       |
| haproxy_exporter_opts                         | all metrics     | comma seperated list of metrics which should be exposed (Refer: http://cbonte.github.io/haproxy-dconv/configuration-1.5.html#9.1 ) |

OVN monitoring exporter
--------------------------

| Variable                  | Default        |Description |
| ---------------------     |-------------   |------------|
| ```scrape-URI```**(*)**   | (Empty)        | On which server it will be used to scrape the data. (Format: **IP:Port** ) |
| ```collectors.enabled```  | All            | List of comma separated exporters that you want to include in the binary. |
| ```web.listen-address```  | :9114          | Prometheus port address on which to expose metrics and web interface. |
| ```web.telemetry-path```  | /metrics       | Path under which to expose prometheus metrics. |
| ```hsm.DeviceID```        | 0001           | Device ID of the HSM. |
| ```ssl-enabled```         | False          | The connection to the prometheus server, will it be ssl enabled or not. |
| ```client-private-key```  | (Empty)        | Path to PEM file that conains the private key for client auth. |
| ```client-cert```         | (Empty)        | Path to PEM file that conains the corresponding cert for the private key. |
| ```ssl-service-enabled``` | False          | Whether SSL is enabled for the service. |
| ```sr.timeout```          | 1 Minute       | Timeout for trying to get stats from the service. |
| ```sr.ca```               | (Empty)        | Path to PEM file that conains trusted CAs for the service connection. |
| ```sr.client-private-key```| (Empty)        | Path to PEM file that conains the private key for client auth when connecting to service. |
| ```sr.client-cert```       | (Empty)        | Path to PEM file that conains the corresponding cert for the private key to connect to service. |





Process Exporter
----------------

|    Variable                                   | Default Value   |  Description                                          |
|:---------------------------------------------:|:---------------:|:-----------------------------------------------------:|
| process_exporter_port                         |  9115           |  port over which process exporter emits metrics       |
| web.telemetry-path                            |  /metrics       |  Path under which to expose prometheus metrics        |


Dependencies
------------

None.


Example Playbook
----------------

```sh

   - name: install node_exporter
      hosts: all:!cumulus_switch:!ovn_manager
      roles:
        - { role: prometheus, dispatch: ['node_exporter'] }

   - name: install udp_exporter
      hosts: ovn_mediator_servers:ovn_switch_servers
      roles:
        - { role: prometheus, dispatch: ['udp_repeater'] }

   - name : install statsd_exporter
      hosts: prometheus_statsd_exporter
      roles:
        - { role: prometheus, dispatch: ['statsd_exporter'] }


   - name: install jmx_exporter
      hosts: hadoop_namenodes,hadoop_datanodes
      roles:
        - { role: prometheus, dispatch: ['jmx_exporter'] }


   - name: install elasticsearch_exporter
      hosts: elasticsearch
      roles:
        - { role: prometheus, dispatch: ['elasticsearch_exporter'] }


   - name: install pushgateway_exporter
      hosts: prometheus_pushgateway
      roles:
        - { role: prometheus, dispatch: ['pushgateway_exporter'] }

   - name: install haproxy_exporter
     hosts: haproxy
     roles:
       - { role: prometheus, dispatch: ['haproxy_exporter'] }

   - name: install ovn_monitoring_exporter
     hosts: ovn_monitoring_exporter
     roles:
       - { role: prometheus, dispatch: ['ovn_monitoring_exporter'] }

   - name: install process_exporter
     hosts: all:!cumulus_switch:!ovn_manager
     roles:
       - { role: prometheus, dispatch: ['process_exporter'] }       
```
License
-------

N/A


Author Information
------------------

Nilang Shah (nilshah@visa.com)
Pankaj Bhatt (ppadmaka@visa.com)

References
-----------

* [Node_exporter overview](https://github.com/prometheus/node_exporter)
* [Statsd_exporter overview](https://github.com/prometheus/statsd_exporter)
* [udp-repeater overview](https://github.com/troydhanson/network/blob/master/udp/repeater/udp-repeater.c)
* [jmx_exporter github](https://github.com/prometheus/jmx_exporter)
* [elasticsearch_exporter github](https://github.com/justwatchcom/elasticsearch_exporter)
* [pushgateway_exporter github](https://github.com/prometheus/pushgateway)
* [haproxy_exporter github](https://github.com/prometheus/haproxy_exporter)
* [process_exporter github](https://github.com/ncabatoff/process-exporter)
