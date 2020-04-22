Currency
=====

This role is used to deploy a currency file to the switch nodes of the specified environment. This will deploy from ovngit. The new currency data will be deployed to /opt/currency.
After the currency has been deployed, the ovn_switch application will detect the addition of the new currency data and automatically use the latest, activated version. As a result, a restart of the ovn_switch is not required.
The deploy playbook is typically only called manually in lower environments when a specific version is needed for testing. Currency build / deployment is managed by an automated process that will deploy daily, regardless of whether new currency data is found.

Requirements
-----

* When calling the deploy_currency playbook, you must pass the currency_ovngit_ref variable.
* The currency will be deployed from ovngit, so the value specified for this variable must match a version available there. (http://sl55ovnapq01.visa.com/git/)
* The currency_ovngit_ref is generated based on the environment name, date, and build number from the currency_build job.

Role Variables
-----

| var                         |  default   | desc
|-----------------------------|------------|-------------------------------------------------------------|
| currency_ovngit_ref         |  N / A     | The ovngit_ref where the currency tarball has been uploaded.|


Example Playbook
--------------

```yaml
ansible-playbook ansible_ovn/deploy_currency.yml -i inventories/test/dc1 -e currency_ovngit_ref=build/currency/prod.indonesia-dci/2018/04-16/296
```

Dependencies
-----
None

Licence
----
None

Author
----
* Zack Petersen  <zpeterse@visa.com>