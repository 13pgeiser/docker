# vim:set ft=dockerfile:
# VERSION=6
include(`debian_base.m4')

# Install squid and bind9
RUN set -ex \
    && apt-get update \
    && apt-get dist-upgrade -y \
    && apt-get install -y --no-install-recommends \
      bind9 \
      squid \
      squidclient \
      ca-certificates \
      dumb-init \
      curl \
    && apt-get clean \
    && rm -rf /var/cache/apt/archives/* /var/lib/apt/lists/*

COPY squid.conf /etc/squid/squid.conf
COPY named.conf.options /etc/bind/named.conf.options
COPY start.sh /
EXPOSE 3128
ENTRYPOINT ["/usr/bin/dumb-init", "--"]
CMD ["bash", "start.sh"]
HEALTHCHECK --interval=5m --timeout=10s \
  CMD squidclient -h 127.0.0.1 cache_object://127.0.0.1/counters || exit 1

