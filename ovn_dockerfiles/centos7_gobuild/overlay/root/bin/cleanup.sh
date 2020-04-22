#!/bin/bash
docker ps -f ancestor=ovn-docker.artifactory.trusted.visa.com/centos7_ovn_docker | grep '/usr/sbin/init' | awk '{print $1}' | xargs docker stop | xargs docker rm
docker ps -f ancestor=ovn-docker.artifactory.trusted.visa.com/centos7_vault -q | xargs docker stop | xargs docker rm
