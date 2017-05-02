FROM nginx

MAINTAINER Weiyan Shao "lighteningman@gmail.com"

WORKDIR /root

ENV DOCKER_GEN_VERSION 0.7.0

ADD https://github.com/just-containers/s6-overlay/releases/download/v1.11.0.1/s6-overlay-amd64.tar.gz /tmp/
ADD https://github.com/jwilder/docker-gen/releases/download/$DOCKER_GEN_VERSION/docker-gen-linux-amd64-$DOCKER_GEN_VERSION.tar.gz /tmp/
ADD https://raw.githubusercontent.com/diafygi/acme-tiny/daba51d37efd7c1f205f9da383b9b09968e30d29/acme_tiny.py /bin/acme_tiny

RUN tar xzf /tmp/s6-overlay-amd64.tar.gz -C / &&\
    tar -C /bin -xzf /tmp/docker-gen-linux-amd64-$DOCKER_GEN_VERSION.tar.gz && \
    rm /tmp/docker-gen-linux-amd64-$DOCKER_GEN_VERSION.tar.gz && \
    rm /tmp/s6-overlay-amd64.tar.gz && \
    rm /etc/nginx/conf.d/default.conf && \
    apt-get update && \
    apt-get install -y python ruby cron && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

COPY ./fs_overlay/bin/reconfig /bin/reconfig
COPY ./fs_overlay/opt/certs_manager/ /opt/certs_manager/
COPY ./fs_overlay/etc/docker-gen/ /etc/docker-gen/
COPY ./fs_overlay/etc/cron.weekly/ /etc/cron.weekly/
COPY ./fs_overlay/etc/services.d/ ./fs_overlay/etc/services.d/
COPY ./fs_overlay/etc/cont-init.d/ /etc/cont-init.d/
COPY ./fs_overlay/var/lib/nginx-conf/ /var/lib/nginx-conf/
COPY ./fs_overlay/var/www/vhosts/ /var/www/vhosts/
COPY ./fs_overlay/var/www/default/ /var/www/default/

RUN chmod a+x /bin/* && chmod a+x /etc/cron.weekly/renew_certs

VOLUME /var/lib/https-portal

ENTRYPOINT ["/init"]
