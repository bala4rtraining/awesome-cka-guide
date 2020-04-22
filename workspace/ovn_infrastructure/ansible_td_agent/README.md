Td-agent
==========
Fluentd(td-agent) is an open source data collector for building an unified logging layer. We use fluentd to collect logs from
nodes and forward them to elasticsearch, which then can be viewed from Kibana.
We use fluentd in client server architecure and we call the nodes as forwarder and aggregator.
Forwarder collects logs from nodes and forwards them to one of the fluentd aggregator.
We have set of dedicated fluentd nodes acting as high available log aggregator.
If one of the aggregator is down, forwarder forwards the logs to next aggregator.
Fluentd aggregators then forward these logs to elasticsearch in required format. 
These logs can be viewed from Kibana.

List of Playbooks
------------------

1. clean_td_agent.yml
Removes the traces of td-agent from all the forwarder and aggregator nodes

2. deploy_input_config.yml
This playbook selectively deploys the input configuration for log files. If no fluentd_input_config_list is passed, this will deploy all the input configurations.
e.g. To deploy only kafka and hadoop config pass following extra-var
--extra-vars "fluentd_input_config_list=[kafka,hadoop]"

3. deploy_td_agent_aggregator.yml
This playbook deploys td-agent rpm, config files and plugins to a node. Use this playbook for deploying td-agent from scratch on a node and start that node as log aggregator.

4. deploy_td_agent_forwarder.yml
This playbook deploys td-agent rpm, config files and plugins to a node. Use this playbook for deploying td-agent from scratch on a node and start that node as log forwarder.

5. fix_log_permissions.yml
This playbook will fix all the log directory permissions

License
-------
N/A


Author Information
------------------
Ashish Kankaria (akankari@visa.com)

References
-----------
* [Fluentd website](https://www.fluentd.org/)
* [Fluentd source code](https://github.com/fluent/fluentd)
* [OVN logging architecture using Fluentd](https://visawiki.trusted.visa.com/display/OVN/OVN+Logging+Framework+LTA)