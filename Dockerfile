FROM docker.io/library/ubuntu:26.04

RUN apt-get update && \
    apt-get install -y --no-install-recommends bind9 bind9utils && \
    rm -rf /var/lib/apt/lists/*

COPY named.conf /etc/bind/named.conf

COPY named.conf.options /etc/bind/named.conf.options

COPY named.conf.local /etc/bind/named.conf.local

COPY transfer.key /etc/bind/transfer.key

#RUN mkdir -p /var/cache/bind && \
RUN chown -R bind:bind /var/cache/bind && \
    chmod 775 /var/cache/bind

RUN chown root:bind /etc/bind/transfer.key && \
    chmod 640 /etc/bind/transfer.key

EXPOSE 53/tcp
EXPOSE 53/udp

#USER bind

CMD ["/usr/sbin/named", "-g", "-u", "bind", "-c", "/etc/bind/named.conf"]
