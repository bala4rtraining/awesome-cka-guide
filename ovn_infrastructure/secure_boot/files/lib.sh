#!/bin/bash
#

CERT_NAME=visa_db

prepare_cert() {

  certdb=$(mktemp -p $PWD -d)
  certname=$CERT_NAME

  certutil -d $certdb --empty-password -N
  pk12util -d $certdb -k <(echo "$KEY_PASS") -w <(echo "$KEY_PASS") -i keys/uefi_db.key.p12

  trap 'rm -rf $certdb' EXIT
}

grub_sign() {

  rm -f "$1".sig
  gpg2 --secret-keyring keys/grub_gpg.sec --keyring keys/grub_gpg.pub --passphrase-file <(echo "$KEY_PASS") --batch --detach-sign "$1"
}
