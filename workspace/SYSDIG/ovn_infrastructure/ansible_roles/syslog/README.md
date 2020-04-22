syslog
=========

This role sets up the small amount of items required to serve up logs to the elasticsearch interface.
To make it easier for elasticsearch the output is based on logstash formatting. 
The rsyslog plugin module called omelasticsearch does most of the work.


Requirements
------------
rsyslog


Role Variables
--------------

N/A


Dependencies
------------
Elasticsearch remote server (target for the output items in a stream over TCP)


Example Playbook
----------------

    - hosts: servers
      roles:
         - syslog


License
-------

N/A

Author Information
------------------

Robert Yeung  (ryeung@visa.com)