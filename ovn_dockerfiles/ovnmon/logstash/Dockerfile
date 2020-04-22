# === LOGSTASH Dockerfile ===
# Compare with https://github.com/elastic/logstash-docker/blob/5.2/build/logstash/Dockerfile
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
RUN yum -y install java-1.8.0-openjdk curl netbase openssh-clients

RUN useradd -u 1000 -d /usr/share/logstash logstash

ENV PATH /usr/share/logstash/bin:$PATH
ENV JAVA_HOME /usr/lib/jvm/jre-1.8.0

WORKDIR /usr/share/logstash

RUN rpm -Uvh http://sl55ovnapq01.visa.com/git/@pod1/3rd_party/logstash/v5.2.2:/logstash-5.2.2.rpm

# Provide a minimal configuration, so that simple invocations will provide
# a good experience.
ADD config/logstash.yml /usr/share/logstash/config/
ADD config/log4j2.properties /usr/share/logstash/config/
ADD pipeline/logstash.conf /usr/share/logstash/pipeline/logstash.conf
RUN chown --recursive logstash:logstash /usr/share/logstash/config/ /usr/share/logstash/pipeline/

USER logstash
CMD ["logstash", "-f", "/usr/share/logstash/pipeline/"]
