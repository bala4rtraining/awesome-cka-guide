yum mirrors
===========

```
"yum_mirrors" role is useful for creating the yum local repos. 
it will create 
   -- primary local mirror on first node of the group which will copy from artifactory
   -- secondary local mirror on  second node of the group which will copy from primary.
   -- remaining servers in datacenter will connect to primary and secondary yum mirrors with high availability
```


Role Variables
--------------

| var                           | default                                  | 
|-------------------------------|------------------------------------------|
| nginx_default_port            | 8443                                     | 
| yum_mirror_dir                | /opt/app/yum-mirror                      | 
| yum_mirror_id                 | ovn-app-el7                              |
| yum_local_primary_server      | first node of the group                  |
| yum_local_secondary_server    | second node of the group                 |
| artifactory_url               | https://artifactory.trusted.visa.com      |


Extra Variables used for API's
------------------------------

| Extra Var            | usage                                | notes                              |
|----------------------|--------------------------------------|------------------------------------|
| yum_mirror_id        | "ovn-extra-el7" or [ovn-extra-el7]   | To install one specific repo       |
|                      | [ovn-app-el7,ovn-app-temp-el7,--,--] | To install one multiple repos      |
| target_hosts         | "sl73ovnapd217.visa.com"             | To install on one specific server  |
|                      | "server1.visa.com,server2.visa.com"  | To install on multiple servers     |
| yum_server_type      | server_type: "yum_primary"           | To join as Primary yum server      |
|                      | server_type: "yum_secondary"         | To join as secondary yum server    |
|                      | server_type: "yum_client"            | To join as yum clients             |
| yum_remove_data      | yum_remove_data: "True"              | To Remove the yum repos local data |


Dependencies
------------

- All nodes should have `/opt/app` partition to download the artifacts


Example usage of functionalities
--------------------------------

The variable that can be passed to this role is: " yum_mirror_id "

```

Install/Add  yum servers defined in hosts for specific repo:
ansible-playbook ansible_middleware/add_yum_mirrors.yml -i ansible_middleware/inventories/mware/dc1/hosts -u root --private-key config/id_dev --extra-vars '{yum_mirror_id: "ovn-extra-el7"}'

Install/Add  yum servers defined in hosts for all repo:
ansible-playbook ansible_middleware/add_yum_mirrors.yml -i ansible_middleware/inventories/mware/dc1/hosts -u root --private-key config/id_dev --extra-vars '{"yum_mirror_id": [ovn-app-el7,ovn-app-temp-el7,ovn-extra-el7,ovn-epel-el7,centos7-os-x86_64,centos7-updates-x86_64,centos7-extras-x86_64]}'

Install/Add specific server:
ansible-playbook ansible_middleware/add_yum_mirrors.yml -i ansible_middleware/inventories/mware/dc1/hosts -u root --private-key config/id_dev --extra-vars '{target_hosts: "sl73ovnapd217.visa.com"}' --extra-vars '{yum_mirror_id: "ovn-extra-el7"}'

Join the default nodes defined in group as servers for specific/all repos:
ansible-playbook ansible_middleware/join_yum_mirrors_servers.yml -i ansible_middleware/inventories/mware/dc1/hosts -u root --private-key config/id_dev --extra-vars '{"yum_mirror_id": [ovn-app-el7,ovn-app-temp-el7,ovn-extra-el7,ovn-epel-el7,centos7-os-x86_64,centos7-updates-x86_64,centos7-extras-x86_64]}'

Join the specific node as primary or secondary server for given repos:
ansible-playbook ansible_middleware/join_yum_mirrors_servers.yml -i ansible_middleware/inventories/mware/dc1/hosts -u root --private-key config/id_dev --extra-vars '{target_hosts: "sl73ovnapd217.visa.com"}' --extra-vars '{server_type: "yum_primary"}' --extra-vars '{"yum_mirror_id": [centos7-os-x86_64,centos7-updates-x86_64,centos7-extras-x86_64]}'

Join all servers in inventory as clients excluding yum_servers for all repos:
ansible-playbook ansible_middleware/join_yum_mirrors_clients.yml -i ansible_middleware/inventories/mware/dc1/hosts -u root --private-key config/id_dev --extra-vars '{"yum_mirror_id": [ovn-app-el7,ovn-app-temp-el7,ovn-extra-el7,ovn-epel-el7]}' --extra-vars '{yum_server_type: "yum_client"}'

Join the specific node as client for all repos:
ansible-playbook ansible_middleware/join_yum_mirrors_clients.yml -i ansible_middleware/inventories/mware/dc1/hosts -u root --private-key config/id_dev --extra-vars '{"yum_mirror_id": [ovn-app-el7,ovn-app-temp-el7,ovn-extra-el7,ovn-epel-el7]}' --extra-vars '{target_hosts: "sl73ovnapd211.visa.com"}' --extra-vars '{yum_server_type: "yum_client"}'

Remove the node from cluster:
ansible-playbook ansible_middleware/remove_yum_mirrors.yml -i ansible_middleware/inventories/mware/dc1/hosts -u root --private-key config/id_dev --extra-vars '{target_hosts: "sl73ovnapd218.visa.com"}' --extra-vars '{yum_mirror_id: "ovn-extra-el7"}'

Remove the node and delete the data from server:
ansible-playbook ansible_middleware/remove_yum_mirrors.yml -i ansible_middleware/inventories/mware/dc1/hosts -u root --private-key config/id_dev --extra-vars '{target_hosts: "sl73ovnapd218.visa.com"}' --extra-vars '{yum_mirror_id: "ovn-extra-el7"}' --extra-vars '{yum_remove_data: "True"}'

Validate the all yum servers:
ansible-playbook ansible_middleware/validate_yum_mirrors_servers.yml -i ansible_middleware/inventories/mware/dc1/hosts -u root --private-key config/id_dev --extra-vars '{yum_mirror_id: "ovn-extra-el7"}'

Validate the specific yum server:
ansible-playbook ansible_middleware/validate_yum_mirrors_servers.yml -i ansible_middleware/inventories/mware/dc1/hosts -u root --private-key config/id_dev --extra-vars '{target_hosts: "sl73ovnapd218.visa.com"}' --extra-vars '{yum_mirror_id: "ovn-extra-el7"}'

Validate the all yum clients:
ansible-playbook ansible_middleware/validate_yum_mirrors_clients.yml -i ansible_middleware/inventories/mware/dc1/hosts -u root --private-key config/id_dev

Validate the specific yum client:
ansible-playbook ansible_middleware/validate_yum_mirrors_clients.yml -i ansible_middleware/inventories/mware/dc1/hosts -u root --private-key config/id_dev --extra-vars '{target_hosts: "sl73ovnapd211.visa.com,sl73ovnapd212.visa.com"}'

Quiesce the specific node:
ansible-playbook ansible_middleware/quiesce_yum_mirrors.yml -i ansible_middleware/inventories/mware/dc1/hosts -u root --private-key config/id_dev --extra-vars '{target_hosts: "sl73ovnapd218.visa.com"}' --extra-vars '{yum_mirror_id: "ovn-extra-el7"}'


```

Author Information
------------------

* vkondise@visa.com