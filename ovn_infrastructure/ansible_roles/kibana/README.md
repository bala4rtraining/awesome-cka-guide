kibana
=========

This role sets up nginx to serve up the Kibana application/interface.
Installs from a previously saved tarball. The configuration files for the kibana service
is in the templates directory. 


Requirements
------------
The tar.gz files for kibana is stored in OVN-git. When the version needs updating, 
the new files will need to be downloaded and stored, and the defaults file updated.


Role Variables
--------------

elasticsearch_host -  fqdn or IP address of the main elasticsearch host kibana will drive queries to.  
elasticsearch_port -  Port for Kibana to communicate with elasticsearch
kibana_png         -  the filename of the png file that replaces standard kibana for the dashboard display
                      (the png file should be stored in the files directory of the kibana role)
kibana_old_version -  the version of kibana to remove .

Dependencies
------------
Elasticsearch (remote server acccessible over http)


Example Playbook
----------------

    - hosts: servers
      roles:
         - kibana


License
-------

N/A

Author Information
------------------

Nathan Aschbacher (naschbac@visa.com)
Robert Yeung  (ryeung@visa.com)