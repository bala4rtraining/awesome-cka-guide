elastalert
=========

This role installs and starts elastalert for the OVN DEV environment.


Requirements
------------
The RPM(s) and the python package tarballs are currently stored in artifactory; when updating the latest RPM or tarball, update
the name in the defaults/main.yml.

The Netcool plugin for elastalert is currently patched on to the source code of elastalert. When upgrading to new version of elastalert, the templates are required to changed accordingly


Role dispatch modes
-------------------

| dispatch names          | description                                   |
|-------------------------|-----------------------------------------------|
| provision_elastalert    | To provision elastalert with the given config |
| deploy_elastalert_rules | To deploy the elastalert rules                |



Role Variables
--------------

| var                             | default                                |  Description                                                                               |
|---------------------------------|----------------------------------------|--------------------------------------------------------------------------------------------|
| artifactory_url            |  "https://artifactory.trusted.visa.com" | OVN artifactory link                                                                       |
| elastalert_config_use_ssl       |  False                                 | Set to 'True' if the SSL is set                                                            |
| elasticsearch_host              |                                        | Hostname for the URL of elasticsearch                                                      |
| elasticsearch_port              | 9200                                   | Port for the URL of elasticsearch                                                          |
| elastalert_config_es_url_prefix |  elasticsearch                         | used when remote proxy has a URL prefix                                                    |
| elastalert_smtp_server          |  "corpportal.visa.com:25"              | SMTP server to send alert mails                                                            |
| elastalert_emailaddr            |  ovnalerts@visa.com                    | # this E-mail address goes into the default initial rules file                             |
| elastalert_config_dir           |  /var/lib/elastalert                   | location of the config files and rules directory                                           |
| Netcool_region                  |  CONSOLE                               |    string used for Netcool 'Region' e.g. CONSOLE/SUPPRESS                                  |
| OVN_AHA                         |  Open_VisaNet-1                        |   Default AHA code assigned for all Netcool:  'OriginType'                                 |
| Netcool_email                   |  EmailNetcoolQA@visa.com               |   This is the Netcool Email ID, For QA EmailNetcoolQA@visa.com and for Production Netcoolemail@visa.com                                                    |
| Netcool_DestinationConsole      |  Opensystems                           |  Opensystems/Network -Netcool bucket name                                                  |
| elastalert_env                  |  "DEV-DC1"                             | string inserted in Freetext field of email for netcool , and into SMTP e-mail from address |



Dependencies
------------
- Python,
- elasticsearch server accessible over http/https from elastalert server
- access to a SMTP relayhost over TCPIP


Example Playbook
----------------


          - hosts: elastalert
            roles:
              - { role: elastalert, dispatch: ['provision_elastalert', 'deploy_elastalert_rules']}
License
-------
Apache 2.0 license, See [Elastalert on OVNHUB](https://stash.trusted.visa.com:7990/projects/OVNHUB/repos/elastalert/browse/README.md)



Author Information
------------------

Robert Yeung (ryeung@visa.com)
Sachinrao Panemangalore ( spaneman@visa.com)
Rupesh Kumar (rupekuma@visa.com)
