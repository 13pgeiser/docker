# Install Python3, Git and ssh, ...
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

