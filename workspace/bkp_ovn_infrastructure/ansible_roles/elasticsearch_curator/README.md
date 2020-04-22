elasticsearch_curator
=========

This role installs elastic search curator and creates a cron jon which will periodically remove the elasticsearch indexes.
The indices are deleted if they meet both the criteria:
1. Older than N days (For index type present in curator_log_patterns, 
   N = curator_log_patterns[index]; for others N = curator_default_retention_period )
2. Not recently used in last K days ( K = curator_default_retention_period)

N is configurable based on index patterns.
N can be configured by adding a key value pair in curator_log_patterns (key=index, value=retention_period)
For example,
To retain syslog indices for 90 days, elasticsearch indices for 90 days 
curator_log_patterns: {"syslog-*" : 90, "elasticsearch-*" : 90}

To set curator log patterns for specific environment, you can set curator_log_patterns: {} in inventory specific vars file and remove from local defaults file.

Note: If we enable mutual SSL in elasticsearch, we might have to change curator config settings.
Requirements
------------
The RPM for curator is currently stored in artifactory @ https://artifactory.trusted.visa.com/ovn-extra-el7/elasticsearch-curator-5.1.1-1.x86_64.rpm

Role Variables
--------------

|            Variable           		| Default value |                    Description                    		 	|
|:-------------------------------------:|:-------------:|:-------------------------------------------------------------:|
| elasticsearch_port            		|      9200     |          			Port on which elasticsearch will be running |
| curator_default_retention_period      |      60       | 	Default days for which elastic search indices will be stored|
| curator_log_patterns					|      {}       |      key value pair of index regex and their retention period |

Author Information
------------------

Ashish Kankaria (akankari@visa.com)

License
-------

N/A

References
----------

1. https://www.elastic.co/guide/en/elasticsearch/client/curator/5.1/index.html
