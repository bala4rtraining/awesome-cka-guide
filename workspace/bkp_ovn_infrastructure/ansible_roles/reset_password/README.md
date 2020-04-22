resetpassword Description
==================

resetpassword role resets root password for existing servers.

1. The current and new password are encrypted using ansible-vault.
2. The new password is only known to individuals with vault-decrypt password

Pre-requisites to test the playbook locally:
----------------------------------------------

1. vagrant-proxyconf plugin to be installed.
   Installed it from source.
   ```
   $ git clone https://github.com/tmatilai/vagrant-proxyconf
   $ cd vagrant-proxyconf
   $ bundle install
   $ bundle exec rake build
   $ vagrant plugin install pkg/vagrant-proxyconf*.gem
   ```

2. vagrant-vbguest plugin for VirtualBox guest additions

Steps(test locally):
---------------------

1. Run
   ```
   vagrant up
   ```

2. After VM is up and running,
   ```
   vagrant ssh
   ```

3. Edit /etc/ssh/sshd_config to comment out "PasswordAuthentication no"
   This is typically not required to be done.  But vanilla CentOS has password authentication disabled.
   Restart sshd service by
   ```
   sudo service sshd restart
   ```

4. Change root password of existing box to existing root password

Run playbook:
--------------

```
ansible-playbook -i <inventory-file> reset_password.yml --ask-vault-pass
```
For local test, use inventory-file=../ansible_roles/tests/test_reset_env

TBD:
-----

Eventually, we need to eliminate need of this playbook.  Password logins should not be used.
Only ssh keys to be used for login

Appendix:
---------

```
vagrant plugin install vagrant-proxyconf
```
did not work due to SSL verification error.  Alternative is to install it from source.