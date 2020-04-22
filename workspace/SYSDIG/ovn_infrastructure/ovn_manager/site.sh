#!/usr/bin/env bash
#

set -e

ENV=test
# Also available: cert, test, occ-aa

OTHER_ENV=occ-aa

decrypt_key() {

  ansible all -i localhost, --connection=local \
    -e @$ROOT/config/$ENV.vars.secret.yml \
    --vault-password-file=~/.vault-$ENV \
    -m copy -a "content={{private_key}} dest=$ROOT/config/$ENV.root_key mode=0600"
}

run() {

  PARAMS="-i $ROOT/config/$ENV.inventory -u root --private-key=$ROOT/config/$ENV.root_key --extra-vars @$ROOT/config/$ENV.vars.yml"

  [ -e "$ROOT/config/$ENV.vars.secret.yml" -a -e ~/.vault-$ENV ] && PARAMS="$PARAMS --extra-vars @$ROOT/config/$ENV.vars.secret.yml --vault-password-file=~/.vault-$ENV"

  [ -n "$OTHER_ENV" -a -e "/tmp/vars_about_$OTHER_ENV.yml" ] && PARAMS="$PARAMS --extra-vars @/tmp/vars_about_$OTHER_ENV.yml"

  ansible-playbook $ROOT/$1 $PARAMS "${@:2}"  "${EXTRA_VARS[@]}"
}

other_dc_vars() {

  [ -z "$OTHER_ENV" ] && return

  rm -f /tmp/vars_about_$OTHER_ENV.yml

  local ENV=$OTHER_ENV
  run ansible_ovn/capture_vars_about_dc.yml --extra-vars "cluster_name=$OTHER_ENV"
}

ROOT=$(dirname $0)/..
EXTRA_VARS=("$@")

#decrypt_key

other_dc_vars

run ansible_riak/site.yml

run ansible_ovn/ha-proxy.yml

run ansible_ovn/heka.yml --extra-vars '{"deploy": false, "provision": true}'

run ansible_ovn/clean_state.yml
run ansible_zookeeper/site.yml
run ansible_kafka/site.yml
run ansible_ovn/deploy_profile.yml
run ansible_ovn/deploy_currency.yml
run ansible_ovn/site.yml
run ansible_ovn/vitalsigns.yml

#run ansible_ovn/provision.yml
#
#run ansible_ovn/umf_broker.yml
