#!/bin/bash
set -e

export CORES=$(grep -c ^processor /proc/cpuinfo)
export SERVICE_THREADS=${SERVICE_THREADS:-$CORES}
export TRANSACTION_QUEUES=${TRANSACTION_QUEUES:-$CORES}
export TRANSACTION_THREADS_PER_QUEUE=${TRANSACTION_THREADS_PER_QUEUE:-4}
export LOGFILE=${LOGFILE:-/dev/null}
export SERVICE_ADDRESS=${SERVICE_ADDRESS:-any}
export SERVICE_PORT=${SERVICE_PORT:-3000}
export HB_ADDRESS=${HB_ADDRESS:-any}
export HB_PORT=${HB_PORT:-3002}
export FABRIC_ADDRESS=${FABRIC_ADDRESS:-any}
export FABRIC_PORT=${FABRIC_PORT:-3001}
export INFO_ADDRESS=${INFO_ADDRESS:-any}
export INFO_PORT=${INFO_PORT:-3003}
#namespace ovn_devintegration
#export NAMESPACE=${NAMESPACE:-ovn_devintegration}
export REPL_FACTOR=${REPL_FACTOR:-1}
export MEM_GB=${MEM_GB:-1}
export DEFAULT_TTL=${DEFAULT_TTL:-14d}
export STORAGE_GB=${STORAGE_GB:-1}

# Fill out conffile with above values
/usr/bin/envsubst < /etc/aerospike/aerospike.template.conf > /etc/aerospike/aerospike.conf

cd /usr/bin 
./asd

aql --file=/conf/schema.txt

# keep the container running
sleep infinity;