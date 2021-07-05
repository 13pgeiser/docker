# vim:set ft=dockerfile:
# VERSION=2
include(`debian_base.m4')
include(`buildbot_base.m4')

# Install Buildbot master
RUN set -ex \
    && python3 -m pip install \
        lz4==3.1.3 \
        buildbot==3.2.0 \
        buildbot-www==3.2.0 \
        buildbot_badges==3.2.0 \
        buildbot-waterfall-view==3.2.0 \
        buildbot-console-view==3.2.0 \
        buildbot-grid-view==3.2.0

COPY buildbot_master.sh /

RUN set -ex \
    && chmod +x /buildbot_master.sh

WORKDIR /var/lib/buildbot

ENTRYPOINT ["/usr/bin/dumb-init", "--"]
CMD ["bash", "/buildbot_master.sh"]
HEALTHCHECK CMD curl --fail http://localhost:8010/api/v2 || exit 1
ENV BUILDBOT_MASTER_URL="http://127.0.0.1:8010/"
ENV BUILDBOT_WORKER_NAME=buildbot_worker
ENV BUILDBOT_WORKER_PASS=pass
ENV LC_ALL=C


