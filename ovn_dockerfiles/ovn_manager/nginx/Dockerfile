FROM ovn-docker.artifactory.trusted.visa.com/centos7_ovn_common:latest

COPY overlay /

RUN yum clean all && yum clean metadata
RUN yum install -y https://artifactory.trusted.visa.com/ovn-rpm-prod/ovn-extra-el7/nginx-1.12.1-1.el7.centos.ngx.x86_64.rpm

CMD ["nginx", "-g", "daemon off;"]
