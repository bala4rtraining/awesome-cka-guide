docker build -t "aerospike/aerospike-server" .
for i in {1..2} ; do
echo $i;
docker stop aerospike${i}
docker rm aerospike${i}
docker run -tid --name aerospike${i} -p ${i}000:3000 -p ${i}001:3001 -p ${i}002:3002 -p ${i}003:3003 aerospike/aerospike-server
done;
