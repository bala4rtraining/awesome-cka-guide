while IFS= read -r line
do
  bin/kafka-topics.sh --create --zookeeper localhost:2181 --topic $line --partitions 1 --replication-factor 1
done < /tmp/kafka/topics.txt
