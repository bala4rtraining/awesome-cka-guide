# CentOS 7 Hashicorp Vault Docker Image

This is the Hashicorp Vault.  Please read thru the `docker-entrypoint.sh` file and set the environment variables
when you run the container.

```bash
docker run --rm -d -e VAULT_TOKEN=<token> -e ...  centos7_vault
```

## How to build a docker image from the command line

The overlay directory has symlinks to the common shared files in this git repo that are copied
to the container.

Please use the following command to ensure the symlinks are followed when building the docker image.

```bash
docker build --rm --no-cache --tag centos7_vault .
```
