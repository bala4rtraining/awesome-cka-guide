This repository contains code(dockerfile and configurations) to run containerized aerospike service in Cloudview Environments.

As this is community edition, we'll have only 2 namespace(ovn_devintegration and ovn_qaintegration) for now. Each namespace can have 1023 sets.

The strategy for using sets is not clear in increment 4. A clearer strategy for multitenancy will be in place in increment 5.


1)To Buid the image  :

docker build .

2)To run a standalone container :

docker run -tid --name aerospike -p 1000:3000 -p 1003:3003 ovn-docker.artifactory.trusted.visa.com/centos7_aerospike:v4.8.08


Directory Structure:

 -  /etc/aerospike - Configurations for Aerospike
 -  /usr/bin - Contains asd process
 -  /var/log/aerospike - Log files for Aerospike
 -  /var/run/aerospike - Contains asd.pid file
 -  /opt/aerospike/data - Contains .dat file for namespaces

Base docker image has created with following steps:
FROM ovn-docker.artifactory.trusted.visa.com/centos:7.3.1611

ENV AEROSPIKE_VERSION 4.8.0.8
ENV AEROSPIKE_ARCHIVE aerospike-server-community-${AEROSPIKE_VERSION}-el7.tgz
ENV AEROSPIKE_ARCHIVE_URL "https://www.aerospike.com/artifacts/aerospike-server-community/${AEROSPIKE_VERSION}/$AEROSPIKE_ARCHIVE"

Install Aerospike Server and Tools
Install Aerospike
RUN \
  yum install -y wget \
  && yum install python lua5.2 gettext -y \
  && wget $AEROSPIKE_ARCHIVE_URL \
  && wget $AEROSPIKE_ARCHIVE_URL".sha256" -O sha256 \
  && cat sha256 | sha256sum -c - \
  && mkdir aerospike \
  && tar xzf $AEROSPIKE_ARCHIVE --strip-components=1 -C aerospike \
  && rpm -ivh aerospike/aerospike-server-*.rpm \
  && rpm -ivh aerospike/aerospike-tools-*.rpm \
  && mkdir -p /var/log/aerospike/ \
  && mkdir -p /var/run/aerospike/ \
  && rm -rf $AEROSPIKE_ARCHIVE sha256 aerospike /var/lib/apt/lists/*

NOTE: Useful in case the base image needs to be changed.

General information on Aerospike ports
 -  3000 – service port, for client connections
 -  3001 – fabric port, for cluster communication
 -  3002 – mesh port, for cluster heartbeat
 -  3003 – info port
But for CV environments we're using only port 3000 and 3003

The following have been created beforehand in the base image as random user that is assigned to CV pods may not be able to create it.
 -  /var/log/aerospike/aerospike.log
 -  /var/run/aerospike/asd.pid

 Create schema on the go using a schema which can be supplied to aql in following manner:
 aql -f, --file=path      Execute the commands in the specified file

 Note: The image is not cybersecurity signed for use in production. It should be only used in dev and qa.