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

# Install Buildbot master
RUN set -ex \
    && python3 -m pip install buildbot==2.5.1 buildbot_travis==0.6.4 buildbot_badges==2.5.1

COPY buildbot_master.sh /

RUN set -ex \
    && chmod +x /buildbot_master.sh

WORKDIR /var/lib/buildbot

ENTRYPOINT ["/usr/bin/dumb-init", "--"]
CMD ["bash", "/buildbot_master.sh"]
HEALTHCHECK CMD curl --fail http://localhost:8010/api/v2 || exit 1
ENV BUILDBOT_MASTER_URL="http://192.168.188.111:8010/"

RUN set -ex \
    && sed -i 's/command=command, doStepIf=not self.disable)/command=command, doStepIf=not self.disable, timeout=7200)/' /usr/local/lib/python3.7/dist-packages/buildbot_travis/steps/create_steps.py

RUN set -ex \
    && sed -i "s/worker.Worker(name, password=config\['password'\])/worker.Worker(name, password=config\['password'\], max_builds=1)/" /usr/local/lib/python3.7/dist-packages/buildbot_travis/configurator.py

RUN set -ex \
    && sed -i 's/waitForFinish=True/waitForFinish=False/' /usr/local/lib/python3.7/dist-packages/buildbot_travis/steps/spawner.py


