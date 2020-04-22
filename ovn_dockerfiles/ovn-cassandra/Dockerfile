FROM ovn-docker.artifactory.trusted.visa.com/centos7_ovn_common:latest
LABEL maintainer "ovndev@visa.com"

COPY overlay /

RUN yum -y install \
      initscripts \
      cassandra \
      openssh-server \
  && yum clean all \
  && rm -rf /var/lib/yum/yumdb

RUN /sbin/chkconfig cassandra on

# 7000: intra-node communication
# 7001: TLS intra-node communication
# 7199: JMX
# 9042: CQL
# 9160: thrift service
EXPOSE 7000 7001 7199 9042 9160

COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

# BEGIN sshd boiler plate
# configure pam_loginuid as optional
RUN mkdir /var/run/sshd \
  && ssh-keygen -t rsa -f /etc/ssh/ssh_host_rsa_key -N '' \
  && chmod -R go-rwsx /root/.ssh \
  && echo "TrustedUserCAKeys /etc/ssh/trusted-user-ca-keys.pub" >> /etc/ssh/sshd_config

EXPOSE 22
# END sshd boilper plate
