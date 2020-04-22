# Aerospike Server Dockerfile

FROM ovn-docker.artifactory.trusted.visa.com/centos7_aerospike:stable4.8.0.8_1

# Add the Aerospike configuration specific to this dockerfile
RUN mkdir -p /etc/aerospike 
RUN mkdir -p /var/log/aerospike
COPY aerospike.template.conf /etc/aerospike/aerospike.template.conf
COPY entrypoint.sh /entrypoint.sh
RUN touch /var/log/aerospike/aerospike.log /var/run/aerospike/asd.pid
RUN chmod 777 /entrypoint.sh /usr/bin/asd
RUN chmod -R 777 /etc/aerospike /usr/bin/asd /opt/aerospike /var/log/aerospike /var/run/aerospike

EXPOSE 3000 3003

# Execute the run script in foreground mode
ENTRYPOINT ["/entrypoint.sh"]
#CMD ["asd"]