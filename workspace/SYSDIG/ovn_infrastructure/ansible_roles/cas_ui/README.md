CAS_UI
=======

This role installs cas_ui components on nodes in OVN environment. Optionally you can add nginx configuration to provide authentication support for cas_ui using nginx role. CAS_UI on its own wont provide any authentication. For authentication it will depend on our nginx authentication/authorization solution.

Requirements
------------
CAS_UI build in artifactory
CAS_Tools server location
Certificates(Optional)

Role Variables
--------------

|   Variable            |   Default Value   |   Description                             |
| :--------------------:|:-----------------:|:-----------------------------------------:|
|   cas_ui_http_port    |   7443            |   HTTP Port on which cas_ui will run      |
|   cas_ui_install_dir  |   /opt/app/cas_ui |   The installation directory for cas_ui   |

Dependencies
------------
CAS_Tools must be installed.

Example Playbook
----------------

```yml
---
- name:  deploy CAS_UI Server
  hosts: cas_ui
  gather_facts: yes
  roles:
    - cas_ui
```
License
-------
N/A

Author Information
------------------
Rohit More (rmore@visa.com)

Associated Playbooks
--------------------
For additional information on how to configure CAS_UI with nginx and authentication mechanism,
please refer to: ansible_ovn/deploy_cas_ui.yaml

References
----------
* https://stash.trusted.visa.com:7990/projects/OP/repos/ovn_cas_ui/browse
* https://visawiki/display/OVN/Clearing+Operations+-+Storyboard OVN Clearing Passthrough Storyboard and high level design
