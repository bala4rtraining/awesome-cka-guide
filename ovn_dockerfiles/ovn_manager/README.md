
# OVN_Manager

### About the **OVN_Manager** use case

* Developed to provide a single sign on user interface to have access to OVN monitoring components
* Deployed in the OCE/OCC Visa Datacenters to monitor activities in remote datacenter

#### Defaults
* OVN_Manager runs a nginx server on port 8443 by default.


# Requirements

## Setup

1. Install [docker](http://docker.io) and [docker-compose](http://docker.io).
2. Clone this repository


# Build

```bash
$ cd ovn_manager
$ docker-compose build
```

```bash
$ docker images

# Images will have repository names "ovn_manager/nginx" and "ovn_manager/nginx_auth"

```


# Running the docker containers

```bash
$ docker-compose up -d
```

# Stopping the docker containers

```bash
$ docker-compose down
```

# Passing volumes

|   Docker         |   Directory               |   Volume Option                                                                        |
|------------------|---------------------------|----------------------------------------------------------------------------------------|
|`nginx`           |   config directory:       |   `-v /opt/app/data/ovn_manager/nginx/conf.d:/etc/nginx/conf.d`                        |
|`nginx`           |   certificate directory:  |   `-v /opt/app/data/ovn_manager/nginx/tls:/etc/pki/tls`                                |
|`nginx`           |   log directory:          |   `-v /opt/app/data/ovn_manager/nginx/log:/var/log/nginx`                              |
|`nginx`           |   static html directory:  |   `-v /opt/app/data/ovn_manager/nginx/html:/var/www/html`                              |
|`ovn_nginx_auth`  |   config directory:       |   `-v /opt/app/data/ovn_manager/ovn_nginx_auth/config:/opt/app/ovn_nginx_auth/config`  |
|`ovn_nginx_auth`  |   log directory:          |   `-v /opt/app/data/ovn_manager/ovn_nginx_auth/log:/var/log/ovn_nginx_auth`            |

### More information
- https://visawiki/display/OVN/Docker+usage+in+the+OVN+infrastructure

- https://visawiki.trusted.visa.com/pages/viewpage.action?pageId=201504839
