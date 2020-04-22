yum mirrors
===========

```
"yum_mirrors" role is useful for creating the yum repos. 
it will create 
   -- primary and secondary yum local mirrors will sync the artifcats from artifactory.
   -- Remaining nodes on the inventory will be pointed to the primary/secondary servers defined in inventory
```


Role Variables
--------------

| var                           | default                                  | 
|-------------------------------|------------------------------------------|
| nginx_default_port            | 8443                                     | 
| yum_mirror_dir                | /opt/app/data/yum-mirror                 |
| yum_config_dir                | /etc/yum.repos.d                         |
| yum_repos                     | ovn-deployment-el7                       |
| artifactory_url               | https://artifactory.trusted.visa.com      |



Dependencies
------------

- All nodes should have `/opt/app/data` partition.


License
-------
N/A



Notes
-------------
detailed documentaion of this yum mirrors implementation is available in below wiki link.
https://visawiki.trusted.visa.com/pages/viewpage.action?pageId=369430642


Author Information
------------------

* vkondise@visa.com