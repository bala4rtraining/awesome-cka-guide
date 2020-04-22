FROM ovn-docker.artifactory.trusted.visa.com/centos7_ovn_common:latest




# User/Group
ENV MY_USER="mysql"
ENV MY_GROUP="mysql"
ENV MY_UID="48"
ENV MY_GID="48"

# Files
ENV MYSQL_BASE_INCL="/etc/my.cnf.d"
ENV MYSQL_CUST_INCL1="/etc/mysql/conf.d"
ENV MYSQL_CUST_INCL2="/etc/mysql/docker-default.d"
ENV MYSQL_DEF_DAT="/var/lib/mysql"
ENV MYSQL_DEF_LOG="/var/log/mysql"
ENV MYSQL_DEF_PID="/var/run/mysqld"
ENV MYSQL_DEF_SCK="/var/sock/mysqld"

ENV MYSQL_LOG_SLOW="${MYSQL_DEF_LOG}/slow.log"
ENV MYSQL_LOG_ERROR="${MYSQL_DEF_LOG}/error.log"
ENV MYSQL_LOG_QUERY="${MYSQL_DEF_LOG}/query.log"

###
### Install
###
RUN groupadd -g ${MY_GID} -r ${MY_GROUP} && \
	adduser ${MY_USER} -u ${MY_UID} -M -s /sbin/nologin -g ${MY_GROUP}



RUN  yum -y install \
	mysql-community-server




##
## Configure
##
RUN \
	rm -rf ${MYSQL_BASE_INCL} && \
	rm -rf ${MYSQL_CUST_INCL1} && \
	rm -rf ${MYSQL_CUST_INCL2} && \
	rm -rf ${MYSQL_DEF_DAT} && \
	rm -rf ${MYSQL_DEF_SCK} && \
	rm -rf ${MYSQL_DEF_PID} && \
	rm -rf ${MYSQL_DEF_LOG} && \
	\
	mkdir -p ${MYSQL_BASE_INCL} && \
	mkdir -p ${MYSQL_CUST_INCL1} && \
	mkdir -p ${MYSQL_CUST_INCL2} && \
	mkdir -p ${MYSQL_DEF_DAT} && \
	mkdir -p ${MYSQL_DEF_SCK} && \
	mkdir -p ${MYSQL_DEF_PID} && \
	mkdir -p ${MYSQL_DEF_LOG} && \
	\
	chown -R ${MY_USER}:${MY_GROUP} ${MYSQL_BASE_INCL} && \
	chown -R ${MY_USER}:${MY_GROUP} ${MYSQL_CUST_INCL1} && \
	chown -R ${MY_USER}:${MY_GROUP} ${MYSQL_CUST_INCL2} && \
	chown -R ${MY_USER}:${MY_GROUP} ${MYSQL_DEF_DAT} && \
	chown -R ${MY_USER}:${MY_GROUP} ${MYSQL_DEF_SCK} && \
	chown -R ${MY_USER}:${MY_GROUP} ${MYSQL_DEF_PID} && \
	chown -R ${MY_USER}:${MY_GROUP} ${MYSQL_DEF_LOG} && \
	\
	chmod 0775 ${MYSQL_BASE_INCL} && \
	chmod 0775 ${MYSQL_CUST_INCL1} && \
	chmod 0775 ${MYSQL_CUST_INCL2} && \
	chmod 0775 ${MYSQL_DEF_DAT} && \
	chmod 0775 ${MYSQL_DEF_SCK} && \
	chmod 0775 ${MYSQL_DEF_PID} && \
	chmod 0775 ${MYSQL_DEF_LOG}



RUN \
	echo "[client]"                                         > /etc/my.cnf && \
	echo "socket = ${MYSQL_DEF_SCK}/mysqld.sock"           >> /etc/my.cnf && \
	\
	echo "[mysql]"                                         >> /etc/my.cnf && \
	echo "socket = ${MYSQL_DEF_SCK}/mysqld.sock"           >> /etc/my.cnf && \
	\
	echo "[mysqld]"                                        >> /etc/my.cnf && \
	echo "skip-host-cache"                                 >> /etc/my.cnf && \
	echo "skip-name-resolve"                               >> /etc/my.cnf && \
	echo "datadir = ${MYSQL_DEF_DAT}"                      >> /etc/my.cnf && \
	echo "user = ${MY_USER}"                               >> /etc/my.cnf && \
	echo "port = 3306"                                     >> /etc/my.cnf && \
	echo "bind-address = 0.0.0.0"                          >> /etc/my.cnf && \
	echo "socket = ${MYSQL_DEF_SCK}/mysqld.sock"           >> /etc/my.cnf && \
	echo "pid-file = ${MYSQL_DEF_PID}/mysqld.pid"          >> /etc/my.cnf && \
	echo "general_log_file = ${MYSQL_LOG_QUERY}"           >> /etc/my.cnf && \
	echo "slow_query_log_file = ${MYSQL_LOG_SLOW}"         >> /etc/my.cnf && \
	echo "log-error = ${MYSQL_LOG_ERROR}"                  >> /etc/my.cnf && \
	echo "group_concat_max_len=1000000"                    >> /etc/my.cnf && \
	echo "!includedir ${MYSQL_BASE_INCL}/"                 >> /etc/my.cnf && \
	echo "!includedir ${MYSQL_CUST_INCL1}/"                >> /etc/my.cnf && \
	echo "!includedir ${MYSQL_CUST_INCL2}/"                >> /etc/my.cnf


COPY overlay /
RUN chmod +x /Mysqlfiles/fileupload.sh
COPY build/webapp  /usr/local/bin/

EXPOSE 8090

VOLUME /var/lib/mysql
VOLUME /var/log/mysql
VOLUME /var/sock/mysqld
VOLUME /etc/mysql/conf.d
VOLUME /etc/mysql/docker-default.d


RUN chmod +x docker-entrypoint.sh

ENTRYPOINT ["/docker-entrypoint.sh"]
