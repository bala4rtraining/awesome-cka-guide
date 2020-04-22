FROM ovn-docker.artifactory.trusted.visa.com/centos7_ovn_common:latest

COPY overlay /

COPY ovn_nginx_auth-*-linux-amd64.tar.gz /opt/app/ovn_nginx_auth/

RUN tar -xzf /opt/app/ovn_nginx_auth/ovn_nginx_auth-*-linux-amd64.tar.gz -C /opt/app/ovn_nginx_auth/

ENTRYPOINT ["/opt/app/ovn_nginx_auth/ovn_nginx_auth", "-config", "/opt/app/ovn_nginx_auth/config/ovn_nginx_auth.yaml"]
