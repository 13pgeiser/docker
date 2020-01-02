# vim:set ft=dockerfile:
# VERSION=1
include(`debian_base.m4')
include(`buildbot_base.m4')

# Setup docker
include(`docker.m4')

# Install Buildbot worker
RUN set -ex \
    && python3 -m pip install buildbot-worker==2.5.1

COPY buildbot_worker.sh /

RUN set -ex \
    && chmod +x /buildbot_worker.sh

WORKDIR /var/lib/buildbot

ENV BUILDBOT_MASTER=localhost
ENV BUILDBOT_WORKER_NAME=buildbot_worker
ENV BUILDBOT_WORKER_PASS=pass

ENTRYPOINT ["/usr/bin/dumb-init", "--"]
CMD ["bash", "/buildbot_worker.sh"]


