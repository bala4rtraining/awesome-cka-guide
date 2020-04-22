
# ovnmon 

### About the **ovnmon** use case 

* Developed to provide a central hub of monitoring services using kibana, grafana, elastalert etc.
* Deployed in the OCE/OCC Visa Datacenters to monitor the remote country clusters

#### Defaults
* Kibana runs exposing the home page on port 5601
* Elasticsearch runs on port 9200
* Grafana runs the Web GUI on port 3000
* elastalert is called using `docker-compose run elastalert`
> Elastalert Rules are exposed on the host in ovnmon/elastalert/rules
* logstash currently logs anything coming in on port 5000 (for development) 
> logstash config files are exposed on the host in ovnmon/logstash/config

**Note:** OVN specialized config files for elastalert and logstash are updated in the config directories after the container is started.


# Requirements

## Setup

1. Install [Docker](http://docker.io).
2. Install [Docker-compose](http://docs.docker.com/compose/install/) **version >= 1.6**.
3. Clone this repository

## Increase `vm.max_map_count` on your host

You need to increase the `vm.max_map_count` kernel setting on your Docker host.
To do this follow the recommended instructions from the Elastic documentation: [Install Elasticsearch with Docker](https://www.elastic.co/guide/en/elasticsearch/reference/current/docker.html#docker-cli-run-prod-mode)


# Build & Tag & push to registry

A standard docker-compose build is used, from the ovnmon directory

```bash
$ cd ovnmon
$ docker-compose build
```

```bash
$ docker images

# Determine the IMAGE ID to use in the next command matching the repository

$ docker tag db7bd0ca8700 sl55ovnapq01.visa.com/ovnmon_elastalert 
$ docker push sl55ovnapq01.visa.com/ovnmon_elastalert 
```


# Running the docker containers

Start the ELK stack using *docker-compose*:
(assuming the current directory is the one with docker-compose.yml)

```bash
$ docker-compose up
```

You can also choose to run it in background (detached mode):

```bash
$ docker-compose up -d
```


Stop the ELK stack using *docker-compose* from a new session on the same host

```bash
$ docker-compose down
```




### More information
- https://visawiki/display/OVN/Docker+usage+in+the+OVN+infrastructure

- https://visawiki.visa.com/pages/viewpage.action?spaceKey=OVN&title=OVNMON