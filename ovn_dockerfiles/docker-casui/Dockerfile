FROM ovn-docker.artifactory.trusted.visa.com/centos7_ovn_common:latest

COPY overlay /

COPY *.tar.gz /opt/app/data/cas_ui/

RUN tar -xzf /opt/app/data/cas_ui/*.tar.gz -C /opt/app/data/cas_ui/

RUN chmod +x /opt/app/data/cas_ui/cas-ui-server

ENTRYPOINT ["/opt/app/data/cas_ui/cas-ui-server", "-config=/opt/app/data/cas_ui/config/cas_ui.yaml"]
