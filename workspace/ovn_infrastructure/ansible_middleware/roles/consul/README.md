Consul
======

```
"Consul" role is for installing and configuring Consul server and client instances.
This role will create
   -- Consul server instances on nodes defined under [consul_server:children]
   -- Consul client instances on nodes defined under [consul_client:children]

Example Usage: For adding nodes
To install all consul servers
    ansible-playbook ansible_middleware/addnode_consul.yml -i ansible_middleware/inventories/mware/dc1/hosts -u root --private-key config/id_dev --extra-vars '{ agent_mode: "server" }'

To install all consul clients
    ansible-playbook ansible_middleware/addnode_consul.yml -i ansible_middleware/inventories/mware/dc1/hosts -u root --private-key config/id_dev --extra-vars '{ agent_mode: "client" }'

To install all consul servers and clients
    ansible-playbook ansible_middleware/addnode_consul.yml -i ansible_middleware/inventories/mware/dc1/hosts -u root --private-key config/id_dev --extra-vars '{ agent_mode: "all" }'

To install specific consul server(s)
    ansible-playbook ansible_middleware/addnode_consul.yml -i ansible_middleware/inventories/mware/dc1/hosts -u root --private-key config/id_dev --extra-vars '{ agent_mode: "server" }' --extra-vars '{ target_hosts: "sl73ovnapd211,sl73ovnapd212" }'
    where the host provided should be a part of the group consul_server as defined in the hosts file else the installation will be skipped. This is to be used in scenarios where a node needs to be replaced. We would like the hosts file to be updated.

To install specific consul client(s)
    ansible-playbook ansible_middleware/addnode_consul.yml -i ansible_middleware/inventories/mware/dc1/hosts -u root --private-key config/id_dev --extra-vars '{ agent_mode: "client" }' --extra-vars '{ target_hosts: "sl73ovnapd214,sl73ovnapd215" }'
    where the host provided should be a part of the group consul_client as defined in the hosts file else the installation will be skipped. This is to be used in scenarios where a node needs to be replaced. We would like the hosts file to be updated.

Follow similar procedure for joining node(s) and removing node(s)
```

Author Information
------------------

* rkrishn3@visa.com