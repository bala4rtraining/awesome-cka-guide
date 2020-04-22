#!/bin/bash

: ${CASSANDRA_RPC_ADDRESS='0.0.0.0'}

: ${CASSANDRA_LISTEN_ADDRESS='auto'}
if [ "$CASSANDRA_LISTEN_ADDRESS" = 'auto' ]; then
  CASSANDRA_LISTEN_ADDRESS="$(hostname --ip-address)"
fi

: ${CASSANDRA_BROADCAST_ADDRESS="$CASSANDRA_LISTEN_ADDRESS"}

if [ "$CASSANDRA_BROADCAST_ADDRESS" = 'auto' ]; then
  CASSANDRA_BROADCAST_ADDRESS="$(hostname --ip-address)"
fi
: ${CASSANDRA_BROADCAST_RPC_ADDRESS:=$CASSANDRA_BROADCAST_ADDRESS}

: ${CASSANDRA_SEEDS:="$CASSANDRA_BROADCAST_ADDRESS"}

sed -ri 's/(- seeds:).*/\1 "'"$CASSANDRA_SEEDS"'"/' "/etc/cassandra/conf/cassandra.yaml"

for yaml in \
  broadcast_address \
  broadcast_rpc_address \
  cluster_name \
  endpoint_snitch \
  listen_address \
  num_tokens \
  rpc_address \
  start_rpc \
; do
  var="CASSANDRA_${yaml^^}"
  val="${!var}"
  if [ "$val" ]; then
    sed -ri 's/^(# )?('"$yaml"':).*/\2 '"$val"'/' "/etc/cassandra/conf/cassandra.yaml"
  fi
done

for rackdc in dc rack; do
  var="CASSANDRA_${rackdc^^}"
  val="${!var}"
  if [ "$val" ]; then
    sed -ri 's/^('"$rackdc"'=).*/\1 '"$val"'/' "/etc/cassandra/conf/cassandra-rackdc.properties"
  fi
done

exec /usr/sbin/init
