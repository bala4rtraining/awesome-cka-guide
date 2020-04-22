FROM ovn-docker.artifactory.trusted.visa.com/centos7_ovn_common:latest
LABEL maintainer "ovndev@visa.com"
RUN (cd /lib/systemd/system/sysinit.target.wants/; for i in *; do [ $i == systemd-tmpfiles-setup.service ] || rm -f $i; done); \
  rm -f /lib/systemd/system/multi-user.target.wants/*; \
  rm -f /etc/systemd/system/*.wants/*; \
  rm -f /lib/systemd/system/local-fs.target.wants/*; \
  rm -f /lib/systemd/system/sockets.target.wants/*udev*; \
  rm -f /lib/systemd/system/sockets.target.wants/*initctl*; \
  rm -f /lib/systemd/system/basic.target.wants/*; \
  rm -f /lib/systemd/system/anaconda.target.wants/*

RUN useradd -u 1000 -d /usr/share/prometheus prometheus

RUN mkdir -p /opt/app/prometheus
RUN mkdir -p /opt/app/prometheus/data
RUN mkdir -p /etc/prometheus/rules
RUN chown -R prometheus:prometheus /opt/app/prometheus
RUN chmod 755 /opt/app/prometheus

RUN mkdir -p /etc/prometheus/alertmanager
RUN mkdir -p /etc/prometheus/rules
RUN chown -R prometheus:prometheus /etc/prometheus
RUN chmod 755 /etc/prometheus

RUN curl -o /opt/app/prometheus/prometheus-2.0.0.linux-amd64.tar.gz https://artifactory.trusted.visa.com/ovn-releases/ovn/repo/prometheus-2.0.0.linux-amd64.tar.gz

RUN tar -xzf /opt/app/prometheus/prometheus-2.0.0.linux-amd64.tar.gz -C /opt/app/prometheus/

RUN ln -s  prometheus-2.0.0.linux-amd64 /opt/app/prometheus/prometheus

COPY overlay/etc/prometheus/prometheus.yml  /etc/prometheus/prometheus.yml
COPY overlay/etc/systemd/system/prometheus.service etc/systemd/system/prometheus.service

COPY overlay/etc/prometheus/rules/prometheus-alert.rules.yml /etc/prometheus/rules/prometheus-alert.rules.yml

RUN systemctl enable prometheus

RUN mkdir -p /opt/app/prometheus/alertmanager
RUN mkdir -p /opt/app/prometheus/alertmanager/data

RUN chown -R prometheus:prometheus /opt/app/prometheus/alertmanager
RUN chmod 755 /opt/app/prometheus/alertmanager

RUN curl -o /opt/app/prometheus/alertmanager/alertmanager-0.8.0.linux-amd64.tar.gz https://artifactory.trusted.visa.com/ovn-releases/ovn/repo/alertmanager-0.8.0.linux-amd64.tar.gz

RUN tar -xzf /opt/app/prometheus/alertmanager/alertmanager-0.8.0.linux-amd64.tar.gz -C /opt/app/prometheus/alertmanager

RUN ln -s  alertmanager-0.8.0.linux-amd64 /opt/app/prometheus/alertmanager/alertmanager

COPY overlay/etc/prometheus/alertmanager/email.tmpl /etc/prometheus/alertmanager/email.tmpl

COPY overlay/etc/prometheus/alertmanager/alertmanager.yml /etc/prometheus/alertmanager/alertmanager.yml
COPY overlay/etc/systemd/system/alertmanager.service etc/systemd/system/alertmanager.service

RUN systemctl enable alertmanager

VOLUME ["/sys/fs/cgroup", "/tmp", "/run", "/run/lock"]
WORKDIR    /opt/app/prometheus
EXPOSE     9088
CMD ["/usr/sbin/init"]
