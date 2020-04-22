nginx_auth
=======

*nginx_auth* ansible playbook is responsible for deploying `ovn_nginx_auth` package on hosts.

Requirements
-----
* RHEL 7
* Download `tar.gz` from OVN Artifactory
* Needs the path of certificates/key, if `https` is enabled

Variables
----

| var                             |  default            | desc                                                 |
|---------------------------------|---------------------|------------------------------------------------------|
| nginx_auth_host                 |  127.0.0.1          | default ip address to avoid access outside machine   |             
| nginx_auth_port                 |  4242               | http port                                            |
| nginx_auth_scheme               |  http               | can be http or https                                 |
| nginx_auth_ldap_host            |  visadcoce.visa.com | visa ldap host                                       |
| nginx_auth_ldap_port            |  389                | visa ldap port                                       |
| nginx_auth_ldap_groups          |  ".*OVNDEV.*",      | filter AD groups                                     |
| nginx_auth_tarball              | ovn_nginx_auth_v0.1.0-linux-amd64.tar.gz | use tarball present in OVN artifactory |     
| nginx_auth_trusted_urls         | kibana , grafana    | list of trusted urls validated against the value of cookie redirect_uri for securing against url redirect attacks 
| nginx_auth_passthrough          |  true               | for enabling passthrough of kibana and grafana , if false then it should pass through url or headers |                                                                                                                             

and many others...

To find out other variables, checkout `defaults/main.yml`

Dependencies:
------
* `nginx` role, if you want to configure it along with `nginx_auth`

Example Playbook
------

```
  - hosts: nginx_auth
    roles:
       - nginx_auth
```

References
----
[https://visawiki/pages/viewpage.action?pageId=201504839](!https://visawiki/pages/viewpage.action?pageId=201504839)

Author
------
* Mukesh Sharma <mmukesh@visa.com>
