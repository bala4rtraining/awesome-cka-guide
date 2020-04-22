Envoy
=====
This role provides tasks to setup service mesh using Envoy proxy. The list of services should be provided in envoy_services var.

Variables
---------
| var                                   | default                                      | desc                                       |
|---------------------------------------|----------------------------------------------|--------------------------------------------|
| envoy_rpm                             | envoy-1.5.0-1.el7.centos.x86_64              | rpm name                                   |
| envoy_user                            | was                                          | running user                               |
| envoy_group                           | was                                          | running group                              |
| envoy_log_level                       | info                                         | log level                                  |
| envoy_log_path                        | /var/log/envoy/envoy.log                     | log path                                   |
| envoy_admin_access_log_path           | /var/log/envoy/admin_access.log              | admin access log path                      |
| envoy_admin_port                      | 9901                                         | admin port                                 |
| envoy_statsd_port                     | 9125                                         | statsd port                                |
| envoy_cert                            |                                              | certificate                                |
| envoy_cert_name                       | envoy.pem                                    | certificate filename                       |
| envoy_cert_hash                       |                                              | certificate hash                           |
| envoy_key                             |                                              | private key                                |
| envoy_key_name                        | envoy.pem                                    | private key filename                       |
| envoy_ca_cert                         |                                              | CA certificate                             |
| envoy_ca_cert_name                    | envoy_ca.pem                                 | CA certificate filename                    |
| envoy_cipher_suites                   | ECDHE-RSA-AES256-GCM-SHA384                  | cipher suites                              |
| envoy_services                        | []                                           | list of services                           |
| envoy_service_lb_type                 | round_robin                                  | load balancing type                        |
| envoy_service_admin_port              | 8800                                         | service admin port                         |
| envoy_service_ingress_port            | 9211                                         | service ingress port for incoming requests |
| envoy_service_egress_port             | 9001                                         | service egress port for outgoing requests  |
| envoy_service_admin_access_log_path   | /var/log/envoy/service_admin_access.log      | service admin access log                   |
| envoy_service_ingress_access_log_path | /var/log/envoy/service_ingress_access.log    | service ingress access log                 |
| envoy_service_egress_access_log_path  | /var/log/envoy/service_egress_access.log     | service egress access log                  |
