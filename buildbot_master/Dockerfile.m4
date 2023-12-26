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
    && apt-get clean \
    && rm -rf /var/cache/apt/archives/* /var/lib/apt/lists/*

# Install Twisted
RUN set -ex \
    && python3 -m pip install twisted==23.10.0 service_identity==23.1.0  --break-system-packages

# Install Buildbot master
RUN set -ex \
    && python3 -m pip install \
        lz4==4.3.2 \
        buildbot==3.10.0 \
        buildbot-www==3.10.0 \
        buildbot_badges==3.10.0 \
        buildbot-waterfall-view==3.10.0 \
        buildbot-console-view==3.10.0 \
        buildbot-grid-view==3.10.0 \
        --break-system-packages

WORKDIR /var/lib/buildbot
ADD services.conf services.conf
ADD buildbot_master.sh buildbot_master.sh
ADD buildbot-site /etc/nginx/sites-available/default
# HEALTHCHECK CMD curl --fail http://localhost:8010/api/v2 || exit 1
ENV BUILDBOT_MASTER_URL="http://127.0.0.1:8010/"
ENV BUILDBOT_WORKER_NAME=buildbot_worker
ENV BUILDBOT_WORKER_PASS=pass
ENV LC_ALL=C
CMD ["supervisord","-c","/var/lib/buildbot/services.conf"]
