# OVN firewall provisioning scripts

The ansible playbooks are played in certain order to generate the firewalld rules.
The scripts generate the rules in the native firewalld xml format.

Generating the firewall rules in this manner has major `performance` benefits over
the `firewalld` ansible module.
We can generate and deploy firewall rules in few minutes instead of hours it takes
with the `firewalld` ansible module.

## How to run the playbooks

Firewall processing is performed on the ansible control node (e.g. `localhost`) to produce the firewalld native `public.xml` zone ruleset.
Therefore the `localhost` must be supplied via the ansible `--limit` option.

The playbook is run one datacenter at a time. In production that is how the playbook is played.  The datacenter should usually be in quieced when these rules are run and client traffic routed to other datacenter while the firewall rules are applied to the target datacenter.

Note: There are ansible variables which have per datacenter specific values.
These vars by convention are in the .../<env>/dc[12]/group_vars/all/dc[12]*.yml ansible vars files.
Since we are targeting the inventory at the <env> level, we must aggreate these vars in a temporary file and pass that to the `ansible-playbook` as `--extra-vars`
parameter.

## First prepare east-west and north-south firewall rules for provisioning

The north-south rules have to operate on the aggregated hosts from the both datacenter.  The east-west rules on the other hand must operate on each datacenter separately.  This is the reason for the separate prepare step is required.

Note: There are ansible variables which have per datacenter specific values.
These vars by convention are in the .../<env>/dc[12]/group_vars/all/dc[12]*.yml ansible vars files.
Since we are targeting the inventory at the <env> level, we must aggreate these vars in a temporary file and pass that to the `ansible-playbook` as `--extra-vars`
parameter.

```bash
cd .../ovn_infrastructure

cat inventories/test/dc1/group_vars/all/dc1*.yml | grep -v '\---' > /tmp/dc1.vars.yml

ansible-playbook ansible_firewalld/prepare_east_west_firewall_rules.yml -i inventories/test/dc1 --extra-vars=@tmp/dc1.vars.yml

ansible-playbook ansible_firewalld/prepare_north_south_firewall_rules.yml -i inventories/test --extra-vars=@tmp/dc1.vars.yml
```

### Run provision_firewall_rules.yml playbook

```bash
cd .../ovn_infrastructure

# Run prepare east-west and north-south playbooks (see above)

chmod 600 config/id_dev

cat inventories/test/dc1/group_vars/all/dc1*.yml | grep -v '\---' > /tmp/dc1.vars.yml
ansible-playbook ansible_firewalld/provision_firewall_rules.yml -i inventories/test -u root --private-key config/id_dev --extra-vars=@tmp/dc1.vars.yml --limit dc1:localhost
```

- Repeat the above steps for the second datacenter `dc2`

```bash

...

cat inventories/test/dc2/group_vars/all/dc2*.yml | grep -v '\---' > /tmp/dc2.vars.yml
ansible-playbook ansible_firewalld/provision_firewall_rules.yml -i inventories/test -u root --private-key config/id_dev --extra-vars=@tmp/dc2.vars.yml --limit dc2:localhost
```

## Run print_firewall_rules_csv.yml playbook

```bash
...
cat inventories/test/dc1/group_vars/all/dc1*.yml | grep -v '\---' > /tmp/dc1.vars.yml

ansible-playbook ansible_firewalld/prepare_east_west_firewall_rules.yml -i inventories/test/dc1 --extra-vars=@tmp/dc1.vars.yml

ansible-playbook ansible_firewalld/prepare_north_south_firewall_rules.yml -i inventories/test --extra-vars=@tmp/dc1.vars.yml

ansible-playbook ansible_firewalld/print_firewall_rules_csv.yml -i inventories/test  --extra-vars=@tmp/dc1.vars.yml
```

- Repeat the above steps for the second datacenter `dc2`
