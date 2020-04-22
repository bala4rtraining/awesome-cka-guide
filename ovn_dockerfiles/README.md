# ovn_dockerfiles

This is the Open VisaNet dockerfiles repository. It contains the source files to support docker container creation and management.
The standard Docker opensource application uses the files in this repository to build Docker container images for Open VisaNet.

## How this repository is organized

* One directory per docker use case
* A **`README.md`** in each use-case directory explains the use case, and it should contain a table chronicling updates applied to the image. This is to ensure that we can match the source code dockerfile with the image stored in a docker registry.
* **`docker-compose.yml`** has a path: ovn_dockerfiles/usecasename/docker-compose.yml
* **`Dockerfile`** has a path:  ovn_dockerfiles/usecasename/build/buildname/Dockerfile

## Dockerfiles best practices @ OpenVisaNet

* Production Dockerfiles should build with **no depedency** on files from the internet.
* RPM/DEB/tgz/pypi packages used by Dockerfiles should be pulled from a visa repository (artifactory is recommended)
  _OVN engineer team members can upload binary files into OVNGIT and artifactory_
* Dockerfiles created for OVN also follow the best practices as described on the Docker.com website. https://docs.docker.com/engine/userguide/eng-image/dockerfile_best-practices/

## Summary of OVN docker use cases

| name/directory          | Description                                                                 |
|-------------------------|-----------------------------------------------------------------------------|
| ovn_base                | Used for all DEV machines should closely match current PROD                 |
| ovn_base_kh             | Clean install base for linux compute nodes for Cambodia (Centos7)           |
| ovn_base_id             | Clean install base for linux compute nodes for Indonesia (Centos7)          |
| docker-jenkins          | Dockerfile used for OVN jenkins build machines                              |
| docker-nginx            | Dockerfile used for nginx  (http frontend for multiple docker services)     |
| ovnmon                  | Dockerfile used for OVNMON (ELK in docker containers)                       |
| centos7_docker_builder  | Dockerfile used for building OVN components                                 |
| centos7_systemd_ssh     | Dockerfile used for building docker container with `systemd` and `sshd`     |
| docker-casui            | Dockerfile used for building docker container for CAS UI application        |
| ovn_teamapp             | Dockerfile used for building docker container for TEAMAPP application       |
| ovn_manager             | Dockerfile used for OVN Manager (Nginx and Nginx_Auth in docker containers) |
| ovn_promethues          | Dockerfile used for prometheus                                              |

## External documentation

Docker hub: https://hub.docker.com/explore/
