# OVN jenkins pipeline

With jenkins 2.0 and above we have the ability to develop code in jenkinsfile pipeline language.
This repository contains the sourcecode used by Jenkins for Open VisaNet.

## How this repository is organized

- Continuous Deployment jenkins jobs are stored in the `cd_pipeline` directory.
- Continuous Integration jenkins jobs are stored in the `ci_pipeline` directory.
- Release management jenkins jobs are stored in the `release_pipeline` directory.
- Mirror-ovnhub jenkins jobs are stored in the `admin_pipeline` directory.
- Test jenkins jobs are stored in the `test_pipeline` directory.
- Shellscripts that are used by called by Jenkins pipeline are stored in the `jenkins-sh` directory.
- groovy files used for Jenkins shared library are stored in the `vars` directory.


## CD Pipeline

The CD Pipeline jobs managed in this repository need to be deployed to several jenkins instances. There is one Jenkins CD appliance instance for each one of the discrete target deployment clusters. All of the clusters draw from this library of defined jenkins jobs.

The Makefile for this repo will package the jenkins jobfiles drawn from the repo into a tarball artifact.


```bash
make generatetarball

Created config.xml for OVN_UMF_delivery_APF_start_stop
. . .
Created config.xml for update_sshd_config
Created config.xml for upgrade_elasticsearch
Created config.xml for upgrade_jre_elasticsearch
Created config.xml for validate_update_packages
TARBALL generation start ...[Done]
Generated archive: jenkinsCDjobs.tar.gz

```


## CI Pipeline

The CI pipeline jobs are templatized jenkinsfile jobs they are organized as follows:


| Name  (filetype is jenkinsfile)         | description                                                           |
| --------------------------------------- | ----------------------------------------------------------------------|
| CI-Nightly(EPICx)                       | Full job flow runs every night and calls the jobs below               |
| CI-nightly-epicx-deploy-infra           | deployment infra only for epicx                                       |
| CI-nightly-epicx-deploy-app             | deployment of applications for epicx job                              |
| CI-nightly-epicx-test1                  | job that runs the E2E test after the successful deploy                |
| CI-nightly-epicx-test2                  | supplemental testing (edge cases that may be known to fail)           |
|                                         |                                                                       |



## Release Pipeline

The Release pipeline jobs are jenkinsfile jobs they are organized as follows:

| Name  (filetype is jenkinsfile)         | description                                                           |
| --------------------------------------- | ----------------------------------------------------------------------|
| release-auth                            | jenkinsfile source for the auth release job                           |
| release-auth-create-branches            | jenkinsfile source for the auth create branches job                   |
| release-auth-freeze-dependencies        | jenkinsfile source for the auth freeeze dependencies job              |
| release-auth-tag-master-branches        | jenkinsfile source for the auth tag master branches job               |
| release-clearing                        | jenkinsfile source for the clearing release job                       |
| release-clearing-create-branches        | jenkinsfile source for the clearing create branches job               |
| release-clearing-tag-master-branches    | jenkinsfile source for the clearing tag master branches job           |
| release-typeofrelease-functionname .    | jenkinsfile source for etc.                                           |
|                                         |                                                                       |


## `vars` To support shared libraries

groovy files are stored in the vars directory. The JenkinsCD and CI configuration retrieves this library and uses the
files from this directory when called at the top of a jenkinsfile thus:

```bash

@Library('ovn-shared-library') _
ciAuthNightly('integration')

```

Here are some examples:

| Name  (filetype is groovy)              | description                                                           |
| --------------------------------------- | ----------------------------------------------------------------------|
| ciNightlyflowConfig                     | groovy sourcecode contains template for CI-Nightly (config)           |
| runPlaybook                             | groovy sourcecode template for running standard OVN ansible playbooks |
| pipelineForErlang                       | groovy sourcecode template multibranch Jenkinsfile CI build           |
| pipelineForGo                           | groovy sourcecode template multibranch Jenkinsfile CI build           |
