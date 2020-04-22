FROM ovn-docker.artifactory.trusted.visa.com/centos7_ovn_docker:latest

COPY overlay /

RUN curl -sL -o /usr/bin/pumba https://artifactory.trusted.visa.com/ovn-releases/ovn/repo/pumba_linux_amd64 \
  && chmod ugo+x /usr/bin/pumba

RUN yum clean all && yum -y update \
  && yum -y install \
      iproute
