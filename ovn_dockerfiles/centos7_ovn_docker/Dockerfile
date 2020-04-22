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

RUN yum remove python3-html2text

# install software
RUN yum -y install \
      alien \
      ansible-2.4.2.0 \
      ant \
      bind-utils \
      ca-certificates \
      cmake \
      cyrus-sasl \
      cyrus-sasl-devel \
      devtoolset-4-gcc-c++ \
      docker-ce \
      envoy \
      esl-erlang \
      file \
      gcc \
      gcc-c++ \
      git \
      glibc-devel.i686 \
      glibc-devel.x86_64 \
      gnupg2 \
      graphiz \
      iperf \
      iperf3 \
      jdk \
      jq \
      librdkafka-devel \
      libstdc++ \
      libstdc++-devel \
      libstdc++.i686 \
      libstdc++-devel.i686 \
      libtool \
      lz4 \
      lz4-devel \
      make \
      maven \
      mysql-community-client \
      net-tools \
      nmap-ncat \
      nodejs \
      openssh-server \
      openssl \
      openssl-devel \
      passwd \
      pandoc \
      perl \
      pwgen \
      python-pip \
      riak \
      rpmdevtools \
      rpmrebuild \
      ruby \
      screen \
      sudo \
      td-agent \
      unixODBC \
      unzip \
      wget \
      which \
      wxGTK wxGTK-gl \
      yarn \
      yum-plugin-ovl \
      zlib \
      zlib-devel \
      xmlstarlet \
      python-requests \
      MySQL-python \
  && yum clean all \
  && rm -rf /var/lib/yum/yumdb

RUN update-ca-trust force-enable && update-ca-trust extract

RUN alternatives --set java $(readlink -f /usr/java/default/jre/bin/java) \
  && alternatives --set javac $(readlink -f /usr/java/default/bin/javac)

RUN curl -sL -o /usr/bin/docker-compose https://artifactory.trusted.visa.com/ovn-releases/ovn/repo/docker-compose-1.21.2-Linux-x86_64 \
  && chmod ugo+x /usr/bin/docker-compose

RUN pip install https://artifactory.trusted.visa.com/ovn-releases/ovn/repo/pypi/tabulate-0.8.2.tar.gz \
  https://artifactory.trusted.visa.com/ovn-releases/ovn/repo/pypi/kazoo-2.4.0.tar.gz \
  https://artifactory.trusted.visa.com/ovn-releases/ovn/repo/pypi/pykafka-2.7.0.dev2.tar.gz \
  https://artifactory.trusted.visa.com/ovn-releases/ovn/repo/pypi/jinja2-cli-0.6.0.tar.gz \
  https://artifactory.trusted.visa.com/ovn-releases/ovn/repo/pypi/smmap2-2.0.5.tar.gz \
  https://artifactory.trusted.visa.com/ovn-releases/ovn/repo/pypi/gitdb2-2.0.6.tar.gz \
  https://artifactory.trusted.visa.com/ovn-releases/ovn/repo/pypi/GitPython-2.1.6.tar.gz \
  https://artifactory.trusted.visa.com/ovn-releases/ovn/repo/pypi/Cerberus-1.3.1.tar.gz --trusted-host artifactory.trusted.visa.com

RUN curl -sLO https://artifactory.trusted.visa.com/ovn-releases/ovn/ovn-snapshots/ovn_dev_tools/ovn_dev_tools-v0.0.1.tar.gz \
  && mkdir -p /usr/local/share/ovn-tools \
  && tar -C /usr/local/share/ovn-tools -xzf ovn_dev_tools-v0.0.1.tar.gz \
  && chmod 600 /usr/local/share/ovn-tools/vagrant_rsa \
  && chmod +x /usr/local/share/ovn-tools/ovn* \
  && ln -sf /usr/local/share/ovn-tools/ovn /usr/local/bin/ovn \
  && rm -f ovn_dev_tools-v0.0.1.tar.gz

RUN curl -sLO https://artifactory.trusted.visa.com/ovn-releases/ovn/repo/vault_0.7.3_linux_amd64.zip \
  && unzip -d /usr/local/bin vault_0.7.3_linux_amd64.zip \
  && rm -f vault_0.7.3_linux_amd64.zip

RUN /root/bin/download-latest.sh -x1 'go1.9*.linux-amd64.tar.gz' '/usr/local/go/1.9\1' \
  && ln -snf /usr/local/go/1.9* /usr/local/go/default

RUN curl -sLO https://artifactory.trusted.visa.com/ovn-releases/ovn/repo/cloc-1.80.tar.gz \
  && tar -C /tmp -xzf cloc-1.80.tar.gz \
  && mv /tmp/cloc-1.80/cloc /usr/local/bin/

RUN /root/bin/download-latest.sh -x1 'go1.11*.linux-amd64.tar.gz' '/usr/local/go/1.11\1'

RUN /root/bin/download-latest.sh -x1 'go1.12*.linux-amd64.tar.gz' '/usr/local/go/1.12\1'

RUN curl -sLO https://artifactory.trusted.visa.com/ovn-releases/ovn/repo/tee.tar \
  && tar -C / -xf tee.tar \
  && rm -f tee.tar

RUN curl -sLO https://artifactory.trusted.visa.com/ovn-releases/ovn/repo/glide-v0.13.1-linux-amd64.tar.gz \
  && echo "c403933503ea40308ecfadcff581ff0dc3190c57958808bb9eed016f13f6f32c glide-v0.13.1-linux-amd64.tar.gz" | sha256sum -c \
  && tar -C /tmp -xzf glide-v0.13.1-linux-amd64.tar.gz \
  && mv /tmp/linux-amd64/glide /usr/local/bin/glide \
  && rm -f glide-v0.13.1-linux-amd64.tar.gz

RUN curl -sLO https://artifactory.trusted.visa.com/ovn-releases/ovn/repo/protoc-3.3.0-linux-x86_64.tar.gz \
  && tar -C /usr/local -xzf protoc-3.3.0-linux-x86_64.tar.gz \
  && rm -f protoc-3.3.0-linux-x86_64.tar.gz

RUN curl -sLO https://artifactory.trusted.visa.com/ovn-releases/ovn/repo/gometalinter-v1.2.1-63-g542fd03.tar.gz \
  && tar -C /usr/local -xzf gometalinter-v1.2.1-63-g542fd03.tar.gz \
  && rm -f gometalinter-v1.2.1-63-g542fd03.tar.gz

RUN curl -sLO https://artifactory.trusted.visa.com/ovn-releases/ovn/repo/golangci-lint-v1.15.0.tar.gz \
  && tar -C /usr/local -xzf golangci-lint-v1.15.0.tar.gz \
  && rm -f golangci-lint-v1.15.0.tar.gz

RUN curl -sLO https://artifactory.trusted.visa.com/ovn-releases/ovn/repo/gocover-cobertura-v0.0.0.tar.gz \
  && tar -C /usr/local -xzf gocover-cobertura-v0.0.0.tar.gz \
  && rm -f gocover-cobertura-v0.0.0.tar.gz

RUN curl -sLO https://artifactory.trusted.visa.com/ovn-releases/ovn/jfrog \
  && mv jfrog /usr/bin \
  && chmod ugo+x /usr/bin/jfrog

RUN curl -sLO https://artifactory.trusted.visa.com/ovn-releases/ovn/repo/protoc-gen-go-69b215d01a5606c843240eab4937eab3acee6530-linux-x86_64.tar.gz \
  && tar -C /usr/local -xzf protoc-gen-go-69b215d01a5606c843240eab4937eab3acee6530-linux-x86_64.tar.gz \
  && rm -f protoc-gen-go-69b215d01a5606c843240eab4937eab3acee6530-linux-x86_64.tar.gz

RUN curl -sLO https://artifactory.trusted.visa.com/ovn-releases/ovn/repo/sbt-0.13.15.tgz \
  && tar -C /usr/local -xzf sbt-0.13.15.tgz \
  && rm -f sbt-0.13.15.tgz

RUN curl -sL -o /usr/bin/covertool https://artifactory.trusted.visa.com/ovn-releases/ovn/repo/covertool \
  && chmod ugo+x /usr/bin/covertool

RUN mkdir -p /opt/BD \
  && /root/bin/download-latest.sh 'hub-detect-*.jar' '/opt/BD/hub-detect.jar'

RUN curl -sLO https://artifactory.trusted.visa.com/ovn-releases/ovn/repo/bazel-0.5.3-without-jdk-installer-linux-x86_64.sh  \
  && bash bazel-0.5.3-without-jdk-installer-linux-x86_64.sh \
  && rm -f bazel-0.5.3-without-jdk-installer-linux-x86_64.sh

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
    GOROOT="/usr/local/go/default" \
    JAVA_TOOL_OPTIONS="-Djava.security.egd=file:/dev/./urandom -Djavax.net.ssl.trustStore=/etc/pki/java/cacerts -Djavax.net.ssl.trustStorePassword=changeit" \
    VAULT_ADDR="http://vault:8200" \
    VAULT_TOKEN="vault_token"

CMD ["/usr/sbin/init"]
