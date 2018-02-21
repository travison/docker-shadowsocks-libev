#
# Dockerfile for shadowsocks-libev
#

FROM alpine:edge
MAINTAINER Travison

ARG SS_VER=3.1.3
ARG SS_OBFS_VER=0.0.5

ARG SS_URL=https://github.com/shadowsocks/shadowsocks-libev/archive/v$SS_VER.tar.gz
ARG SS_OBFS_URL=https://github.com/shadowsocks/simple-obfs/archive/v$SS_OBFS_VER.tar.gz

RUN set -ex && \
    apk add --no-cache --virtual .build-deps \
                                git \
                                libnet1 \
                                libnet1-dev \
                                libpcap0.8 \
                                libpcap0.8-dev \
                                autoconf \
                                automake \
                                make \
                                build-base \
                                curl \
                                libev-dev \
                                libtool \
                                linux-headers \
                                udns-dev \
                                libsodium-dev \
                                mbedtls-dev \
                                pcre-dev \
                                tar \
                                c-ares-dev && \

    cd /tmp/ && \
    git clone https://github.com/snooda/net-speeder.git && \
    cd net-speeder && \
    sh build.sh && \
    mv net_speeder /usr/local/bin/ && \
    chmod +x /usr/local/bin/net_speeder && \
    cd /tmp/ && \
    git clone https://github.com/shadowsocks/shadowsocks-libev.git && \
    cd shadowsocks-libev && \
    git checkout v$SS_VER && \
    git submodule update --init --recursive && \
    ./autogen.sh && \
    ./configure --prefix=/usr --disable-documentation && \
    make install && \
    cd /tmp/ && \
    git clone https://github.com/shadowsocks/simple-obfs.git shadowsocks-obfs && \
    cd shadowsocks-obfs && \
    git checkout v$SS_OBFS_VER && \
    git submodule update --init --recursive && \
    ./autogen.sh && \
    ./configure --prefix=/usr --disable-documentation && \
    make install && \
    cd .. && \

    runDeps="$( \
        scanelf --needed --nobanner /usr/bin/ss-* \
            | awk '{ gsub(/,/, "\nso:", $2); print "so:" $2 }' \
            | xargs -r apk info --installed \
            | sort -u \
    )" && \
    apk add --no-cache --virtual .run-deps $runDeps && \
    apk del .build-deps && \
    rm -rf /tmp/*


ENV SERVER_ADDR 0.0.0.0
ENV SERVER_PORT 8388
ENV PASSWORD 1234567890
ENV METHOD aes-256-gcm
ENV TIMEOUT 600
ENV DNS_ADDR 8.8.4.4
ENV PLUGIN obfs-server
ENV PLUGIN_OPTS obfs=tls
ENV USER nobody

EXPOSE $SERVER_PORT/tcp
EXPOSE $SERVER_PORT/udp

COPY docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
