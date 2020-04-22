**my_organization/ansible_nomad**

---
#Overview

This is an empty Ansible project scaffolded just for you, so you can get to work automating all the things!

**Prerequisites:**
* [ansible](#ansible)

If you have all these already, just skip to the [Usage](#usage) section.

###ansible

**Install python-pip:**

    $ sudo easy_install pip

**Setup virtualenvwrapper:**

    $ sudo pip install virtualenvwrapper

**Add these lines to your ~/.profile file:**

    export WORKON_HOME=$HOME/.virtualenvs
    export PROJECT_HOME=$HOME/Repositories
    source /usr/local/bin/virtualenvwrapper.sh

The above assumes that your projects live in your home folder in a directory named `Repositories`

**Reload your shell or source the above file to load the changes:**

        $ source ~/.profile

**Create an environment for doing your ansible development:**

        $ mkvirtualenv ansible-dev

**Make sure your new environment is loaded:**

        $ workon ansible-dev

**Install ansible:**

        $ pip install ansible

---

#Usage

##Running the playbook

	$ cd ~/Repositories/ansible_nomad
	$ ansible-playbook -i inventory/hosts site.yml
	
##Testing

The `test.yml` playbook should contain test scenarios and/or include external tasks for testing which in this example are contained in `tests/main.yml`

These are intended to be akin to unit tests for this playbook project:

        $ cd ~/Repositories/ansible_nomad
	$ ansible-playbook -i inventory/hosts test.yml
