Clearing Master Job
=========

This role deploys the ovn_cas_cli release binary on Nomad client machine and starts Clearing Master job.This job schedules the clearing jobs for all the clients using clearing profile in a datacenter. 


The following variables values should be set in defaults/main.yml

variable                  |default               |description
--------------------------|---------------------------|------------------
ovn_cas_tools_version     |ovn_cas_tools-0.1.0.tar.gz |Ovn cas tools tar version which contain cas_tools_cli and cas_tools_server
clearing_profile          |clearing.profile           | clearing profile
ovn_cas_tools_artifact_url| https://artifactory.trusted.visa.com:8080/ovn-snapshots/com/visa/ovn/ovn_cas_tools-0.1.0.tar.gz  |Artifactory URL to get the ovn cas tools tar
clearing_job_artifact_url| https://artifactory.trusted.visa.com/ovn-snapshots/com/visa/ovn/ovn_clearing_jobs-assembly-0.1-SNAPSHOT.jar    |Artifactory URL to get the clearing jobs tar


Requirements
====
* Nomad server and client up and running
* Kafka up and running
* Riak up and running

To run locally
==
* Add the following proxy setup section to clearing_master_job_deploy.yml

 ```code()
  vars:
    proxy_env:
      http_proxy: http://{{user@password}}@na55hrbc03.visa.com
      https_proxy: httpis://{{user@password}}@na55hrbc03.visa.com
