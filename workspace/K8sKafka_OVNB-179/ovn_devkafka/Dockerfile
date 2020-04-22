FROM nonprod.registry.trusted.visa.com/oi-0024789/jdk18rhel7:jdk18rhel7-development_1

RUN curl -o kafka_2.11-0.11.0.1.tgz https://artifactory.trusted.visa.com/ovn/repo/kafka_2.11-0.11.0.1.tgz --insecure
RUN tar -xzf kafka_2.11-0.11.0.1.tgz
RUN mv kafka_2.11-0.11.0.1 kafka

WORKDIR kafka

RUN sed -i 's|'#listeners=PLAINTEXT://:9092'|'listeners=PLAINTEXT://0.0.0.0:9092'|g' config/server.properties
RUN sed -i 's|'#advertised.listeners=PLAINTEXT://your.host.name:9092'|'advertised.listeners=PLAINTEXT://kafka:9092'|g' config/server.properties

COPY start.sh .
COPY init.sh .

# Commenting since we need to upload this as config file
#COPY topics.txt .

RUN chmod +x start.sh init.sh
ENTRYPOINT [ "./start.sh" ]
EXPOSE 9092