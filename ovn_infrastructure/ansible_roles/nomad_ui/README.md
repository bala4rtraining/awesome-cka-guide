Nomad UI
=========
This role installs and starts nomad_ui in the OVN environment.

Requirements
------------
Nomad server should be running before attempting to start nomad_ui

Role Variables
--------------

| var                         |  default                       | desc
|-----------------------------|--------------------------------|-----------------------------------------|
| nomad_ui_nomad_address      |  http://localhost:8443         | nomad server address                    |
| nomad_ui_port               |  3000                          | nomad ui server port                    |
| nomad_ui_tarball            |  hashi_ui-v0.13.6.tar.gz       | nomad ui package present in artifactory |


For more details, refer [defaults/main.yml](defaults/main.yml) or below playbook for sample usage.

Dependencies
------------
None.

Example Playbook
----------------
```
- name: Deploy and run nomad_ui
  role: nomad_ui
  vars:
    - nomad_ui_nomad_address: http://sl73ovnapd070:4646
```

License
-------
N/A

References
-------
[https://github.com/jippi/hashi-ui](!https://github.com/jippi/hashi-ui)


Author Information
------------------
sthimmap@visa.com
