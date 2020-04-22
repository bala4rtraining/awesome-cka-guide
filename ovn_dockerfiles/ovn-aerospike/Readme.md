
This is the docker file for an aerospike database instance. It is a single node that will open all ports on localhost.

The default docker setup uses the internal filesystem for logging etc. and is memory resident.

Should it be necessary to have an instance that does not work in this manner, i.e. one that persists data to your local mac drive the the configuration aerospike_local.conf can be used as follows

docker run -d  -v /opt/shared/aerospike:/opt/shared/aerospike --name as -p 3000:3000 -p 3001:3001 -p 3002:3002 -p 3003:3003 ovn-dev  asd --config-file /opt/shared/aerospike/etc/aerospike.conf


You will need to create a directory structure 

/opt/shared/aerospike with the following directories

bin/
data/
etc/
log/
run/

and from you docker admin you will need to file sharing to /opt/shared

of course you can change this directory should you wish but that will necessitate changes to the aerospike config file

A simple telnet session shoudl help confirm that docker is running correctly

telnet localhost 3003

wiat for prompt and enter

namespaces

The terminal should report 

ovn-dev

as the only configured namespace





