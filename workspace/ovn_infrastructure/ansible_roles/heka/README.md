heka
=========

This role installs the heka service as a collector and forwarder for stats and logs.
The default configuration forwards logs to the elasticsearch cluster using http/json 
the target cluster is defined in the roles/heka/defaults/main.yml


Requirements
------------

Expected to be run on OVN servers (e.g. mediator, riak and switch). It defines the hekad
service and sets it up to run automatically.


Role Variables
--------------

| Variable                  | Default values   | Description                                                                                                                                        | 
|---------------------------|------------------|----------------------------------------------------------------------------------------------------------------------------------------------------| 
| heka_log_templates        |                  | list of templates to deploy                                                                                                                        | 
| elasticsearch_host        | 127.0.0.1        | fqdn of elasticsearch host (for storing log,data)                                                                                                  | 
| carbon_host               | 127.0.0.1        | fqdn of carbon host (when using statsd,template)                                                                                                   | 
| heka_statsd_port          | 8125             | statsd port where heka will listen. 9126 on,hosts where udp_repeater is running and 8125 on rest of the hosts.                                     | 
| heka_total_buffer_size    | 0 (no limit)     | Maximum amount of disk space that the entire,queue buffer can consume. Defaults to 0 (no limit)                                                    | 
| heka_action_on_max_buffer | shutdown         | The action Heka will take if the queue,buffer grows to larger than the maximum specified by the max_buffer_size,setting.                           | 
| heka_buffer_file_size     | 512 MiB          | max size of a single file in the queue,buffer.                                                                                                     | 
| heka_cursor_update_count  | 1                | count of UpdateCursor calls must be made, before the cursor location is flushed to disk. if 0 is specified the default will be used instead.       | 
| heka_cache_dir            | /var/cache/hekad | location of the buffer cache                                                                                                                       | 

Dependencies
------------

- The most recent hekad RPM is stored in artifactory (version/name stored in defaults).  
- Assumes a target elasticsearch cluster is running and accepting data over http.
- when deploying statsd, requires a graphite system to receive metrics using carbon-graphite protocol


Example Playbook
----------------

    - hosts: servers
      roles:
         - heka
      vars:
         elasticsearch_host: sl73ovnapd021.visa.com
         heka_log_templates: "{{ kafkalog_templates }}"


License
-------

N/A


Author Information
------------------

Nathan Aschbacher (naschbac@visa.com)
Robert Yeung (ryeung@visa.com)
