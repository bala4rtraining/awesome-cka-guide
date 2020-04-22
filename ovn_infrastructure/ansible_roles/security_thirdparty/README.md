security_thirdparty role
===========================

This role deploys third party security products tanium and tripwire.

Pre-requisites:
-----------------

Tanium and tripwire latest Visa verified binaries to be present in artifactory path:
https://artifactory.trusted.visa.com/seceng

Role Variables
--------------

| var                             |  default   | desc
|:-------------------------------:|:----------:|:---------------------------------------------------:|
| tripwire_server_port            |  9898      | Tripwire TCP/IP listener                            |
| tripwire_rtm_port               |  1169      |           |
| tripwire_server_host            |  sl75tripapd001.visa.com    | Tripwire server.  This will vary per environment |
| tripwire_passphrase_to_use      |  tripw1re  | Login password(default password is for dev)         |
| tripwire_uninstall_cmd          |  opt/security/tripwire/te/agent/bin/uninstall.sh    | If rpm use yum remove, else run the default command    |
| tripwire_service_name           | twdaemon | tripwire agent daemon name                          |
| tripwire_install_dir            | /opt/security/tripwire/te/agent/ | Installation path for tripwire agent |
| tripwire_download_dir           | /tmp/tripwire | Download path for tripwire agent | 
| tripwire_tgz_file_name          | te_agent_8.5.5_en_linux_x86_64.tgz | Last stable Visa verified tripwire agent.  Reach out to security tools team to get latest one. |
| tripwire_artifact_url           | https://artifactory.trusted.visa.com/seceng/{{ tripwire_tgz_file_name }} | Artifactory url to download files |
| tanium_download_dir           | /tmp/tanium | Download path for tanium agent |
| tanium_rpm           | TaniumClient | RPM name for tanium client |
| tanium_tgz_file_name           | tanium-agent.rhel7.tgz | Tarball tanium client |
| tanium_artifact_url           | https://artifactory.trusted.visa.com/seceng/{{ tanium_tgz_file_name }} | Artifactory url for tanium.  Reach out to security tools team to get latest one |
| tanium_service_name           | taniumclient | Tanium service name |


Tripwire dispatch task:
-------------------------
1. Fetch te_agent_8.5.5_en_linux_x86_64.tgz from artifactory url
2. Untar the tarball
3. Stop and uninstall tripwire service if it already exists
4. Run the tripwire agent

Tanium dispatch task:
-----------------------
1. Fetch tanium-agent.rhel7.tgz from artifactory url
2. Untar the tarball
3. Stop and uninstall tanium service if it already exists
4. Run the taanium service


Example Playbook
----------------

```
---
- name: start deploying third party products tanium and tripwire
  hosts: all,!cumulus_switch,!ovn_manager
  roles:
    - { role: security_thirdparty, dispatch: ['tripwire'] }
    - { role: security_thirdparty, dispatch: ['tanium'] }
```

Run playbook:
--------------

```
ansible-playbook -i <inventory-file> ansible_ovn/deploy_thirdparty_security_prod.yml
```

Author Information
------------------

raskrish@visa.com
mvaidyam@visa.com

