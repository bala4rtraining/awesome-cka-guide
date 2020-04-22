certificates
=======

*certificates* ansible playbook is responsible for deploying certificates required to enable SSL on hosts.

Requirements
-----
* Needs data, name and path for all private key, certificate and CA certificate

Variables
----

| var              |     default                          | desc                                                 |
|------------------|--------------------------------------|------------------------------------------------------|
| cert_data        |      "<sample_cert>"                 | actual cerificate                                    |
| cert_name        |      "{{ inventory_hostname }}.pem"  | name of certificate file                             |
| cert_path        |      "/etc/pki/tls/certs"            | path to store the certificate                        |
| key_data         |      "<sample_key>"                  | actual key                                           |
| key_name         |      "{{ inventory_hostname }}.pem"  | name of key file                                     |
| key_path         |      "/etc/pki/tls/private"          | path to store the key                                |
| ca_cert_data     |      "<sample_ca_cert>"              | actual CA certificate                                |
| ca_cert_name     |      "ca.pem"                        | name of CA certificate file                          |
| ca_cert_path     |      "/etc/pki/tls/certs"            | path to store the CA certificate                     |
| cert_user        |      "root"                          | user to which files will belong                      |
| cert_group       |      "root"                          | group to which files will belong                     |


Dependencies:
------
* none

Example Playbook
------

```
  - hosts: nginx
    roles:
       - nginx
       - certificates
    
```

References
----
[https://visawiki.trusted.visa.com/display/OVN/Open+VisaNet+Home](!https://visawiki.trusted.visa.com/display/OVN/Open+VisaNet+Home)