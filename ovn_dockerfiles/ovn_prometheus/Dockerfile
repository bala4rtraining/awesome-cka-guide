FROM ovn-docker.artifactory.trusted.visa.com/centos:7.4.1708
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

RUN chown -R prometheus:prometheus /opt/app/prometheus
RUN chmod 755 /opt/app/prometheus
USER prometheus
RUN curl -o /opt/app/prometheus/prometheus-1.7.1.linux-amd64.tar.gz https://artifactory.trusted.visa.com/ovn-releases/ovn/repo/prometheus-1.7.1.linux-amd64.tar.gz

RUN tar -xzf /opt/app/prometheus/prometheus-1.7.1.linux-amd64.tar.gz -C /opt/app/prometheus/

COPY config/prometheus.yml  /etc/prometheus/prometheus.yml

WORKDIR    /opt/app/prometheus
EXPOSE     9088
ENTRYPOINT [ "/opt/app/prometheus/prometheus-1.7.1.linux-amd64/prometheus" ]
CMD        [ "-config.file=/etc/prometheus/prometheus.yml", \
             "-web.listen-address=:9088", \ 
             "-web.external-url=http://127.0.0.1/prometheus"]

