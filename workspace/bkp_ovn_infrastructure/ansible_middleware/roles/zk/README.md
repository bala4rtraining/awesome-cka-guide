# zookeeper
This is an Ansible project for working around with different functionalities like add,remove and join for Zookeeper in Middlware Infrastructure

**Prerequisites:**
* [ansible](#ansible)

Add Node - Install and deploy zookeeper on a single node
Join Node - Start zookeeper service on the node, add the node to zookeeper cluser, update the node IP to all the other nodes in the cluster and bounce the daemon.
Remove Node - Shut down zookeeper on a node and remove the node from cluster
Quiesce Node - Just remove zookeeper node from the cluster. No new traffic will go to the node. But node status will be up
Validate Node - Get the status of the zookeeper node.

##Running the playbook
$ cd ~/ansible_middleware
$ ansible-playbook -i inventory/hosts add_zk_node.yml -e node=localhost
$ ansible-playbook -i inventory/hosts join_zk_node.yml -e node=localhost
$ ansible-playbook -i inventory/hosts remove_zk_node.yml -e node=localhost
$ ansible-playbook -i inventory/hosts quiesce_zk_node.yml -e node=localhost
$ ansible-playbook -i inventory/hosts validate_zk_node.yml -e node=localhost
