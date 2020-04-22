FROM ovn-docker.artifactory.trusted.visa.com/centos7_ovn_common:latest
LABEL maintainer "ovndev@visa.com"

######
# borrowed from 'docker-vault/0.7.3/docker-entrypoint.sh'
# modified to run under centos7
######

# This is the release of Vault to pull in.
ENV VAULT_VERSION=0.7.3

# This is the release of https://github.com/hashicorp/docker-base to pull in order
# to provide HashiCorp-built versions of basic utilities like dumb-init and gosu.
ENV DOCKER_BASE_VERSION=0.0.4

# Create a vault user and group first so the IDs get set the same way,
# even as the rest of this may change over time.
RUN /usr/sbin/groupadd vault \
  && /usr/sbin/useradd -g vault vault

# Set up certificates, our base tools, and Vault.
RUN yum clean all && yum -y update \
  && yum -y install \
        libcap \
        unzip \
        which \
    \
  && curl -sLO https://artifactory.trusted.visa.com/ovn-releases/ovn/repo/docker-base_${DOCKER_BASE_VERSION}_linux_amd64.zip \
  && unzip -d / docker-base_${DOCKER_BASE_VERSION}_linux_amd64.zip \
  && rm -f docker-base_${DOCKER_BASE_VERSION}_linux_amd64.zip \
    \
  && curl -sLO https://artifactory.trusted.visa.com/ovn-releases/ovn/repo/vault_${VAULT_VERSION}_linux_amd64.zip \
  && unzip -d /usr/local/bin vault_${VAULT_VERSION}_linux_amd64.zip \
  && rm -f vault_${VAULT_VERSION}_linux_amd64.zip \
    \
  && rm -rf /tmp/* /var/tmp/* \
  && yum clean all \
  && rm -rf /var/lib/yum/yumdb

# /vault/logs is made available to use as a location to store audit logs, if
# desired; /vault/file is made available to use as a location with the file
# storage backend, if desired; the server will be started with /vault/config as
# the configuration directory so you can add additional config files in that
# location.
RUN mkdir -p /vault/logs && \
    mkdir -p /vault/file && \
    mkdir -p /vault/config && \
    chown -R vault:vault /vault

# Expose the logs directory as a volume since there's potentially long-running
# state in there
VOLUME /vault/logs

# Expose the file directory as a volume since there's potentially long-running
# state in there
VOLUME /vault/file

# 8200/tcp is the primary interface that applications use to interact with
# Vault.
EXPOSE 8200

ENV VAULT_ADDR="http://vault:8200" \
    VAULT_DEV_ROOT_TOKEN_ID="vault_token"

# The entry point script uses dumb-init as the top-level process to reap any
# zombie processes created by Vault sub-processes.
#
# For production derivatives of this container, you shoud add the IPC_LOCK
# capability so that Vault can mlock memory.
COPY docker-entrypoint.sh /bin/docker-entrypoint.sh
RUN chmod ugo+x /bin/docker-entrypoint.sh
ENTRYPOINT ["docker-entrypoint.sh"]

# By default you'll get a single-node development server that stores everything
# in RAM and bootstraps itself. Don't use this configuration for production.
CMD ["server", "-dev"]
