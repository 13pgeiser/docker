# vim:set ft=dockerfile:
# VERSION=1
include(`debian_base.m4')

# Install Python3, Git and ssh
RUN set -ex \
    && apt-get update \
    && apt-get dist-upgrade -y \
    && apt-get install -y --no-install-recommends \
    dumb-init \
    curl \
    python3-pip \
    python3-dev \
    build-essential \
    git \
    openssh-client \
    sudo \
    libcairo-gobject2 \
    && python3 -m pip install --upgrade pip setuptools wheel virtualenv \
    && apt-get clean \
    && rm -rf /var/cache/apt/archives/* /var/lib/apt/lists/*

# Install Twisted
RUN set -ex \
    && python3 -m pip install twisted==19.10.0 service_identity==18.1.0

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


