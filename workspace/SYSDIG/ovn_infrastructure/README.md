# OVN Infrastructure

Ansible is the configuration management tool of choice for OVN.  Going forward we should follow [Ansible Best Practices](http://docs.ansible.com/ansible/playbooks_best_practices.html)
when writing playbooks or ansible roles.

Below are notable Ansible recommendations OVN developers are encouraged to follow:
- [OVN Inventory Directory Layout](http://docs.ansible.com/ansible/playbooks_best_practices.html#alternative-directory-layout)
- [Group And Host Variables](http://docs.ansible.com/ansible/playbooks_best_practices.html#group-and-host-variables)
- [Top Level Playbooks Are Separated By Role](http://docs.ansible.com/ansible/playbooks_best_practices.html#top-level-playbooks-are-separated-by-role)
- [Task And Handler Organization For A Role](http://docs.ansible.com/ansible/playbooks_best_practices.html#task-and-handler-organization-for-a-role)
- [How to Differentiate Staging vs Production](http://docs.ansible.com/ansible/playbooks_best_practices.html#how-to-differentiate-staging-vs-production)
- [Variables and Vaults](http://docs.ansible.com/ansible/playbooks_best_practices.html#variables-and-vaults)

This is the benefit we gain when ansible playbook and roles are structured as recommended by [Ansible Best Practices](http://docs.ansible.com/ansible/playbooks_best_practices.html) above.
> Now what sort of use cases does this layout enable? Lots! If I want to reconfigure my whole infrastructure, it’s just:
> ```bash
> ansible-playbook -i production site.yml
> ```
> What about just reconfiguring NTP on everything? Easy.:
> ```bash
> ansible-playbook -i production site.yml --tags ntp
> ```
> What about just reconfiguring my webservers?:
> ```bash
> ansible-playbook -i production webservers.yml
> ```
> What about just my webservers in Boston?:
> ```bash
> ansible-playbook -i production webservers.yml --limit boston
> ```
> What about just the first 10, and then the next 10?:
> ```bash
> ansible-playbook -i production webservers.yml --limit boston[1-10]
> ansible-playbook -i production webservers.yml --limit boston[11-20]
> ```
> And of course just basic ad-hoc stuff is also possible.:
> ```bash
> ansible boston -i production -m ping
> ansible boston -i production -m command -a '/sbin/reboot'
> ```
> And there are some useful commands to know (at least in 1.1 and higher):
> ```bash
> # confirm what task names would be run if I ran this command and said "just ntp tasks"
> ansible-playbook -i production webservers.yml --tags ntp --list-tasks
>
> # confirm what hostnames might be communicated with if I said "limit to boston"
> ansible-playbook -i production webservers.yml --limit boston --list-hosts
> ```

## Testing ansible playbook with vagrant

Vagrant is a good tool for testing playbooks or roles.  Vagrant can help in incrementally writing ansible playbooks or roles.  It can even help run ansible playbooks in the debugger (more on this later).

If you are not using homebrew on mac, then you should use it :).  You can install homebrew with

```bash
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
```

Now install vagrant and virtualbox

```bash
brew cask install vagrant
brew cask install virtualbox
```

Save the following contents as a `Vagrantfile` in the same directory where your playbook is located.

```bash
# -*- mode: ruby -*-
# vi: set ft=ruby :

HTTP_PROXY = ENV['HTTP_PROXY'] || ENV['http_proxy']
HTTPS_PROXY = ENV['HTTPS_PROXY'] || ENV['https_proxy']
NO_PROXY = ENV['NO_PROXY'] || ENV['no_proxy'] || '127.0.0.1,localhost'

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.
Vagrant.configure("2") do |config|

  config.vm.box_download_insecure = true  # eliminate annoying Visa Man in the middle Cert SSL error

  #
  # This is needed when working behind Visa corporate proxy
  # you should install vagrant proxy plugin by running the following
  # command from the shell:
  #
  #     vagrant plugin install vagrant-proxyconf
  #
  # (If running the above command fails, then try running it when you outside of Visa corporate proxy.)
  #
  config.proxy.http     = HTTP_PROXY
  config.proxy.https    = HTTPS_PROXY
  config.proxy.no_proxy = NO_PROXY

  config.vm.box = "centos/7"

  # Disable the new default behavior introduced in Vagrant 1.7, to
  # ensure that all Vagrant machines will use the same SSH key pair.
  # See https://github.com/mitchellh/vagrant/issues/5005

  config.ssh.insert_key = false

  config.vm.provision "ansible" do |ansible|
    ansible.playbook = "provision.yml"  # replace 'provision.yml' with the name of your playbook
    ansible.verbose = "v"
  end

end

```

Modify the hosts target in your playbook with default

```bash
---
- hosts: default
  roles:
    - role: ...
```

Just run the following command from the same directory where you saved the `Vagrantfile`

```bash
vagrant up --provision
```

If you run into issues you can manually run the playbook in the ansible debugger. To run in the debugger, update the playbook

```bash
---
- hosts: default
  strategy: debug
  roles:
    - role: ...
```

Run ansible manually from the same directory.  Please refer to the [Playbook Debugger](https://docs.ansible.com/ansible/playbooks_debugger.html) for using the debugger and [Using Vagrant with Ansible](http://docs.ansible.com/ansible/guide_vagrant.html).

```bash
ansible-playbook --private-key=~/.vagrant.d/insecure_private_key -u vagrant -i .vagrant/provisioners/ansible/inventory/vagrant_ansible_inventory provision.yml
```
