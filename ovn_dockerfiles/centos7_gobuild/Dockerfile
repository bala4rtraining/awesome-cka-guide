FROM ovn-docker.artifactory.trusted.visa.com/centos7_ovn_common:latest
LABEL maintainer "ovndev@visa.com"

COPY overlay /

# These users must have fix uid and gid
RUN /usr/sbin/groupadd was -g 309 \
  && /usr/sbin/useradd was -g was -u 311 -G wheel \
  && /usr/sbin/groupadd vagrant -g 409 \
  && /usr/sbin/useradd vagrant -g vagrant -u 411 -G wheel,was \
  && /usr/sbin/groupadd jenkins -g 993 \
  && /usr/sbin/useradd jenkins -g jenkins -u 995 -d /var/lib/jenkins \
  && /usr/sbin/groupadd ovngrp -g 12065 \
  && /usr/sbin/useradd ovncd -d /home/ovncd -s /bin/bash -u 601815 -m -g ovngrp \
  && /usr/bin/passwd -x 99999 ovncd


# install software
RUN yum -y install \
      bind-utils \
      ca-certificates \
      docker-ce \
      file \
      gcc \
      gcc-c++ \
      git \
      glibc-devel.i686 \
      glibc-devel.x86_64 \
      gnupg2 \
      iperf3 \
      jq \
      librdkafka-devel \
      libstdc++ \
      libstdc++-devel \
      libstdc++.i686 \
      libstdc++-devel.i686 \
      lz4 \
      lz4-devel \
      make \
      nodejs \
      openssh-server \
      openssl \
      openssl-devel \
      dockle \
      passwd \
      pwgen \
      screen \
      sudo \
      unzip \
      wget \
      which \
      yum-plugin-ovl \
      zlib \
      zlib-devel \
  && yum clean all \
  && rm -rf /var/lib/yum/yumdb

RUN update-ca-trust force-enable && update-ca-trust extract

RUN curl -sL -o /usr/bin/docker-compose https://artifactory.trusted.visa.com/ovn-releases/ovn/repo/docker-compose-1.21.2-Linux-x86_64 \
  && chmod ugo+x /usr/bin/docker-compose

RUN curl -sLO https://artifactory.trusted.visa.com/ovn-releases/ovn/repo/go1.13.3.linux-amd64.tar.gz \
  && tar -C tmp/ -xzf go1.13.3.linux-amd64.tar.gz \
  && mkdir -p /usr/local/go/1.13 \
  && mv /tmp/go/* /usr/local/go/1.13/. \
  && ln -snf /usr/local/go/1.13 /usr/local/go/default \
  && rm -f go1.13.3.linux-amd64.tar.gz

RUN curl -sLO https://artifactory.trusted.visa.com/ovn-releases/ovn/repo/protoc-3.10.0-linux-x86_64.zip \
  && unzip -d /usr/local protoc-3.10.0-linux-x86_64.zip \
  && rm -f protoc-3.10.0-linux-x86_64.zip

RUN curl -sLO https://artifactory.trusted.visa.com/ovn-releases/ovn/repo/golangci-lint-1.19.1-linux-amd64.tar.gz \
  && tar -C tmp/ -xzf golangci-lint-1.19.1-linux-amd64.tar.gz \
  && mv /tmp/golangci-lint-1.19.1-linux-amd64/golangci-lint /usr/local/bin \
  && rm -f golangci-lint-1.19.1-linux-amd64.tar.gz

RUN curl -sLO https://artifactory.trusted.visa.com/ovn-releases/ovn/repo/gocover-cobertura-v0.0.0.tar.gz \
  && tar -C /usr/local -xzf gocover-cobertura-v0.0.0.tar.gz \
  && rm -f gocover-cobertura-v0.0.0.tar.gz

RUN curl -sLO https://artifactory.trusted.visa.com/ovn-releases/ovn/repo/jfrog-1.29.2-linux-amd64 \
  && mv jfrog-1.29.2-linux-amd64 /usr/bin/jfrog \
  && chmod ugo+x /usr/bin/jfrog

RUN curl -sLO https://artifactory.trusted.visa.com/ovn-releases/ovn/repo/protoc-gen-go-v1.3.2-linux-amd64.tar.gz \
  && tar -C /usr/local -xzf protoc-gen-go-v1.3.2-linux-amd64.tar.gz \
  && rm -f protoc-gen-go-v1.3.2-linux-amd64.tar.gz

RUN curl -sL -o /usr/bin/covertool https://artifactory.trusted.visa.com/ovn-releases/ovn/repo/covertool \
  && chmod ugo+x /usr/bin/covertool

RUN mkdir -p /opt/BD \
  && /root/bin/download-latest.sh 'hub-detect-*.jar' '/opt/BD/hub-detect.jar'

RUN mkdir -p /opt/visakp/lib/1.5.1 \
  && cd /opt/visakp/lib/1.5.1 \
  && curl -sLO https://artifactory.trusted.visa.com/secarcheng-snapshots/visakp/linux/visakp-libs-1.5.1.tar.gz \
  && tar -C /opt/visakp/lib/1.5.1 -xzf visakp-libs-1.5.1.tar.gz
#  && ln -sfn /opt/visakp/lib/1.5.1 /opt/visakp/lib/default

RUN mkdir -p /opt/visakp/lib/1.3.1 \
  && cd /opt/visakp/lib/1.3.1 \
  && curl -sLO https://artifactory.trusted.visa.com/secarcheng-snapshots/visakp/linux/visakp-libs-1.3.1.tar.gz \
  && tar -C /opt/visakp/lib/1.3.1 -xzf visakp-libs-1.3.1.tar.gz \
  && ln -sfn /opt/visakp/lib/1.3.1 /opt/visakp/lib/default

# install sona-scanner from artifactory for analysis
RUN wget -q -O /opt/sonar-scanner-cli-3.1.0.1141-linux.zip https://artifactory.trusted.visa.com/scm-tools/sonarqube/sonar-scanner-cli-3.1.0.1141-linux.zip  \
  && unzip /opt/sonar-scanner-cli-3.1.0.1141-linux.zip -d /opt/ \
  && ln -s /opt/sonar-scanner-3.1.0.1141-linux/bin/sonar-scanner /usr/bin/sonar-scanner \
  && rm -f /opt/sonar-scanner-cli-3.1.0.1141-linux.zip \
  && sed -i 's|#sonar.host.url=http://localhost:9000|sonar.host.url=https://sonarqube.trusted.visa.com|g' /opt/sonar-scanner-3.1.0.1141-linux/conf/sonar-scanner.properties

RUN curl -sLO https://artifactory.trusted.visa.com/ovn-releases/ovn/repo/go-junit-report.tar.gz \
  && tar -C /usr/local/bin -xzf go-junit-report.tar.gz \
  && rm -f go-junit-report.tar.gz

RUN chmod 0755 /root/bin/cleanup.sh

# BEGIN sshd boiler plate
# configure pam_loginuid as optional
RUN mkdir /var/run/sshd \
  && ssh-keygen -t rsa -f /etc/ssh/ssh_host_rsa_key -N '' \
  && SSH_ROOTPASS=rootpass \
  && echo -e "$SSH_ROOTPASS\n$SSH_ROOTPASS" | (passwd --stdin root) \
  && echo ssh root password: $SSH_ROOTPASS \
  && sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd \
  && chmod -R go-rwsx /root \
  && echo "TrustedUserCAKeys /etc/ssh/trusted-user-ca-keys.pub" >> /etc/ssh/sshd_config

EXPOSE 22
# END sshd boilper plate

# Set up was user to be used by jenkins slaves
# Using same gid and uid as on jenkins slaves - this lets us correctly map /opt/app/jenkins and /home/was/.ssh folders
# from jenkins slave host to the docker container
# add jenkins user for running docker inside docker
RUN echo "was" | passwd --stdin was \
  && echo "was        ALL=(ALL)       NOPASSWD: ALL" >> /etc/sudoers.d/was \
  && echo "Defaults:was !requiretty"                 >> /etc/sudoers.d/was \
  && chmod 0440 /etc/sudoers.d/was \
  && echo "vagrant" | passwd --stdin vagrant \
  && echo "vagrant        ALL=(ALL)       NOPASSWD: ALL" >> /etc/sudoers.d/vagrant \
  && echo "Defaults:vagrant !requiretty"                 >> /etc/sudoers.d/vagrant \
  && chmod 0440 /etc/sudoers.d/vagrant \
  && chmod -R go-rwsx ~vagrant/.ssh \
  && chown -R vagrant:vagrant ~vagrant/.ssh \
  && mkdir -p /opt/app/jenkins \
  && chown was:was /opt/app/jenkins \
  && mkdir ~was/.ssh \
  && ssh-keyscan -t rsa -p7999 stash.trusted.visa.com >> ~was/.ssh/known_hosts \
  && chmod -R go-rwsx ~was \
  && chown -R was:was ~was \
  && chown -R was:was /usr/local/go

ENV PATH="/usr/local/go/default/bin:/usr/local/sbt/bin:${PATH}" \
    GOROOT="/usr/local/go/default"

CMD ["/usr/sbin/init"]
