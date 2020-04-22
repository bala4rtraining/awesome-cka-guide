Grafana
=========

*deploy_grafana*

Provides: Grafana installation on a single host in OVN dev environment.
creates service grafana-server 

*create_prometheus_datasource*

Provides: Prometheus datasource installation on all prometheus servers through the curl command using python script.

*deploy_grafana_dashboard*

Provides: Dashboard deployment using grafana api's from the json file uploaded on artifactory 

*delete_prometheus_datasource*

Provides: Deletes prometheus datasource on all prometheus servers in that respective environment.


Requirements
------------

* OVN dev environment (RHEL6 or CENTOS7)
* Retrieving RPMs from OVNGIT respository
* ovnmon_dashboards-prometheus-v1.0 tarball which is stored in artifactory



Role Variables
--------------

| var                             |  default   | desc
|:-------------------------------:|:----------:|:---------------------------------------------------:|
| grafana_port                    |  8080      | grafana TCP/IP listener http                        |
| grafana_reverse_proxy_enabled   |  false     | root_url required when behind reverseproxy          |
| grafana_reverse_proxy_url       |  <none>    | root_url in the grafana.ini file                    |
| grafana_initial_install         |  true      | set to false when upgrading                         |
| graphite_host                   |  127.0.0.1 | grafana communicates with graphite                  |
| graphite_port                   |  5603      |                                                     |
| grafana_dashboard_override_enabled | "true"  | overwriting the existing grafana dashboard          |


Dependencies
------------

grafana connects to the graphite host over TCP/IP. The default datasource can also be set/changed manually from the admin functions 
of the Grafana GUI after install. 


Example Playbook
----------------

```
    - name: Run the grafana role for the grafana host in the inventory
    - hosts: grafana
      roles:
        - { role: grafana, dispatch: ['deploy_grafana'] }

    - name: Create prometheus datasource
    - hosts: grafana
      roles:
        - { role: grafana, dispatch: ['create_prometheus_datasource'] }

    - name: Deploy dashboard
    - hosts: grafana
      roles:
        - { role: grafana, dispatch: ['deploy_dashboard'] }
```

License
-------

BSD


Author Information
------------------

ryeung@visa.com
