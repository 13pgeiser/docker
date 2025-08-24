# Debian base.
FROM debian:trixie-slim
MAINTAINER Pascal Geiser <pgeiser@pgeiser.com>

ENV DEBIAN_FRONTEND=noninteractive

# Upgrade
RUN set -ex \
    && apt-get update \
    && apt-get -y dist-upgrade \
    && apt-get clean \
    && rm -rf /var/cache/apt/archives/* /var/lib/apt/lists/*

