FROM ovn-docker.artifactory.trusted.visa.com/centos7_ovn_common:latest
LABEL maintainer "ovndev@visa.com"

# install software
# Overlay plugin is helping yum to run inside docker better
COPY overlay /

# These users must have fix uid and gid
RUN /usr/sbin/groupadd was -g 309 \
  && /usr/sbin/useradd was -g was -u 311 -G wheel

RUN yum -y install initscripts iproute openssh-server bind-utils rsync which \
  && rm -rf /tmp/* /var/tmp/* \
  && yum -y clean all \
  && rm -rf /var/lib/yum/yumdb

# BEGIN sshd boiler plate
# configure pam_loginuid as optional
RUN mkdir /var/run/sshd \
  && ssh-keygen -t rsa -f /etc/ssh/ssh_host_rsa_key -N '' \
  && chmod -R go-rwsx /root/.ssh \
  && echo "TrustedUserCAKeys /etc/ssh/trusted-user-ca-keys.pub" >> /etc/ssh/sshd_config

EXPOSE 22
# END sshd boilper plate

RUN mkdir -p /opt/app

CMD ["/usr/sbin/init"]
