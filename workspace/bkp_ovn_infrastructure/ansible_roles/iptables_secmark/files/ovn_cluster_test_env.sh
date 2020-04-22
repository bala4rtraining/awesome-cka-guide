#!/bin/bash

cd /tmp
make -f /usr/share/selinux/devel/Makefile ovn_cluster_test.pp

DIR=$(pwd)
echo ${DIR}

semodule -i /tmp/ovn_cluster_test.pp
