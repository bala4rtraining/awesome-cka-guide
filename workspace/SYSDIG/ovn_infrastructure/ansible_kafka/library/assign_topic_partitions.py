#!/usr/bin/python
# TODO: update document
ANSIBLE_METADATA = {
    'metadata_version': '0.0.1',
    'status': ['preview'],
    'supported_by': 'Vamsi Putrevu'
}

DOCUMENTATION = '''
---
module: assign-topic-partitions

short_description: module to manage kafka cluster

version_added: "2.4"

description:
    - "module to generated new replica configurations for each topic in the kafka cluster"
    - This module assumes that kafka was previously installed
    - The module dynamically introspects the kafka cluster, through the provided kafka brokers, and generated new replica configurations for each topic in the cluster.
    - Assumptions:
    - 1. New Kafka nodes to be added to kafka cluster are added to the inventories#kafka group
    - 2. Every broker in the cluster is homogeneous - i.e., will be assigned approximatly equal partitions and replicas
    - 3. Partitions for each topic will be a function of the number of brokers in the cluster. Currently No. of partitions = total number of brokers in the cluster * partition_factor
    - 4. Every topic has same 3 of replicas which is sent as a param to the module as replica_count
    - Module constructs new replica configurations and uploads to every broker in the cluster
    - Finally, the module applies and creates new partitions for each topic on the cluster (will be done only if new partition count is higher than existing partition count)


options:
    brokers:
        description:
            - "host:port of broker where module runs for operations like describe cluster, partition reassignment. any available broker can be used"
        required: true
    zookeepers:
        description:
            - "host:port of zookeeper needed for shell commands excutions like create topic, reassignment of partitions"
        required: true
    balance_cluster:
        description:
            - Controls reassignment of partitions
        required: false
    replica_count:
        description:
            - No. of replicas for each topic partition
        required: false
        default: 3
    partition_factor:
        description:
            - No. of partitions for each topic = (No. of ndoes in the cluster * partition_factor)
        required: false
        default: 1 i.e., no. of partitions = no. of brokers in the cluster

extends_documentation_fragment:
    - azure

author:
    - Vamsi Putrevu (vputrevu@visa.com)
'''

EXAMPLES = '''
# Pass a broker host:port to log suggested partition assignment in verbose mode (use -v while running ansible)
- name: Log recommended partition assignment
  assign-topic-partitions:
    brokers: 100.100.100.100:9092
    zookeepers: 120.120.120.120:2181

# pass in a message and have changed true
- name: Reassign partitions
  assign-topic-partitions
    brokers: 100.100.100.100:9092,100.100.100.101:9092
    zookeepers: 120.120.120.120:2181,120.120.120.121:2181
    balance_cluster: true
    partition_factor: 2

# fail the module
'''

RETURN = '''
original_message:
    description: The current paritions state
    type: str
message:
    description: "recommended reassignment template if balance_cluster=false (default). stdout of reassignment shell command if balance_cluster=true"
    type: str
'''

import json
from time import sleep

from ansible.module_utils.basic import AnsibleModule
from pykafka.client import KafkaClient

def desc_topic(client, topic_name):
    """Returns detailed information about given topic in cluster.
    :param client: KafkaClient connected to the cluster.
    :type client:  :class:`pykafka.KafkaClient`
    :param topic_name: name of kafka topic.
    :type client:  :class:`str`
    """
    topic_desc = {}
    topic = client.topics[topic_name]
    partitions_list = [
        {'topic': topic.name, 'parition': p.id, 'replicas': [r.id for r in p.replicas]} for p in topic.partitions.values()
    ]

    topic_desc['name'] = topic.name
    topic_desc['partions'] = partitions_list
    return topic_desc

def desc_cluster(client):
    """Returns detailed information about all topics in cluster.
    :param client: KafkaClient connected to the cluster.
    :type client:  :class:`pykafka.KafkaClient`
    """
    topics_list = []
    for topic_name in client.topics:
        topic_desc = desc_topic(client, topic_name)
        topics_list.append(topic_desc)
    return topics_list

def reassign_template_for_topic(client, topic_name, partition_factor, replica_count):
    """Returns recommended partition reassignment list for given topic
    :param client: KafkaClient connected to the cluster.
    :type client:  :class:`pykafka.KafkaClient`
    :param topic_name: name of kafka topic.
    :type client:  :class:`str`
    """
    topic = client.topics[topic_name]

    nodes = [broker.id for _, broker in client.brokers.items()]

    new_replicas = []
    for p in range(0, len(nodes) * partition_factor):
        new_replica = {}
        new_replica["topic"] = topic_name
        new_replica["partition"] = p
        new_replica["replicas"] = []
        # TODO: This should be dynamic based on the topic
        for r in range(0, replica_count):
            index = (p+r) % len(nodes)
            new_replica["replicas"].append(nodes[index])
        new_replicas.append(new_replica)
    return new_replicas

def reassign_template(client, partition_factor, replica_count):
    """Returns recommended partition reassignment template for all topics
    :param client: KafkaClient connected to the cluster.
    :type client:  :class:`pykafka.KafkaClient`
    """
    new_replicas = []
    for topic_name in client.topics:
        new_replicas += reassign_template_for_topic(client, topic_name, partition_factor, replica_count)
    template ={"version": 1, "partitions": new_replicas}
    return template

def run_module():
    # define the available arguments/parameters that a user can pass to
    # the module
    module_args = dict(
        brokers=dict(type='str', required=True),
        zookeepers=dict(type='str', required=True),
        kafka_dir=dict(type='str', required=True),
        balance_cluster=dict(type='bool', required=False, default=False),
        partition_factor=dict(type='int', required=False, default=1),
        replica_count=dict(type='int', required=False, default=3),
    )

    # seed the result dict in the object
    # we primarily care about changed and state
    # change is if this module effectively modified the target
    # state will include any data that you want your module to pass back
    # for consumption, for example, in a subsequent task
    result = dict(
        changed=False,
        original_message='',
        message=''
    )

    # the AnsibleModule object will be our abstraction working with Ansible
    # this includes instantiation, a couple of common attr would be the
    # args/params passed to the execution, as well as if the module
    # supports check mode
    module = AnsibleModule(
        argument_spec=module_args,
        supports_check_mode=True
    )

    # if the user is working with this module in only check mode we do not
    # want to make any changes to the environment, just return the current
    # state with no modifications
    if module.check_mode:
        return result
    # during the execution of the module, if there is an exception or a
    # conditional state that effectively causes a failure, run
    # AnsibleModule.fail_json() to pass in the message and the result
    if module.params['brokers'] == '':
      module.fail_json(msg='assign-topic-partitions: Need one or more brokers to be passed.', **result)

    # manipulate or modify the state as needed (this is going to be the
    # part where your module will do what it needs to do)
    client = KafkaClient(module.params['brokers'])
    replica_count_param = module.params['replica_count']
    nodes = [broker.id for _, broker in client.brokers.items()]
    replica_count = min(replica_count_param, len(nodes))
    template = reassign_template(client, module.params['partition_factor'], replica_count)

    result['message'] = template
    result['original_message'] = template
    if module.params['balance_cluster']:
        with open(module.params['kafka_dir'] + '/config/preferred_replica_configuration.json', 'w') as outfile:
            json.dump(template, outfile)

        # Increase number of partitions for topic
        # partitions_to_add = len(filter(lambda x: x.get('topic') == 'test',template['partitions']))
        command_result = {}
        for topic_name in client.topics:
            args = [
                '{}/bin/kafka-topics.sh'.format(module.params['kafka_dir']),
                '--alter',
                '--zookeeper',
                module.params['zookeepers'].rstrip('\n'),
                '--topic',
                topic_name,
                '--partitions',
                '{}'.format(len(nodes) * module.params['partition_factor'])
            ]
            rc, out, err = module.run_command(args=args)
            command_result[topic_name] = out or err
        result['message'] = command_result

    # TODO: use whatever logic you need to determine whether or not this module
    # made any modifications to your target, check err messages from run_command?
    # set to true only if above run_command was successful
    result['changed'] = True

    # in the event of a successful module execution, you will want to
    # simple AnsibleModule.exit_json(), passing the key/value results
    module.exit_json(**result)

def main():
    run_module()

if __name__ == '__main__':
    main()
