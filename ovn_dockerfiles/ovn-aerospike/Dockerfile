#
# Aerospike Server Dockerfile
#
# http://github.com/aerospike/aerospike-server.docker
#

#FROM centos:7.3.1611

# if this does not work then please use above
FROM ovn-docker.artifactory.trusted.visa.com/centos:7.3.1611

#ENV AEROSPIKE_VERSION 4.8.0.5
#ENV AEROSPIKE_SHA256 0bf86bfa7d47a11db9cef9782b6812ce0507a45fd5951fcc92b357878b6a7d8b
#ENV http_proxy http://userproxy.visa.com:80
ENV AEROSPIKE_VERSION 4.2.0.5
ENV AEROSPIKE_ARCHIVE aerospike-server-community-${AEROSPIKE_VERSION}-el7.tgz
ENV AEROSPIKE_ARCHIVE_URL "https://www.aerospike.com/artifacts/aerospike-server-community/${AEROSPIKE_VERSION}/$AEROSPIKE_ARCHIVE"




# Install Aerospike Server and Tools


# Install Aerospike
 RUN \
   yum update -y \
     && yum install -y logrotate \
     && yum install -y wget \
       && wget $AEROSPIKE_ARCHIVE_URL \
         && wget $AEROSPIKE_ARCHIVE_URL".sha256" -O sha256 \
           && cat sha256 | sha256sum -c - \
             && mkdir aerospike \
               && tar xzf $AEROSPIKE_ARCHIVE --strip-components=1 -C aerospike \
                 && rpm -i aerospike/aerospike-server-*.rpm \
                   && mkdir -p /var/log/aerospike/ \
                     && mkdir -p /var/run/aerospike/ \
                       && rm -rf $AEROSPIKE_ARCHIVE sha256 aerospike /var/lib/apt/lists/*
                       
# Add the Aerospike configuration specific to this dockerfile
COPY aerospike.conf /etc/aerospike/aerospike.conf
COPY entrypoint.sh /entrypoint.sh
# Mount the Aerospike data directory
VOLUME ["/opt/aerospike/data"]
# VOLUME ["/etc/aerospike/"]


# Expose Aerospike ports
#
#   3000 – service port, for client connections
#   3001 – fabric port, for cluster communication
#   3002 – mesh port, for cluster heartbeat
#   3003 – info port
#
EXPOSE 3000 3001 3002 3003

# Execute the run script in foreground mode
ENTRYPOINT ["/entrypoint.sh"]
CMD ["asd"]
