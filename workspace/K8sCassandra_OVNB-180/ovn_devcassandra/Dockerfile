FROM nonprod.registry.trusted.visa.com/oi-0024789/jdk18rhel7:jdk18rhel7-development_1

RUN curl -o cassandra.tar https://artifactory.trusted.visa.com/ovn-extra-el7/apache-cassandra-3.11.4.tar --insecure
RUN tar --warning=no-unknown-keyword -zxf cassandra.tar
#RUN mv apache-cassandra-3.11.4 cassandra
COPY ./cass_conf.sh cassandra/
COPY ./start.sh cassandra/
COPY ./schema.txt cassandra/

WORKDIR cassandra
RUN chmod +x start.sh
RUN chmod +x cass_conf.sh
RUN chmod +x schema.txt

RUN mkdir logs
RUN touch logs/gc.log
RUN chmod -R 777 .

RUN sed -i 's|'#-XX:ParallelGCThreads=16'|'-XX:ParallelGCThreads=2'|g' conf/jvm.options
RUN sed -i 's/#-Xms4G/-Xms512M/g' conf/jvm.options
RUN sed -i 's/#-Xmx4G/-Xmx512M/g' conf/jvm.options

RUN sed -i 's/#MAX_HEAP_SIZE="4G"/MAX_HEAP_SIZE="512M"/g' conf/cassandra-env.sh
RUN sed -i 's/#HEAP_NEWSIZE="800M"/HEAP_NEWSIZE="512M"/g' conf/cassandra-env.sh
RUN echo "JVM_OPTS=\"\$JVM_OPTS -Dcassandra.initial_token=0\"" >> conf/cassandra-env.sh
RUN echo "JVM_OPTS=\"\$JVM_OPTS -Dcassandra.skip_wait_for_gossip_to_settle=0\"" >> conf/cassandra-env.sh


RUN sed -i -e "s/num_tokens/\#num_tokens/" conf/cassandra.yaml
RUN sed -i -e "s/\# initial_token:/initial_token: 0/" conf/cassandra.yaml
RUN sed -i 's/rpc_address: localhost/rpc_address: 0.0.0.0/g' conf/cassandra.yaml

ENTRYPOINT [ "./start.sh" ]
EXPOSE 9042
