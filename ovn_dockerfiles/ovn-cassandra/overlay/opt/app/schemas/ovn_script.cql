CREATE KEYSPACE IF NOT EXISTS "OVN_TLC_KEYSPACE" WITH REPLICATION = { 'class' : 'SimpleStrategy', 'replication_factor' : 1};
USE "OVN_TLC_KEYSPACE";
CREATE TABLE "TLC_TABLE" ( key text, value text, PRIMARY KEY(key));

