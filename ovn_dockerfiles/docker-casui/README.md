
# CAS-UI

### About the **CAS-UI** use case 

* Developed to provide a user interface to have access to Clearing-Passthrough activities.
* Deployed in the OCE/OCC Visa Datacenters to monitor CAS activities in remote datacenter

#### Defaults
* CAS-UI runs on port 7443 by default. But should be accessible through Nginx only.

**Note:** CAS-UI connect to CAS-Tools which is a API Server deployed within remote Datacenter.


# Requirements

## Setup

1. Install [Docker](http://docker.io).
3. Clone this repository

## Increase `vm.max_map_count` on your host

You need to increase the `vm.max_map_count` kernel setting on your Docker host.


# Build & Tag & push to registry

```bash
$ cd docker-casui
$ docker build -t ovn_cas_ui .
```

```bash
$ docker images

# Determine the IMAGE ID to use in the next command matching the repository

$ docker tag "<<img-id>>" sl55ovnapq01.visa.com/ovn_cas_ui 
$ docker push sl55ovnapq01.visa.com/ovn_cas_ui 
```


# Running the docker containers

```bash
$ docker run --name ovn_cas_ui -d -p 8443:8443 ovn_cas_ui
```

# Stopping the docker containers

```bash
$ docker stop "<<container-id>>"
```

### More information
- https://visawiki/display/OVN/Docker+usage+in+the+OVN+infrastructure

- https://visawiki/display/OVN/Clearing+Operations+-+Storyboard OVN Clearing Passthrough Storyboard and high level design
