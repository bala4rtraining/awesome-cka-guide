#/bin/bash
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

echo "env is $ENVIRONMENT"
echo "servers are $zookeeper_servers"
echo "Partitions are ${PARTITIONS}"
echo "Replication factor is ${REPLICATION_FACTOR}"
echo "i is ${i}"


for i in $(echo ${TOPIC_NAME} | sed "s/,/ /g")
do
     echo "creating topic ${i}"
    ./kafka-topics.sh --create --zookeeper $zookeeper_servers --topic ${i} --partitions ${PARTITIONS} --replication-factor ${REPLICATION_FACTOR}
done

echo "All the topics are Created"


for i in $(echo ${TOPIC_NAME} | sed "s/,/ /g")
do
    ./kafka-topics.sh --describe --zookeeper $zookeeper_servers --topic ${i}
    
done
