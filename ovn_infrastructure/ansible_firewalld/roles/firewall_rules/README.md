# Using Firewalld Rich Rules to Secure OVN Servers

This ansible role uses a simple ansible YAML data structure named `firewall_rules` to generate and configure
firewalld rules on the OVN servers.

The `firewall_rules` data structure is defined as

```yaml
firewall_rules:
- src:          # (optional) List of source IP addresses and/or networks.
  state:        # (optional) `enabled` (default) or `disabled`.
  dest:         # (required) List of destination IP addresses.
  ports:        # (required) List of ports to be opened for access from the `src`
  - port:       # (optional) Port or range of ip ports
    protocol:   # (optional) `tcp` (default) or `ucp`
```

## Some examples

Limit `ssh` access to all hosts in the ansible inventory from the `VMSN` network.

```yaml
firewall_rules:
- src:  "10.184.254.0/24"
  dest: "{{ groups.all }}"
  ports:
  - port: 22
```

Remove the above restriction.

```yaml
firewall_rules:
- src:  "10.184.254.0/24"
  state: "disabled"
  dest: "{{ groups.all }}"
  ports:
  - port: 22
```

Limit access to `tcp` port `9100` from just the `haproxy` on the `mediators` servers.

```yaml
firewall_rules:
- src:  "{{ groups.haproxy }}"
  dest: "{{ groups.ovn_mediator_servers }}"
  ports:
  - port: "9100"
```
