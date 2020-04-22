#!/bin/bash

# Configure Cassandra with current host details
./cass_conf.sh

# Start Cassandra
./bin/cassandra -fR &

# Wait for cassandra to start
sleep 20;

# Creating keyspace and other cassandra initialization
./bin/cqlsh -f /tmp/cassandra/schema.txt &

# Keep container running
sleep infinity;