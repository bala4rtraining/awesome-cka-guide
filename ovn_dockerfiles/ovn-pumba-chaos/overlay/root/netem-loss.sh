#!/bin/bash
pumba netem --duration 5m loss --percent 2 kerberosserver-dc1-0 \
& pumba netem --duration 5m loss --percent 2 kerberosserver-dc2-0 \
& pumba netem --duration 5m loss --percent 2 zookeeper-dc1-0 \
& pumba netem --duration 5m loss --percent 2 zookeeper-dc1-1 \
& pumba netem --duration 5m loss --percent 2 zookeeper-dc1-2 \
& pumba netem --duration 5m loss --percent 2 zookeeper-dc2-0 \
& pumba netem --duration 5m loss --percent 2 zookeeper-dc2-1 \
& pumba netem --duration 5m loss --percent 2 zookeeper-dc2-2 \
& pumba netem --duration 5m loss --percent 2 kafka-dc1-0 \
& pumba netem --duration 5m loss --percent 2 kafka-dc1-1 \
& pumba netem --duration 5m loss --percent 2 kafka-dc1-2 \
& pumba netem --duration 5m loss --percent 2 kafka-dc2-0 \
& pumba netem --duration 5m loss --percent 2 kafka-dc2-1 \
& pumba netem --duration 5m loss --percent 2 kafka-dc2-2 \
& pumba netem --duration 5m loss --percent 2 riak-dc1-0 \
& pumba netem --duration 5m loss --percent 2 riak-dc2-0 \
& pumba netem --duration 5m loss --percent 2 ovnmediator-dc1-0 \
& pumba netem --duration 5m loss --percent 2 ovnmediator-dc2-0 \
& pumba netem --duration 5m loss --percent 2 ovnswitch-dc1-0 \
& pumba netem --duration 5m loss --percent 2 ovnswitch-dc2-0 \
& pumba netem --duration 5m loss --percent 2 multidcsync-dc1-0 \
& pumba netem --duration 5m loss --percent 2 multidcsync-dc2-0 \
& pumba netem --duration 5m loss --percent 2 vitalsignsdelivery-dc1-0 \
& pumba netem --duration 5m loss --percent 2 vitalsignsdelivery-dc2-0 \
& pumba netem --duration 5m loss --percent 2 umfdelivery-dc1-0 \
& pumba netem --duration 5m loss --percent 2 umfdelivery-dc2-0 \
& pumba netem --duration 5m loss --percent 2 ftps-dc1-0 \
& pumba netem --duration 5m loss --percent 2 ftps-dc2-0 \
& pumba netem --duration 5m loss --percent 2 umfbroker-dc1-0 \
& pumba netem --duration 5m loss --percent 2 umfbroker-dc2-0