# === KIBANA Dockerfile ===
# Compare with https://github.com/elastic/kibana-docker  FROM docker.elastic.co/kibana/kibana:5.2.1 (But converted to CENTOS7 @ OVN)
FROM centos:centos7.2.1511
LABEL maintainer "ovndev@visa.com"
RUN (cd /lib/systemd/system/sysinit.target.wants/; for i in *; do [ $i == systemd-tmpfiles-setup.service ] || rm -f $i; done); \
  rm -f /lib/systemd/system/multi-user.target.wants/*; \
  rm -f /etc/systemd/system/*.wants/*; \
  rm -f /lib/systemd/system/local-fs.target.wants/*; \
  rm -f /lib/systemd/system/sockets.target.wants/*udev*; \
  rm -f /lib/systemd/system/sockets.target.wants/*initctl*; \
  rm -f /lib/systemd/system/basic.target.wants/*; \
  rm -f /lib/systemd/system/anaconda.target.wants/*

# Pointing repos to OVNGIT mirror, adding overlay files
RUN rm -f /etc/yum.repos.d/*
COPY ./config/CentOS-OVNGIT.repo /etc/yum.repos.d/CentOS-OVNGIT.repo
RUN yum -y update; yum clean all

RUN rpm -Uvh http://sl55ovnapq01.visa.com/git/@pod1/3rd_party/kibana/v5.2.2:/kibana-5.2.2-x86_64.rpm

ADD config/kibana.yml /usr/share/kibana/config/
ADD bin/kibana-docker /usr/local/bin/
RUN usermod --home /usr/share/kibana kibana

RUN usermod --home /usr/share/kibana kibana
USER kibana
ENV PATH=/usr/share/kibana/bin:$PATH
CMD /usr/local/bin/kibana-docker