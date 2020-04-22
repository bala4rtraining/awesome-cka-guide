FROM ovn-docker.artifactory.trusted.visa.com/centos:7.4.1708
LABEL maintainer "ovndev@visa.com"

### BEGIN systemd boiler plate
ENV container docker

RUN (cd /lib/systemd/system/sysinit.target.wants/; for i in *; do [ $i == systemd-tmpfiles-setup.service ] || rm -f $i; done); \
  rm -f /lib/systemd/system/multi-user.target.wants/*;\
  rm -f /etc/systemd/system/*.wants/*;\
  rm -f /lib/systemd/system/local-fs.target.wants/*; \
  rm -f /lib/systemd/system/sockets.target.wants/*udev*; \
  rm -f /lib/systemd/system/sockets.target.wants/*initctl*; \
  rm -f /lib/systemd/system/basic.target.wants/*;\
  rm -f /lib/systemd/system/anaconda.target.wants/*; \
  rm -f /etc/yum.repos.d/*;

VOLUME ["/tmp", "run", "/sys/fs/cgroup"]
### END systemd boiler plate

# install software
# Overlay plugin is helping yum to run inside docker better
# make sure oracle jdk (1.8.0_131) is active.
COPY overlay /

RUN update-ca-trust force-enable && update-ca-trust extract
