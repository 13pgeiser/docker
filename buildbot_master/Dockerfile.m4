# vim:set ft=dockerfile:
# VERSION=3
include(`debian_base.m4')

# Install Python3, Git and ssh, ...
RUN set -ex \
    && apt-get update \
    && apt-get dist-upgrade -y \
    && apt-get install -y --no-install-recommends \
      dumb-init \
      python3-pip \
      python3-setuptools \
      python3-virtualenv \
      python3-wheel \
      python3-dev \
      libcairo2 \
      git \
      nginx \
      supervisor \
      nano \
      vim \
      figlet \
    && apt-get clean \
    && rm -rf /var/cache/apt/archives/* /var/lib/apt/lists/*

# Install Twisted
#RUN set -ex \
#    && python3 -m pip install twisted==25.5.0  service-identity==24.2.0  --break-system-packages

RUN set -ex \
    && python3 -m pip install twisted==24.3.0  service-identity==24.1.0  --break-system-packages

# Install Buildbot master
RUN set -ex \
    && python3 -m pip install \
        lz4==4.4.4 \
        certifi == 2025.8.3 \
        buildbot==4.0.1 \
        buildbot-www==4.0.1 \
        buildbot-badges==4.0.1 \
        buildbot-waterfall-view==4.0.1 \
        buildbot-console-view==4.0.1 \
        buildbot-grid-view==4.0.1 \
        buildbot-wsgi-dashboards==4.0.1 \
        --break-system-packages

WORKDIR /var/lib/buildbot
ADD buildbot.py buildbot.tac
ADD master.py master.cfg
ADD buildbot_master.sh buildbot_master.sh
ADD buildbot-site /etc/nginx/sites-available/default
# HEALTHCHECK CMD curl --fail http://localhost:8010/api/v2 || exit 1
ENV BUILDBOT_MASTER_URL="http://127.0.0.1:8010/"
ENV BUILDBOT_WORKER_NAME=buildbot_worker
ENV BUILDBOT_WORKER_PASS=pass
ENV LC_ALL=C
CMD bash buildbot_master.sh
