# Roles and Policies for Cluster Access Control

These Hashicorp Vault policies and roles for Remote data center access are defined by the `policy` and `role` files.

Please refer to the [Cluster Access Management for Administration](https://visawiki.trusted.visa.com/display/OVN/Indonesia+Cluster+Access+Management+for+Administration)

There are four main `roles`:

 Role | Description
-------|-----------
 adminrole | Grants access to the remote data center as the `admin` principal.  `admin` principal are allowed full `sudo` privilege esalation on the remote cluster.  Access to the `adminrole` is controlled by the `adminrole-policy` definition.
 appsupportrole  | Grants access to the remote data center as the `appsupport` principal.  This is typically granted to developer's for real-time problem investigation on production issues that have been escalated to level 3 support.  `appsupport` has read-only access to the remote cluster.
 supportrole | Grants access to the remote data center as the `support` principal.  This is granted to operational support staff for read-only access to investigate production issues.
 cdrole | `cdrole` is dedicated to automation workflow for tasks such as ansible playbook deployments.

## How do I get access to the remote data center

The access to the remote data center is a two step process

* Install vault

```bash
# if on mac os x
brew install vault

# if on centos
curl -LO https://artifactory.trusted.visa.com/ovn/repo/vault_0.8.1_linux_amd64.zip
unzip vault_0.8.1_linux_amd64.zip; mv vault /usr/local/bin
```

* mount ssh backend and set `VAULT_ADDR` to the url where Hashicorp Vault Server.  For the `dev` POC environment use `http://sl73ovnapd112:8200`.

```bash
$ export VAULT_ADDR=<hashicorp vault server url>
$ vault mount -path=ssh ssh
Successfully mounted 'ssh' at 'ssh'!
```

* Perform 2FA against the firewall.  The following is 2FA firewall for the `dev` environment where POC is currently running.

```bash
telnet 10.199.56.20 259
...
```

* authenticate to the vault to get `token` to get your ssh public key signed by the SSH CA.  A vault `token` is issued upon successful authentication with appropriate policies that are mapped to the member ldap groups.

```bash
$ vault auth -method=ldap username=younglee
Password (will be hidden):
Successfully authenticated! You are now logged in.
The token below is already saved in the session. You do not
need to "vault auth" again with the token.
token: xxxxxxxxxxxxxxxxxxxxxxxxxxx
token_duration: 31535999
token_policies: [adminrole-policy default]
```

* Use the vault `token` to get ssh public key signed by the SSH CA.  For `<role>` enter one of `adminrole`, `appsupportrole`, or `supportrole`.

```bash
VAULT_TOKEN=xxxxxxxxxxxxxxxxxxxxxxxxxxx vault write --field=signed_key ssh/sign/<role> public_key=@$HOME/.ssh/id_rsa.pub > $HOME/.ssh/id_rsa-cert.pub
```

* Now you can access machines in the remote data center as SSH principal you been granted.  For `<principal>` enter of `admin`, `appsupport`, or `support` respective to the `<role>` used in the previous step to obtain the vault `token`.

```bash
ssh <principal>@<remote host>
```
