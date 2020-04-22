kerberos
==========

This role helps in installing and configuring kerberos server and kerberos client.
To install kerberos client with host names opted out of principal names please use 
kerberos_client_nohostname_principal.

Requirements
------------
None

Variables
----

| var                           |  default                            | desc                                        |
|-------------------------------|-------------------------------------|---------------------------------------------|
| kerberos_realm_name           |  VISA.COM                           | realm to be used in kerberos                |
| kerberos_kdc_port             |  88                                 | port at which kdc_server will listen        |
| kerberos_kadmind_port         |  749                                | port at which admin_server will listen      |
| kerberos_kadmin_user          |  root                               | admin user in kdc                           |
| kerberos_skip_create_principals | "false"                           | skips creating principals in kerberos_client_nohostname_principal|
| kerberos_skip_create_keytabs  | "false"                             | skips creating keytabs in kerberos_client_nohostname_principal
 

Example Playbook
------

```
- hosts: kerberos_server
  roles:
  - { role: kerberos, dispatch: ['kerberos_server', 'kerberos_client'] }
```

Dependencies:
-------------
None

References
----------

[https://visawiki.trusted.visa.com/display/OVN/Kerberos+in+Hadoop+Cluster](!https://visawiki.trusted.visa.com/display/OVN/Kerberos+in+Hadoop+Cluster)

Author
------
* Mukesh Sharma <mmukesh@visa.com>