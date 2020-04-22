#!/bin/bash

# Start zookeeper
./bin/zookeeper-server-start.sh config/zookeeper.properties &

# Wait for zookeeper to come up
sleep 15;

# Start kafka
./bin/kafka-server-start.sh config/server.properties &

# Wait for kafka to start
sleep 20;

# Creating topics
./init.sh &

# Keep container running
sleep infinity;
