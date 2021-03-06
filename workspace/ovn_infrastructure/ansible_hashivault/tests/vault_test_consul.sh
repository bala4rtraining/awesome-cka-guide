#!/bin/bash

host=$(hostname -I | sed 's/^\([[:digit:]]\+\).\([[:digit:]]\+\).\([[:digit:]]\+\).\([[:digit:]]\+\) .*$/\1.\2.\3.\4/g')
export VAULT_ADDR="https://$host:8200"
export VAULT_SKIP_VERIFY=1
VAULTCLI="/usr/local/bin/vault"

$VAULTCLI mount consul
$VAULTCLI unmount consul
