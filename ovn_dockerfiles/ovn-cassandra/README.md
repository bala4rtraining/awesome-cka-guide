# Cassandra Docker

This image is based on the official Cassandra docker image. https://hub.docker.com/_/cassandra/

It should only use for local development. In production, we use DataStax Enterprise(DSE) version.

You can check the compatibility at http://docs.datastax.com/en/landing_page/doc/landing_page/compatibility.html

## How to use this image

**Starting a Cassandra instance is simple**

```bash
docker run -d --name=cassandra --cap-add=SYS_ADMIN --cap-add=SYS_RESOURCE -v /sys/fs/cgroup:/sys/fs/cgroup -p 9042:9042 ovn-docker.artifactory.trusted.visa.com/cassandra:latest
```

**How to create a keyspace and a simple key/value table used for transaction log**

```bash
docker exec -it cassandra cqlsh -f /opt/app/schemas/ovn_script.cql
```

**Set up cluster using Docker compose**

docker-compose.yml
```yaml
version: '3'
services:
  cassandra-seed:
    image: ovn-docker.artifactory.trusted.visa.com/cassandra:latest
    cap_add:
      - SYS_ADMIN
      - SYS_RESOURCE
    volumes:
      - /sys/fs/cgroup:/sys/fs/cgroup
    ports:
      - "9042:9042"
  cassandra-node:
    image: ovn-docker.artifactory.trusted.visa.com/cassandra:latest
    environment:
      CASSANDRA_SEEDS: cassandra-seed
```

To start a Cassandra seed and a node:
```bash
docker-compose up -d cassandra-seed cassandra-node
```

To add additional nodes to the cluster:
```bash
docker-compose up -d --scale cassandra-node=2 cassandra-node
```
To wait for all 3 nodes are up:
```bash
while [ $(docker-compose exec cassandra-seed nodetool status | grep UN | wc -l) -lt 3 ]; do
    docker-compose exec cassandra-seed nodetool status
done
```