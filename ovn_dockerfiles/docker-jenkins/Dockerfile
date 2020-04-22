FROM ovn-docker.artifactory.trusted.visa.com/centos7_ovn_common:latest

COPY overlay-ansible /

RUN yum clean all && yum -y update && yum install -y \
        ansible-2.4.2.0 \
        dejavu-sans-fonts \
        docker-ce \
        fontconfig \
        git \
        initscripts \
        jdk \
        jenkins \
        mailx \
        sendmail \
        sssd-client \
    && yum clean all

RUN update-ca-trust force-enable && update-ca-trust extract \
  && alternatives --set java /usr/java/jdk1.8.0_*/jre/bin/java

RUN find /lib/systemd/system/sysinit.target.wants \
         /lib/systemd/system/multi-user.target.wants \
         /lib/systemd/system/local-fs.target.wants \
         /lib/systemd/system/local-fs.target.wants \
         /etc/systemd/system/*.wants \
         /lib/systemd/system/sockets.target.wants/*udev* \
         /lib/systemd/system/sockets.target.wants/*initctl* \
      \! -type d \
| grep -v systemd-tmpfiles-setup.service \
| xargs rm -f

RUN systemctl enable jenkins

ENV container docker

VOLUME ["/sys/fs/cgroup", "/tmp", "/run", "/run/lock"]

RUN useradd -p '$6$1gkUwNuKYbp.3f6C$nqUiG0.gHQkPdAWGpbiceOifr7X9aqfE5FNFElCDtQP/LSx3ROXrg4b61c8bHvKr3hLUr/Rn3CwsWrYc9G08W1' ovndev \
    && usermod -u 995 jenkins \
    && groupmod -g 993 jenkins \
    && chown -R jenkins:jenkins /var/cache/jenkins \
    && chown jenkins /etc/shadow \
    && chmod 400 /etc/shadow

CMD ["/usr/sbin/init"]
