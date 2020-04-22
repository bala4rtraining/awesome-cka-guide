Kafka
=========

This role installs and starts Kafka brokers on nodes in the OVN environment.


Requirements
------------
A JDK compatible with the Kafka version and distribution.


Role Variables
--------------
    'username' is the username running the Kafka services
    'source' is the location of the Kafka tarball
    'kafka_data_dir' is the filesystem path to where Kafka stores data
    'broker_configuration_lead' is the ansible_hostname of the node responsible for configuring Kafka once installed
    'min_insync_replicas' is the minimum number of acks a reliable producer will need in order to write successfully
    'number_brokers' is the number of brokers (ie. the number of hosts)
    'kafka_topic_names' are the name of the topic(s) to create/configure

Monitoring KAFKA thorugh JMX exporter
-------------------------------------
To start monitoring KAFKA thorugh JMX exporter and send metrics to prometheus, set following flag to "true":
monitor_kafka_using_prometheus: "true". This will emit the metrics over host:9111/metrics. These metrics will be available in Prometheus


Dependencies
------------
Java runtime.


Example Playbook
----------------

    hosts: ovn_vm
      become: true
      roles:
        - kafka
      vars:
        username: ovn
            source: files/{{tarball}}.tgz
            kafka_install_dir: /opt/kafka
            kafka_data_dir: /opt/app/kafka
            number_brokers: 3
            broker_configuration_lead: "{{groups['ovn_vm'][0]}}"
            min_insync_replicas: "{{ (number_brokers | int) - 1 }}"
            kafka_topic_names: '["topic_name"]'


License
-------

N/A



Author Information
------------------

Michael Quinlan (miquinla@visa.com)
