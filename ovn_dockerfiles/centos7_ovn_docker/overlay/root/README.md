# OVN docker setup for automation development and testing

Congratulations!!!!  You made it!!!!

This container provides an automation development and testing environment for automation engineer to
write and test ansible deployment scripts.

Here you will find two docker specific files `docker-compose.yml` and `cleanup.sh` to launch and cleanup
docker containers that simulate an OVN node.  You can edit `docker-compose.yml` to create and launch as many
machines you desire.  The number of machines you can launch are only limited by your host machine resources.

Here you will find the ansible `inventories` directory that mirrors `ovn_infrastructure` repository inventory
structure.  This structure follows the [ansible best practices inventory organization](http://docs.ansible.com/ansible/playbooks_best_practices.html#alternative-directory-layout).

All ansible variables should be defined inside the `vars.yml` file in each respective datacenter `group_vars/all` directory.
The `group_vars` directory is ansible standard and the `all` subdirectory represents the ansible `all` group.
Ansible recognizes all variable definiions that are defined inside the `vars.yml` file under the `all` group.

## How to run an ansible-plabook

First launch the VMs with `docker-compose`:

```bash
docker-compose up -d
```

You can edit the `docker-compose.yml` to add or remove VMs as needed.  After you add or remove VMs from the
`docker-compose.yml` file, just update the respective inventories file under the `inventories` directory.

You can run the playbook from the command line againt the dc1 datacenter target nodes by entering the command below.
You will need to subsititude appropriate values for the angled `<>` variables.  You can run the same playbook for dc2
datacenter by passing `/root/inventories/dc2` inventory file.

```bash
ansible-playbook <playbook> -i /root/inventories/dc1 -u root --private-key <ovn dev root ssh key>
```

Please run the `cleanup.sh` script to stop all containers launched with `docker-compose` before you exit your session.
