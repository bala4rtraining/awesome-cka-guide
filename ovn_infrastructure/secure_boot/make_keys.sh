#!/bin/bash
#

set -e

CERT_NAME=visa_db
PASS="$1"
UUID=a472f31a-f5b9-40fd-b9c5-3cf59398122d

[ -n "$PASS" ] || { echo pass is needed; exit; }

mkdir -p keys

[ -f keys/uefi_db.key.p12 ] || {

  pass=$1
  certname=$CERT_NAME

  rm -f keys/uefi_*

  for f in /etc/pki/tls/openssl.cnf /etc/ssl/openssl.cnf; do
    cp -f $f .openssl.conf && break
  done
  echo """
[ codesigning ]
keyUsage                = digitalSignature
extendedKeyUsage        = codeSigning
subjectKeyIdentifier    = hash
""" >> .openssl.conf

  openssl req -config .openssl.conf -extensions codesigning -new -x509 -newkey rsa:2048 -subj "/CN=db/" -keyout keys/uefi_db.key -out keys/uefi_db.crt -days 3650 -sha256 -passout file:<(echo "$PASS")
  openssl x509 -outform der -in keys/uefi_db.crt -out keys/uefi_db.cer
  openssl pkcs12 -export -inkey keys/uefi_db.key -in keys/uefi_db.crt -out keys/uefi_db.key.p12 -nodes -name $certname -passout file:<(echo "$PASS") -passin file:<(echo "$PASS")

  openssl req -new -x509 -newkey rsa:2048 -subj "/CN=PK/"  -keyout keys/uefi_PK.key  -out keys/uefi_PK.crt  -days 3650 -sha256 -passout file:<(echo "$PASS")
  openssl req -new -x509 -newkey rsa:2048 -subj "/CN=KEK/" -keyout keys/uefi_KEK.key -out keys/uefi_KEK.crt -days 3650 -sha256 -passout file:<(echo "$PASS")

  ln -sf /usr/lib64/libcrypto.so.1.0.1e libcrypto.so.1.0.0
  rpm2cpio files/efitools-1.5.3-1.1.x86_64.rpm |
  cpio -i --to-stdout ./usr/bin/cert-to-efi-sig-list > cert-to-efi-sig-list
  rpm2cpio files/efitools-1.5.3-1.1.x86_64.rpm |
  cpio -i --to-stdout ./usr/bin/sign-efi-sig-list > sign-efi-sig-list
  chmod +x cert-to-efi-sig-list sign-efi-sig-list
  LD_LIBRARY_PATH=. ./cert-to-efi-sig-list -g f5a96b31-dba0-4faa-a42a-7a0c9832768e keys/vendor_uefi_db_HP.crt keys/uefi_dbHP.esl
  LD_LIBRARY_PATH=. ./cert-to-efi-sig-list -g e6a9fe22-fa3f-43f0-99bb-f4bd10d6a3d5 keys/vendor_uefi_db_MS.crt keys/uefi_dbMS.esl
  LD_LIBRARY_PATH=. ./cert-to-efi-sig-list -g $UUID keys/uefi_db.crt keys/uefi_dbV.esl
  cat keys/uefi_db?*.esl > keys/uefi_db.esl
  rm  keys/uefi_db?*.esl
  LD_LIBRARY_PATH=. ./cert-to-efi-sig-list -g $UUID keys/uefi_PK.crt  keys/uefi_PK.esl
  LD_LIBRARY_PATH=. ./cert-to-efi-sig-list -g $UUID keys/uefi_KEK.crt keys/uefi_KEK.esl
  openssl rsa -in keys/uefi_PK.key -passin file:<(echo "$PASS") -out keys/uefi_PK.key.clear
  LD_LIBRARY_PATH=. ./sign-efi-sig-list -k keys/uefi_PK.key.clear -c keys/uefi_PK.crt PK keys/uefi_PK.esl keys/uefi_PK.auth
  rm -f libcrypto.so.1.0.0 cert-to-efi-sig-list sign-efi-sig-list keys/uefi_PK.key.clear

  rm -f .openssl.conf
}

[ -f keys/inst_https.key ] || {

  openssl req -new -x509 -subj "/CN=192.168.76.2/" -newkey rsa:2048 -keyout keys/inst_https.key -out keys/inst_https.crt -days 3650 -sha256 -nodes
}

[ -f keys/grub_gpg.pub ] || {


  gpg2  --passphrase-file <(echo "$PASS") --gen-key --batch <(echo """
%echo Generating a GPG key
Key-Type: DSA
Key-Length: 2048
Name-Real: Visa OVN
Name-Email: security@ovn.visa.com
Expire-Date: 0
Passphrase: $PASS
%pubring keys/grub_gpg.pub
%secring keys/grub_gpg.sec
%commit
%echo Done
""")

# gpg2 --import keys/grub_gpg.sec
}

