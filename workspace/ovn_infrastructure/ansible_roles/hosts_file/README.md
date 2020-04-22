# Ansible role to generate /etc/hosts file from the inventory

The role generates /etc/hosts file from the inventory and updates the /etc/nsswitch.conf
to lookup host ip address from the /etc/hosts file and then the DNS lookup if the host
is not present in the /etc/hosts file.

The calling book must include this in the playbook to gather all facts about to generate the /etc/hosts file.

```yaml
- hosts: target_inventory
  gather_facts: yes
```