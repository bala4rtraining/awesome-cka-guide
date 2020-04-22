# Single Inventory Per Site

This is the inventory model following the [Ansible best practices](http://docs.ansible.com/ansible/playbooks_best_practices.html#alternative-directory-layout).

The migration of inventory as per the `Ansible best practices` is implemented in this directory.

The inventory is structured as below.  The `<cluster>` represents various environments where we deploy OVN application components.

At the top level, there is a `group_vars/all` directory where all common config vars are defined by individual OVN logical components.  The `dc1` and `dc2` directories represent the pair of datacenters in the cluster.
Each datacenter has the `hosts` file containing the inventory for the respective datacenters `dc1` and `dc2`.

The common groups_vars are symlinked to each datacenter `dc?/group_vars/all` directory from the top level `group_vars/all` directory.  Datacenter specific config vars reside in the `dc?/group_vars/all` with datacenter prefix by convention `dc1` or `dc2`.

```bash
├── <cluster>
    └── dc1
    |   └── hosts
    │   ├── group_vars
    │       └── all
    └── dc2
    |   └── hosts
    │   ├── group_vars
    │       └── all
    └── group_vars
        └── all
```

The PERF and CERT clusters have a new directory with name `dc1_monitoring`. This directory is created for JIRA OVN-7783.
This folder has the `hosts` inventory file with hostnames instead of IP. hostnames are added to the file to enable SSL between OVN Monitoring components.