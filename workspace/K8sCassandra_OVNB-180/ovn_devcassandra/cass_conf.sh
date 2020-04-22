#!/bin/bash

sed -i "s/__cassandra_seeds__/$HOSTNAME/g" /cassandra/conf/cassandra.yaml
sed -i "s/__cassandra__/$HOSTNAME/g" /cassandra/conf/cassandra.yaml