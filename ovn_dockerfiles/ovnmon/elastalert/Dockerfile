# === ELASTALERT Dockerfile ===
# Compare with https://github.com/tomwganem/docker-elastalert (But converted to CENTOS7 @ OVN)
FROM ovn-docker.artifactory.trusted.visa.com/centos:7.3.1611
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
RUN yum -y downgrade glibc glibc-common python-libs python openssl-libs krb5-libs libcom_err libss nss-softokn-freebl libffi nss-softokn
RUN rpm -e --justdb --nodeps libstdc++ libgcc xz-libs zlib libsepol libselinux
RUN yum install -y tar curl netbase openssh-clients python-dev tzdata ntp python-pip gcc python-devel libffi-devel openssl-devel libffi-devel libffi-3.0.13-18.el7.x86_64 openssl-devel libstdc++-4.8.5-11.el7.x86_64 libgcc-4.8.5-11.el7.x86_64 xz-libs-5.2.2-1.el7.x86_64 nss-softokn-freebl-3.16.2.3-14.4.el7.x86_64 zlib-1.2.7-17.el7.x86_64 libsepol-2.5-6.el7.x86_64 libselinux-2.5-6.el7.x86_64
ENV SET_CONTAINER_TIMEZONE false
ENV CONTAINER_TIMEZONE America/Los_Angeles
ENV ELASTALERT_URL https://artifactory.trusted.visa.com/ovn-releases/ovn/repo/elastalert-0.1.29-netcool.tar.gz
ENV PYPI_DOWNLOAD_PATH https://artifactory.trusted.visa.com/ovn-releases/ovn/repo/pypi/

ENV ELASTICSEARCH_HOST esdocker
ENV ELASTICSEARCH_PORT 9200
ENV ELASTICSEARCH_USERNAME ""
ENV ELASTICSEARCH_PASSWORD ""
ENV ELASTICSEARCH_SECURE false
ENV ELASTALERT_VERSION elastalert-0.1.29

ENV ELASTALERT_HOME /var/lib/elastalert
ENV RULES_DIRECTORY /var/lib/elastalert/${ELASTALERT_VERSION}/rules

WORKDIR /opt

RUN pip install --index-url=${PYPI_DOWNLOAD_PATH} --no-deps \
    ${PYPI_DOWNLOAD_PATH}twilio-6.0.0.tar.gz \
    ${PYPI_DOWNLOAD_PATH}stomp.py-4.1.17.tar.gz \
    ${PYPI_DOWNLOAD_PATH}idna-2.0.tar.gz \
    ${PYPI_DOWNLOAD_PATH}pyOpenSSL-0.14.tar.gz \
    ${PYPI_DOWNLOAD_PATH}aws-requests-auth-0.3.0.tar.gz \
    ${PYPI_DOWNLOAD_PATH}envparse-0.2.0.tar.gz \
    ${PYPI_DOWNLOAD_PATH}pbr-1.9.0.tar.gz \
    ${PYPI_DOWNLOAD_PATH}exotel-0.1.3.tar.gz \
    ${PYPI_DOWNLOAD_PATH}vcversioner-2.16.0.0.tar.gz

RUN pip install --index-url=${PYPI_DOWNLOAD_PATH} --no-deps \
    ${PYPI_DOWNLOAD_PATH}setuptools-21.0.0.tar.gz \
    ${PYPI_DOWNLOAD_PATH}linecache2-1.0.0.tar.gz \
    ${PYPI_DOWNLOAD_PATH}six-1.10.0.tar.gz \
    ${PYPI_DOWNLOAD_PATH}argparse-1.4.0.tar.gz \
    ${PYPI_DOWNLOAD_PATH}traceback2-1.4.0.tar.gz

RUN pip install --index-url=${PYPI_DOWNLOAD_PATH} --no-deps \
    ${PYPI_DOWNLOAD_PATH}meld3-0.6.7.tar.gz \
    ${PYPI_DOWNLOAD_PATH}supervisor-3.1.2.tar.gz \
    ${PYPI_DOWNLOAD_PATH}docutils-0.12.tar.gz \
    ${PYPI_DOWNLOAD_PATH}funcsigs-0.4.tar.gz \
    ${PYPI_DOWNLOAD_PATH}functools32-3.2.3-2.tar.gz \
    ${PYPI_DOWNLOAD_PATH}oauthlib-1.0.3.tar.gz \
    ${PYPI_DOWNLOAD_PATH}ordereddict-1.1.tar.gz \
    ${PYPI_DOWNLOAD_PATH}requests-2.10.0.tar.gz \
    ${PYPI_DOWNLOAD_PATH}jmespath-0.9.0.tar.gz \
    ${PYPI_DOWNLOAD_PATH}tlslite-0.4.9.tar.gz \
    ${PYPI_DOWNLOAD_PATH}blist-1.3.6.tar.gz \
    ${PYPI_DOWNLOAD_PATH}py-1.4.31.tar.gz \
    ${PYPI_DOWNLOAD_PATH}pytest-2.8.7.tar.gz \
    ${PYPI_DOWNLOAD_PATH}requests-toolbelt-0.5.1.tar.gz \
    ${PYPI_DOWNLOAD_PATH}repoze.lru-0.6.tar.gz \
    ${PYPI_DOWNLOAD_PATH}unittest2-1.1.0.tar.gz \
    ${PYPI_DOWNLOAD_PATH}urllib3-1.14.tar.gz \
    ${PYPI_DOWNLOAD_PATH}elasticsearch-5.4.0.tar.gz

RUN pip install --index-url=${PYPI_DOWNLOAD_PATH} --no-deps ${PYPI_DOWNLOAD_PATH}texttable-0.8.8.tar.gz
RUN pip install --index-url=${PYPI_DOWNLOAD_PATH} --no-deps ${PYPI_DOWNLOAD_PATH}mock-2.0.0.tar.gz
RUN pip install --index-url=${PYPI_DOWNLOAD_PATH} --no-deps ${PYPI_DOWNLOAD_PATH}python-dateutil-2.6.0.tar.gz
RUN pip install --index-url=${PYPI_DOWNLOAD_PATH} --no-deps ${PYPI_DOWNLOAD_PATH}simplejson-3.10.0.tar.gz
RUN pip install --index-url=${PYPI_DOWNLOAD_PATH} --no-deps ${PYPI_DOWNLOAD_PATH}PyYAML-3.12.tar.gz
RUN pip install --index-url=${PYPI_DOWNLOAD_PATH} --no-deps ${PYPI_DOWNLOAD_PATH}PyStaticConfiguration-0.10.3.tar.gz
RUN pip install --index-url=${PYPI_DOWNLOAD_PATH} --no-deps ${PYPI_DOWNLOAD_PATH}jsonschema-2.6.0.tar.gz
RUN pip install --index-url=${PYPI_DOWNLOAD_PATH} --no-deps ${PYPI_DOWNLOAD_PATH}setuptools_scm-1.15.0.tar.gz
RUN pip install --index-url=${PYPI_DOWNLOAD_PATH} --no-deps ${PYPI_DOWNLOAD_PATH}pytest-runner-4.0.tar.gz
RUN pip install --index-url=${PYPI_DOWNLOAD_PATH} --no-deps ${PYPI_DOWNLOAD_PATH}jira-1.0.10.tar.gz
RUN pip install --index-url=${PYPI_DOWNLOAD_PATH} --no-deps ${PYPI_DOWNLOAD_PATH}croniter-0.3.16.tar.gz
RUN pip install --index-url=${PYPI_DOWNLOAD_PATH} --no-deps ${PYPI_DOWNLOAD_PATH}configparser-3.5.0.tar.gz
RUN pip install --index-url=${PYPI_DOWNLOAD_PATH} --no-deps ${PYPI_DOWNLOAD_PATH}boto3-1.4.4.tar.gz

RUN pip install --index-url=${PYPI_DOWNLOAD_PATH} --no-deps \
    ${PYPI_DOWNLOAD_PATH}futures-2.2.0.tar.gz \
    ${PYPI_DOWNLOAD_PATH}pyasn1-0.1.8.tar.gz \
    ${PYPI_DOWNLOAD_PATH}enum34-1.1.5.tar.gz \
    ${PYPI_DOWNLOAD_PATH}ipaddress-1.0.15.tar.gz \
    ${PYPI_DOWNLOAD_PATH}botocore-1.5.0.tar.gz \
    ${PYPI_DOWNLOAD_PATH}s3transfer-0.1.10.tar.gz \
    ${PYPI_DOWNLOAD_PATH}requests-oauthlib-0.6.1.tar.gz \
    ${PYPI_DOWNLOAD_PATH}defusedxml-0.5.0.tar.gz \
    ${PYPI_DOWNLOAD_PATH}funcsigs-1.0.2.tar.gz \
    ${PYPI_DOWNLOAD_PATH}pytz-2018.3.tar.gz \
    ${PYPI_DOWNLOAD_PATH}PyJWT-1.4.2.tar.gz \
    ${PYPI_DOWNLOAD_PATH}pycparser-2.16.tar.gz \
    ${PYPI_DOWNLOAD_PATH}cffi-1.4.1.tar.gz \
    ${PYPI_DOWNLOAD_PATH}cryptography-1.3.4.tar.gz

RUN mkdir -p ${ELASTALERT_HOME}

RUN curl -Lo elastalert.tar.gz ${ELASTALERT_URL} && \
    tar xvf *.tar.gz -C ${ELASTALERT_HOME} && \
    rm *.tar.gz

WORKDIR ${ELASTALERT_HOME}/${ELASTALERT_VERSION}

VOLUME ["${RULES_DIRECTORY}"]

RUN mkdir -p ${RULES_DIRECTORY}
RUN python ${ELASTALERT_HOME}/${ELASTALERT_VERSION}/setup.py install

COPY ./config/default.config.yaml ${ELASTALERT_HOME}/${ELASTALERT_VERSION}/config.yaml

COPY ./config/config_visa.yaml ${ELASTALERT_HOME}/${ELASTALERT_VERSION}/config_visa.yaml

COPY ./start-elastalert.sh /opt/start-elastalert.sh
RUN chmod +x /opt/start-elastalert.sh

ENTRYPOINT ["/opt/start-elastalert.sh"]
CMD ["/usr/bin/python", "-m", "elastalert.elastalert", "--verbose"]
