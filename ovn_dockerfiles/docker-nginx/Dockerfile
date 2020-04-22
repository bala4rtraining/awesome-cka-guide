FROM nginx:1.11.5-alpine

RUN set -xe \
    && apk add -U git-gitweb fcgiwrap spawn-fcgi perl-cgi \
    && rm -rf /var/cache/apk/*

COPY overlay /

CMD spawn-fcgi -s /var/run/fcgiwrap.socket -u nginx /usr/bin/fcgiwrap > dev/null 2> /dev/null & \
    exec nginx -g "daemon off;"
