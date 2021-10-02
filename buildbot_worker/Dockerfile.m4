# vim:set ft=dockerfile:
# VERSION=2
include(`debian_base.m4')
include(`buildbot_base.m4')

# Setup docker
include(`docker.m4')

# Install Buildbot worker
RUN set -ex \
    && python3 -m pip install buildbot-worker==3.3.0

COPY buildbot_worker.sh /
RUN set -ex \
    && chmod +x /buildbot_worker.sh

ADD daemon.json /etc/docker/daemon.json
WORKDIR /var/lib/buildbot
ADD services.conf services.conf
ADD buildbot_worker.sh buildbot_worker.sh

ENV BUILDBOT_MASTER=buildbot_master
ENV BUILDBOT_WORKER_NAME=buildbot_worker
ENV BUILDBOT_WORKER_PASS=pass

ENV HTTP_PROXY="http://buildbot_master:8118/"
ENV HTTPS_PROXY="http://buildbot_master:8118/"
ENV http_proxy="http://buildbot_master:8118/"
ENV https_proxy="http://buildbot_master:8118/"

CMD ["supervisord","-c","/var/lib/buildbot/services.conf"]
