# CentOS 7 Docker Image for Go Build

This container is specially focus on the go build related process.

## How to build a docker image from the command line

The overlay directory has symlinks to the common shared files in this git repo that are copied
to the container.

Please use the following command to ensure the symlinks are followed when building the docker image.

```bash
docker build --rm --no-cache --tag centos7_gobuild .
```

## How to use the docker container to build an OVN project

The best practice to use the docker builder is to create a `Jenkinsfile` in the root of
the project directory.  The OVN automatically scans and creates a Jenkins job when the `Jenkinsfile`
is installed in the project.

Please use the `Jenkinsfile` boiler plate below.

```Jenkinsfile
node('ovn_build') {
  checkout scm

  # use the LATEST version of the centos7_gobuild.
  # you can find the LATEST from https://artifactory.trusted.visa.com/ovndocker/centos7_gobuild/

  def builder = 'ovn-docker.artifactory.trusted.visa.com/centos7_gobuild_builder:LATEST'

  # mounts the jenkins .ssh directory for the ssh keys to access stash
  def mounts = '-v /sys/fs/cgroup:/sys/fs/cgroup:ro -v /home/was/.ssh:/home/was/.ssh'
  docker.image("${builder}").inside("${mounts}") {
    # run your project build script to produce the build artifact
    sh './jenkins-build.sh'
  }
}
```
