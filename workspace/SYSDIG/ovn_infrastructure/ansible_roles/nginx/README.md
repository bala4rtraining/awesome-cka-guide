nginx
=====

*nginx* role is useful for deploying and configuring `nginx` on cluster machines. Nginx with auth-plugin is used for providing authentication/authorization to various OVN components, e.g. CAS-UI, Grafana, Nomad-UI.

Requirements
-----

* RHEL 7
* OVN Artifactory

Role Variables
-----

| var                         |  default   | desc
|-----------------------------|------------|-----------------------------------------------------|
| nginx_default_port          |  8443      | nginx default site port                             |
| nginx_exporter_port         |  9120      | nginx port used for prometheus_exporters
| nginx_sites                 |  {}        | add multiple nginx's sites                          |
| nginx_configs               |  {}        | add different types of configs                      |
| nginx_locations             |  {}        | configure multiple locations for any site           |

For more details, refer [defaults/main.yml](defaults/main.yml) or below playbook for sample usage.

Sample Playbook
--------------

The variables that can be passed to this role are:

```yaml
nginx_user: "nginx"

# for adding mulitple sites
nginx_sites:
  default:
     - listen 8443
     - server_name localhost

# for configure different configs like upstreams 
nginx_configs:
  grafana_upstream:
      - upstream grafana {
          server localhost:3000;
        }

# for configuring same site for different upstreams 
nginx_locations:
  - site: default
    locations:
      - name: grafana
        location: 
          - location /grafana/ {
              proxy_pass http://grafana/;
            }
```


Dependencies
-----
None

References
----
[https://www.nginx.com/resources/wiki/](!https://www.nginx.com/resources/wiki/)

Author
----
* Mukesh Sharma <mmukesh@visa.com>