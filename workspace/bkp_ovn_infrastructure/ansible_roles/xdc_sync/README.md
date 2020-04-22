xdc_sync
=======

*xdc_sync* ansible playbook is responsible for deploying `ovn_clearing_xdc_sync` package on datanodes.

Requirements
-----
* RHEL 7
* Download `tgz` from OVN Artifactory

Variables
----

| var                             |  default            | desc                                                 |
|---------------------------------|---------------------|------------------------------------------------------|
| xdc_sync_version                | 0.3.12-rc2          | version to be deployed                               |
| xdc_sync_src_namenodes          | []                  | namenodes addresses of source cluster                |
| xdc_sync_dest_namenodes         | []                  | namenodes addresses of destination cluster           |
| xdc_sync_kafka                  | []                  | kafka broker addresses                               |
| xdc_sync_riak                   | []                  | riak node addresses                                  |
| xdc_sync_bucket_type            | ovn_clearing        | riak bucket type used for riak events                |
| xdc_sync_bucket_name            | XdcHdfsEventBucket  | riak bucket name used for hdfs event                 |
| xdc_sync_kakfa_topic            | ovn_xdc_state_kh2   | kafka event topic name                               |
| xdc_sync_kafka_groupId          | xdc_clearing_jobs   | kafka event group id                                 |     

Dependencies:
------
* None

Example Playbook
------

```
  - hosts: hadoop_datanodes
    roles:
       - xdc_sync
```

References
----
[stash.trusted.visa.com:7990/projects/OP/repos/ovn_clearing_xdc_sync/browse](!stash.trusted.visa.com:7990/projects/OP/repos/ovn_clearing_xdc_sync/browse)

Author
------
* Mukesh Sharma <mmukesh@visa.com>