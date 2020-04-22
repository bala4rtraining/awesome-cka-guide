Riak
===========

```
"Riak" role is useful for Installing Riak component on the servers.
   -- primary server is the  first node of the group .
```


Role Variables
--------------

| var                           | default                                  | 
|-------------------------------|------------------------------------------|
| Riak_primary_server           | first node of the group                  |
| artifactory_url               | https://artifactory.trusted.visa.com      |


Extra Variables used for API's
------------------------------

| Extra Var            | usage                                | notes                              |
|----------------------|--------------------------------------|------------------------------------|
| target_hosts         | "sl73ovnapd216.visa.com"             | To install on one specific server  |
|                      | "server1.visa.com,server2.visa.com"  | To install on multiple servers  
| riak_remove_data    | riak_remove_data: "True"              | To Remove the yum repos local data |



Example usage of functionalities
--------------------------------

The variable that can be passed to this role is: " yum_mirror_id "

```

Install/Add  riak node:
ansible-playbook ansible_middleware/add_riak_node.yml -i ansible_middleware/inventories/mware/dc1/hosts -u root --private-key ~/ovn_infrastructure/config/id_dev  --extra-vars '{ target_hosts: "sl73ovnapd216.visa.com,sl73ovnapd215.visa.com" }'


Join the Raik nodes:
ansible-playbook ansible_middleware/join_riak_node.yml -i ansible_middleware/inventories/mware/dc1/hosts -u root --private-key ~/ovn_infrastructure/config/id_dev  --extra-vars '{ target_hosts: "sl73ovnapd216.visa.com,sl73ovnapd215.visa.com" }'


Remove the node from cluster:
ansible-playbook ansible_middleware/remove_riak_node.yml -i ansible_middleware/inventories/mware/dc1/hosts -u root --private-key ~/ovn_infrastructure/config/id_dev  --extra-vars '{ target_hosts: "sl73ovnapd216.visa.com,sl73ovnapd215.visa.com" }'


Validate the Riak Nodes:
ansible-playbook ansible_middleware/quiesce_riak_node.yml -i ansible_middleware/inventories/mware/dc1/hosts -u root --private-key ~/ovn_infrastructure/config/id_dev  --extra-vars '{ target_hosts: "sl73ovnapd216.visa.com,sl73ovnapd215.visa.com" }'


Quiesce the Riak Nodes:

ansible-playbook ansible_middleware/quiesce_riak_node.yml -i ansible_middleware/inventories/mware/dc1/hosts -u root --private-key ~/ovn_infrastructure/config/id_dev  --extra-vars '{ target_hosts: "sl73ovnapd216.visa.com,sl73ovnapd215.visa.com" }'


```

Author Information
------------------

* rparvath@visa.com