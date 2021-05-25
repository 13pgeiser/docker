# vim:set ft=dockerfile:
# VERSION=2
include(`debian_base.m4')
include(`buildbot_base.m4')

# Install Buildbot master
RUN set -ex \
    && python3 -m pip install \
        buildbot==3.1.1 \
        buildbot-www==3.1.1 \
        buildbot_badges==3.1.1 \
        buildbot-waterfall-view==3.1.1 \
        buildbot-console-view==3.1.1 \
        buildbot-grid-view==3.1.1

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


