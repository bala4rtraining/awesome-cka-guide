Bro
=========

This role installs and starts standalone bro.

Example Playbook
----------------

    - hosts: sdnlab-133
      vars:
      - cluster: true
      - iface: eth0, eno1
      roles:
      - bro
  

> ansible-playbook -i sdnlab-133, bro_play.yml