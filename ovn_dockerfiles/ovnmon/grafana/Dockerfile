# === GRAFANA Dockerfile ===
# Compare with... https://hub.docker.com/r/grafana/grafana/ (converted to OVN Centos7)
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
RUN yum install -y libfontconfig curl ssh initscripts fontconfig
RUN useradd -u 1000 -d /usr/share/grafana grafana

RUN curl  http://sl55ovnapq01.visa.com/git/@pod1/3rd_party/gosu/v1.10:/gosu-amd64 -o /usr/bin/gosu \
    && curl http://sl55ovnapq01.visa.com/git/@pod1/3rd_party/gosu/v1.10:/gosu-amd64.asc -o /tmp/gosu.asc \
	&& export GNUPGHOME="$(mktemp -d)" \
	&& rm -r "$GNUPGHOME" /tmp/gosu.asc \
	&& chmod +x /usr/bin/gosu \
    && gosu nobody true

RUN rpm -Uvh http://sl55ovnapq01.visa.com/git/@pod1/3rd_party/grafana/v4.2.0:/grafana-4.2.0-1.x86_64.rpm

COPY ./config/grafana.ini /etc/grafana/grafana.ini
VOLUME ["/var/lib/grafana", "/var/log/grafana", "/etc/grafana"]

EXPOSE 3000

COPY ./run.sh /run.sh

ENTRYPOINT ["/run.sh"]