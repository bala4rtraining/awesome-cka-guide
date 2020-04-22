keystore
==========

This role creates java keystore and trustore.

Requirements
------------
This role assumes that`jre`, `keystore_owner` and `keystore_group` are already exists on the machine.

Variables
----

| var                           |  default        | desc                             |
|-------------------------------|-----------------|----------------------------------|
| keystore_file_name            |  ovn-keystore   | keystore file name               |
| keystore_alias                |  ovn-keystore   | keystore alias                   |
| keystore_truststore_file_name |  ovn-truststore | truststore alias                 |
| keystore_cert | "/etc/pki/tls/certs/{{ inventory_hostname }}.pem"   | keystore certificate path |
| keystore_key  | "/etc/pki/tls/private/{{ inventory_hostname }}.pem" | keystore key path         |
| keystore_ca   | "/etc/pki/tls/certs/bundle.pem"                     | keystore ca path          |

Checkout `defaults/main.yml` for other variables.

Example Playbook
------

```
- hosts: hdfs_HA_All_nodes
  roles:
  - { role: keystore }
  vars:
  - keystore_truststore_ca:
    - { cert: "/etc/pki/tls/certs/bundle.pem", alias: "server.pem" }
```

Dependencies:
-------------
None

References
----------

[https://docs.oracle.com/javase/7/docs/api/java/security/KeyStore.html](!https://docs.oracle.com/javase/7/docs/api/java/security/KeyStore.html)

Author
------
* Mukesh Sharma <<mmukesh@visa.com>>