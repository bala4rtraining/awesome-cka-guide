# CentOS 7 OVN docker builder container with systemd and sshd

This container is a multi-purpose container for building OVN components, provisioning
OVN application with ansible playbooks and for testing.

## How to build a docker image from the command line

The overlay directory has symlinks to the common shared files in this git repo that are copied
to the container.

Please use the following command to ensure the symlinks are followed when building the docker image.

```bash
docker build --rm --no-cache --tag centos7_ovn_docker .
```

## How to use the docker container to build an OVN project

The best practice to use the docker builder is to create a `Jenkinsfile` in the root of
the project directory.  The OVN automatically scans and creates a Jenkins job when the `Jenkinsfile`
is installed in the project.

Please use the `Jenkinsfile` boiler plate below.

```Jenkinsfile
node('ovn_build') {
  checkout scm

  # use the LATEST version of the centos7_ovn_docker.
  # you can find the LATEST from https://artifactory.trusted.visa.com/ovndocker/centos7_ovn_docker/

  def builder = 'ovn-docker.artifactory.trusted.visa.com/centos7_docker_builder:LATEST'

  # mounts the jenkins .ssh directory for the ssh keys to access stash
  def mounts = '-v /sys/fs/cgroup:/sys/fs/cgroup:ro -v /home/was/.ssh:/home/was/.ssh'
  docker.image("${builder}").inside("${mounts}") {
    # run your project build script to produce the build artifact
    sh './jenkins-build.sh'
  }
}
```

## How to use the docker container to launch VMs for provisioning with ansible

Launch the docker container `centos7_ovn_docker`.

```bash
docker network create ovn_test
docker run --rm -it --network ovn_test -v /var/run/docker.sock:/var/run/docker.sock -v ~/.ssh/id_rsa:/root/.ssh/id_rsa:ro ovn-docker.artifactory.trusted.visa.com/centos7_ovn_docker:latest bash
```

Once you are inside the running container, navigate to the `root` user's home directory, `cd /root`, and
launch the docker virtual machine containers to provision OVN components with ansible playbooks.

```bash
cd /root
docker-compose up -d
```

Now checkout the ovn_infrastructure from the git repo and provision the docker containers with ansible

```bash
git clone ssh://git@stash.trusted.visa.com:7999/op/ovn_infrastructure.git
cd ovn_infrastructure
chmod 600 config/id_dev
ansible-playbook ansible_ovn/site.yml -i /root/inventories/dc1 -u root --private-key config/id_dev
```
