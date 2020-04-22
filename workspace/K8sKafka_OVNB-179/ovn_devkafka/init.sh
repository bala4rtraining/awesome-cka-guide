#while IFS= read -r line
#do
  bin/kafka-topics.sh --create --zookeeper localhost:2181 --topic sample --partitions 1 --replication-factor 1
#done 
#mv /opt/app/jenkins/workspace/OVN/OVN_dev/kafkacontainer/topics.txt /opt/app/jenkins/workspace/OVN/OVN_dev/topics.txt
#touch /opt/app/jenkins/workspace/OVN/OVN_dev/kafkacontainer/topics.txt
