CREATE ROLE IF NOT EXISTS ovn_appuser_dev1 WITH PASSWORD = 'ovn_elrond@appuser_dev1' AND LOGIN = true;
GRANT SELECT ON KEYSPACE ovn_dev1 TO ovn_appuser_dev1;
GRANT MODIFY ON KEYSPACE ovn_dev1 TO ovn_appuser_dev1;
GRANT EXECUTE ON ALL FUNCTIONS IN KEYSPACE ovn_dev1 TO ovn_appuser_dev1;
LIST ALL PERMISSIONS OF ovn_appuser_dev1;
