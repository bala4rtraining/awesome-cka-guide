Role Name
=========

*graphite*

Provides: Graphite installation on a single host in OVN dev environment.
creates services httpd, carbon-cache


Requirements
------------

OVN dev environment (playbook works with both RHEL6 or Centos7)
Artifactory access from the ansible client is required for the RPMs.


Role Variables
--------------


| var   |default     | 
|----------------|------------|
| graphite_host  |  127.0.0.1| 
| graphite_port  |  81       | 


Dependencies
------------

graphite includes carbon + whisper and is dependent on apache+mod_wsgi, django, python, cairo.
grafana has its own ansible role (called separately)


Example Playbook
----------------


```
    - hosts: graphite
      roles:
         - graphite
```


License
-------

BSD


Author Information
------------------

ryeung@visa.com
