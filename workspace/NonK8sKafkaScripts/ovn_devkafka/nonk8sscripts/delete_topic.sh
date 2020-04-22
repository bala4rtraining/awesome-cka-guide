#!/bin/bash
cd kafka_2.11-0.11.0.1/bin

if [ "$ENVIRONMENT" == "DEV" ]
then
	zookeeper_servers="sl73ovnapd584:2181,sl73ovnapd585:2181,sl73ovnapd586:2181"
elif [ "$ENVIRONMENT" == "DEV1A" ]
then
	zookeeper_servers="sl73ovdbd032:2181,sl73ovdbd033:2181,sl73ovdbd034:2181/kafka-cluster"
elif [ "$ENVIRONMENT" == "DEV1B" ]
then
	zookeeper_servers="sl73ovdbd042:2181,sl73ovdbd043:2181,sl73ovdbd044:2181/kafka-cluster"

fi

for i in $(echo ${TOPIC_NAME} | sed "s/,/ /g")
do
    ./kafka-topics.sh --delete --zookeeper $zookeeper_servers --topic ${i}             
done
