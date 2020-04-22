# Webapp

### About the **Webapp** use case

* Developed to provide a user interface to have access the centralized information about the OVN Team.

#### Defaults
* WEBAPP runs on port 8090 by default. But should be accessible through Nginx only.
#### Note : 
* 1. tar ball should be present in current working directory of host machine
* 2. tar ball which copied into container should have naming convention team*.tar.gz
## Requirements

### Setup

1. Install [Docker](http://docker.io).
2. Clone this repository

### Build & Tag & Push to registry

```bash
$ cd ovn_webapp
$ docker build -t webapp .
```

```bash
$ docker images

# Determine the IMAGE ID to use in the next command matching the repository

$ docker tag "<<img-id>>" ovn-docker.artifactory.trusted.visa.com/ovn_webapp
$ docker push ovn-docker.artifactory.trusted.visa.com/ovn_webapp 
```


### Running the docker containers

```bash
$ docker run --name webapp -d -p 8090:8090 ovn-docker.artifactory.trusted.visa.com/ovn_webapp
```

### Stopping the docker containers

```bash
$ docker stop "<<webapp>>"
```

### On a VM

SSH into a VM:

```bash
ssh sl73ovnapd112
#UED password

pmrun su -
#UPM password

mkdir -p /opt/app/data/webapp

docker-compose <<docker-compose.yml>> up -d
```


## SSH-ing into the container

```bash
docker exec -it <mycontainerid> bash

# or ssh with root access
docker exec -u root -it <mycontainerid> bash
```


### More information
- https://visawiki/display/OVN/Docker+usage+in+the+OVN+infrastructure
- https://visawiki/display/OVN/OVNdev+Webapp+Low+Level+Design OVN Clearing Pass through Storyboard and high level design.

