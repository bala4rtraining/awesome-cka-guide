#!/bin/bash +x
wget -q https://artifactory.trusted.visa.com/ovn/repo/kafka_2.11-0.11.0.1.tgz --no-check-certificate
tar -xzf kafka_2.11-0.11.0.1.tgz 2>/dev/null
cd kafka_2.11-0.11.0.1/bin
