Prometheus
==========

This role deploys prometheus server on a node in the OVN environment. Prometheus server will get installed in folder /opt/app/prometheus and configurations will be installed under /etc/prometheus. Role can start prometheus servers in HA mode based on the inventory label named as 'prometheus_mode'.

* prometheus_mode = active, prometheus server will pull the metrics from the exporters and will use prometheus-active.yml.j2 template.
* prometheus_mode = standby, prometheus server will pull the metrics from the active prometheus server and will use prometheus-standby.yml.j2 template.
* prometheus_mode = lt-active, prometheus server will pull the metrics from the active prometheus server every 1 minute and will retain the data for 1+ year. lt-active is shorthand for long term active, because it retains data for longer duration. Scrape interval and retention period are configurable.
* prometheus_mode = lt-standby, prometheus server will pull the metrics from the lt-active prometheus server every 1 minute and will retain the data for 1+ year. This server will provide HA for lt-active.

Prometheus federation will work over nginx reverse proxy on default port 8443 over mutual ssl. All prometheus servers will listen on 127.0.0.1 and exposed only over nginx proxy over mutual ssl.

This role can install prometheus server in non HA configuration as well. It will use prometheus-active.yml.j2 template to start prometheus server.
Note: If you run this role without prometheus_mode specified in inventory file for multiple host, it will start all of them in active mode pulling metrics from exporters. 
For failover, below steps should be executed to make standby prometheus instance active.

* Confirm /etc/prometheus/prometheus.yml soft link is pointing to /etc/prometheus/prometheus-standby.yml
* Change /etc/prometheus/prometheus.yml soft link to point to /etc/prometheus/prometheus-active.yml.
* execute service prometheus reload
* Reconfigure nginx proxy to point to active prometheus
* Reconfigure lt-active server to pull metrics from the active prometheus server

Prometheus supports configuration reload without restarting service. Similar steps needs to be executed for changing active prometheus to standby. 
Logs for prometheus are redirected to syslog with level as info. Startup logs are under /var/log/prometheus.

Validation tasks are added in role to check config and alert rules before installing them on prometheus servers using promtool utility. It will help us to catch configuration errors early.

Dispatch methods
------------------
1. provision_prometheus: This task file is used to deploy prometheus and exporters in environment

2. prometheus_failover: This task file is used to failover active prometheus server to standby one when current prometheus goes down. You need to pass prometheus_active_node="<new_active_host>" and prometheus_standby_node="<new_standby_host>" as extra args

3. prometheus_alertrules: This task file is used to deploy alerts separately in prometheus

4. prometheus_alertmanager: This task deploys alertmanager on node in the OVN environment. Alertmanager will get installed in folder /opt/app/prometheus/alertmanager and configurations will be installed under /etc/prometheus/alertmanager. For HA, we can start alertmanager on mutiple nodes. Logs for alertmanager are redirected to syslog with level as info. All alertmanager servers will listen on 127.0.0.1 and exposed only using nginx reverse proxy over mutual ssl. However, alertmanager gossip will be done over non ssl port. Prometheus will push alerts over mutual ssl to alertmanager using nginx reverse proxy port 8443.

Requirements
------------
3rd party prometheus-1.7.1.linux-amd64 tarball which is stored in artifactory.
3rd party alertmanager-0.8.0.linux-amd64 tarball which is stored in artifactory.


Role Variables
--------------

|            Variable            			| Default value |                    Description                    	|
|:-----------------------------------------:|:-------------:|:-------------------------------------------------:	|
| prometheus_port                			|      9088     |             Port where prometheus will be running 	|
| prometheus_data_retention      			|    720h0m0s   | Time till old data in prometheus will be retained 	|
| prometheus_node_exporter_port  			|      9100     |   Node_exporter port to pull system level metrics 	|
| prometheus_alertmanager_port   			|      9087     |                  Alertmanager port to push alerts 	|
| prometheus_log_level           			|      INFO     |                              Prometheus log level 	|
| prometheus_rule_files          			|  alert.rules  |        List of rule files for alert configuration 	|
| prometheus_datacenter_id       			|      N/A      |     Datacenter where prometheus server is running 	|
| prometheus_lt_data_retention   			|   8760h0m0s   |     Time till long term prometheus will keep data 	|
| prometheus_heap_size_in_bytes  			|  system_mem/4 |     Amount of heap allocated to prometheus server 	|
| prometheus_listen_address      			|     127.0.0.1:9088     |                   Prometheus http and ui endpoint 	|
| prometheus_statsd_exporter_port			|      9102     |  Stasd_exporter port to pull statsd based metrics 	|
| prometheus_elasticsearch_exporter_port	|      9108    	| Port where elasticsearch exporter will expose metrics |
| prometheus_pushgateway_exporter_port |      9110     | Pushgateway_exporter to pull metrics for short lived jobs |
| prometheus_haproxy_exporter_port    |    9109       |         Port where haproxy will expose metrics      |
| prometheus_external_host             | ovndev.visa.com | This will be used for constructing the link/URL back to prometheus source pages from alertmanager pages |
| alertmanager_port             |               9087                  |           Port where alertmanager will be running |
| alertmanager_data_retention   |             720h0m0s                |        Data in alertmanager will be retained till |
| alertmanager_log_level        |               INFO                  |                            Alertmanager log level |
| alertmanager_gossip_port      |               6783                  |                          Alertmanager gossip port |
| alertmanager_smtp_smarthost   |       internet1.visa.com:25         |                SMTP host to send out email alerts |
| alertmanager_smtp_from        |      PROMETHEUS-ALERTS@visa.com     | 		         Form address of the email alerts |

Dependencies
------------
None.


Example Playbook
----------------
    - name: start prometheus servers
      hosts: prometheus_server
      gather_facts: yes
      roles:
        - prometheus

License
-------
N/A


Author Information
------------------
Nilang Shah (nilshah@visa.com)

References
-----------
* [Prometheus overview](https://prometheus.io/docs/introduction/overview/)
* [Design wiki for monitoring using prometheus](https://visawiki/display/OVN/Monitoring+LTA+using+Prometheus)
* [Prometheus home page](https://prometheus.io/)
* [Alertmanager overview](https://prometheus.io/docs/alerting/alertmanager/)
* [Design wiki for monitoring using prometheus](https://visawiki/display/OVN/Monitoring+LTA+using+Prometheus)
* [Alertmanager github page](https://github.com/prometheus/alertmanager)
* [Prometheus data migration] (https://visawiki.trusted.visa.com/display/OVN/Prometheus+Data+store+take+snapshot+and+copy+snapshot)