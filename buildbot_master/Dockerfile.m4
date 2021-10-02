# vim:set ft=dockerfile:
# VERSION=2
include(`debian_base.m4')
include(`buildbot_base.m4')

# Install Buildbot master
RUN set -ex \
    && python3 -m pip install \
        lz4==3.1.3 \
        buildbot==3.3.0 \
        buildbot-www==3.3.0 \
        buildbot_badges==3.3.0 \
        buildbot-waterfall-view==3.3.0 \
        buildbot-console-view==3.3.0 \
        buildbot-grid-view==3.3.0

# Install Python3, Git and ssh, ...
RUN set -ex \
    && apt-get update \
    && apt-get dist-upgrade -y \
    && apt-get install -y --no-install-recommends \
      privoxy \
      net-tools \
    && apt-get clean \
    && rm -rf /var/cache/apt/archives/* /var/lib/apt/lists/*

add privoxy.sh /privoxy.sh
WORKDIR /var/lib/buildbot
ADD services.conf services.conf
ADD buildbot_master.sh buildbot_master.sh
HEALTHCHECK CMD curl --fail http://localhost:8010/api/v2 || exit 1
ENV BUILDBOT_MASTER_URL="http://127.0.0.1:8010/"
ENV BUILDBOT_WORKER_NAME=buildbot_worker
ENV BUILDBOT_WORKER_PASS=pass
ENV LC_ALL=C
CMD ["supervisord","-c","/var/lib/buildbot/services.conf"]
