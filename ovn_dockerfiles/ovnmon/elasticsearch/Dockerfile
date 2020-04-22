# === ELASTICSEARCH Dockerfile ===
# Compare with https://github.com/elastic/elasticsearch-docker
#
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
RUN yum -y install java-1.8.0-openjdk

RUN useradd -u 1000 -d /usr/share/elasticsearch elasticsearch

ENV PATH /usr/share/elasticsearch/bin:$PATH
ENV JAVA_HOME /usr/lib/jvm/jre-1.8.0

WORKDIR /usr/share/elasticsearch

RUN rpm -Uvh http://sl55ovnapq01.visa.com/git/@pod1/3rd_party/elasticsearch/v5.2.2:/elasticsearch-5.2.2.rpm

RUN set -ex && for esdirs in config data logs; do \
        mkdir -p "$esdirs"; \
        chown -R elasticsearch:elasticsearch "$esdirs"; \
    done

USER elasticsearch

COPY ./config/elasticsearch.yml config/
COPY ./config/log4j2.properties config/
COPY ./bin/es-docker bin/es-docker

USER root
RUN chown elasticsearch:elasticsearch config/elasticsearch.yml config/log4j2.properties bin/es-docker && \
    chmod 0750 bin/es-docker

USER elasticsearch
CMD ["/bin/bash", "bin/es-docker"]

EXPOSE 9200 9300
