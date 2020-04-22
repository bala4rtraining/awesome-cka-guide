CREATE KEYSPACE IF NOT EXISTS ovn_dev1
	WITH REPLICATION = {
		'class' : 'SimpleStrategy',
		'replication_factor' : 1
};
DESCRIBE KEYSPACES;