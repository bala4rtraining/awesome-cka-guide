graphite-beacon
=========

This role installs and starts graphite-beacon monitor for the OVN DEV environment.

  - Python is upgraded to the latest version, and setuptools RPM is added on top. 
  - Pip install is performed on the pre-requisites and the graphite-beacon tarball.
  - the latest OVN_alerts graphite-beacon config is loaded from a ovn_alerts REPO tarball release (OVNGIT) 

Requirements
------------
The RPM(s) and the python package tarballs are currently stored in artifactory; when updating the latest RPM or tarball, update
the name in the defaults/main.yml.  

Role Variables
--------------


| var           |default                        | Description
|---------------|-------------------------------|----------
| gb_email      |  `ryeung@visa.com`              | the email address to which alerts are sent -> sets initial value in graphite-beacon configuration file.
| graphite_url  |  `http://ovndev/graphite`       | The URL of the graphite instance carrying the metrics -> also goes into the graphite-beacon config.
| smtp_mailhost |  `internet1.visa.com`           | The smtp server which will forward the outgoing alert e-mails

Dependencies
------------
- Python
- graphite(accessible over http from the graphite-beacon server)
- access to smtp server over TCPIP 


Example Playbook
----------------

    - hosts: gb_server
      roles:
         - graphite_beacon

License
-------

see opensource in repository [graphite-beacon](https://stash.trusted.visa.com:7990/projects/OVNHUB/repos/graphite-beacon/browse)



Author Information
------------------

Robert Yeung (ryeung@visa.com)