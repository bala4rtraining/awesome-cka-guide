# Description

These files are Ansible scripts to be run on an OGL machine.
They will be copied to the OGL machine by the tasks of this role.

The Ansible scripts in this directoy configures a 2spine-3leaf
topology formed by Cumulus switches. This topology is defined
by variables in the **group_vars/main.yml**. They are used by
the templates in the role **leafs** and **spines**. So in the future we
only need to update the group variables when new switching capabilities are
added.


For an overview of OVN infrastructure topology, please refer to [OVN Topology](https://stash.trusted.visa.com:7990/projects/OP/repos/ovn_docs/browse/process/infrastructure/networking/ovn_networking_topo_3racks.md)
