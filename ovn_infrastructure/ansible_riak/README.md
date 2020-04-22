# Riak KV

## Overview

Here are the ansible playbooks for installing Riak KV, the master playbook is `site.yml`. The `site.yml` playbook is called by the
riak deploy job in jenkins when deploying Riak KV to our Development servers (Riak KV is provisioned to support Open VisaNet advice storage/retrieval processing).


### Prerequisites:

#### ansible

External documentation available [here](http://docs.ansible.com/ansible/intro_installation.html)

##### On OSX
```
brew install ansible
```

##### On CentOS / RHEL
```
yum install ansible
```



---


# Usage

## Running the playbook

	$ cd ~/Repositories/ansible_riak
	$ ansible-playbook -i inventory/hosts site.yml
	
## Testing

The `test.yml` playbook should contain test scenarios and/or include external tasks for testing which in this example are contained in `tests/main.yml`

These are intended to be akin to unit tests for this playbook project:

    $ cd ~/Repositories/ansible_riak
	$ ansible-playbook -i inventory/hosts test.yml
