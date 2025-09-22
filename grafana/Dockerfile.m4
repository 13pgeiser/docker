# vim:set ft=dockerfile:
# VERSION=1
include(`debian_base.m4')

RUN set -ex \
  && apt-get update \
  && apt-get dist-upgrade -y \
  && apt-get install -y --no-install-recommends \
    wget \
    ca-certificates \
    dumb-init \
  && apt-get clean \
  && rm -rf /var/cache/apt/archives/* /var/lib/apt/lists/*

RUN set -ex \
  && wget https://dl.grafana.com/grafana/release/12.1.1/grafana_12.1.1_16903967602_linux_amd64.tar.gz \
  && tar -zxvf grafana_12.1.1_16903967602_linux_amd64.tar.gz \
  && rm grafana_12.1.1_16903967602_linux_amd64.tar.gz \
  && mv /grafana-12.1.1 /grafana

ARG USER=grafana
ARG UID=1000
ARG GID=1000
RUN groupadd -g $GID -o $USER
RUN useradd -m -u $UID -g $GID -o -s /bin/bash $USER
RUN set -ex \
  && chown -R grafana:users /grafana
WORKDIR /grafana
EXPOSE 3000
ENTRYPOINT ["/usr/bin/dumb-init", "--"]
CMD ["bash", "-c", "mkdir -p /grafana/data && chown -R grafana:users /grafana/data && su grafana -s /grafana/bin/grafana server"]