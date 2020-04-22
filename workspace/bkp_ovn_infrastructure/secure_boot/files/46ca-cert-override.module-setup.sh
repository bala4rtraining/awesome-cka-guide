#!/bin/bash
# module-setup for ca-cert-override

install() {

    rm -f ${initdir}/etc/pki/ca-trust/extracted/pem/tls-ca-bundle.pem
    inst_simple keys/inst_https.crt /etc/pki/ca-trust/extracted/pem/tls-ca-bundle.pem
}
