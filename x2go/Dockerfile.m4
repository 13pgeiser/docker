# vim:set ft=dockerfile:
# VERSION=1
include(`debian_base.m4')

# Install X2GO
RUN set -ex \
    && apt-get update \
    && apt-get dist-upgrade -y \
    && apt-get install -y --no-install-recommends \
      supervisor \
      openssh-server \
      x2goserver \
      socat \
      locales \
      console-setup \
      keyboard-configuration \
      sudo \
      less \
      mc \
      unzip \
      bzip2 \
      file \
      xz-utils \
    && apt-get clean \
    && rm -rf /var/cache/apt/archives/* /var/lib/apt/lists/*

RUN cp /usr/share/zoneinfo/Europe/Zurich /etc/localtime && \
    echo "Europe/Zurich" >  /etc/timezone

ENV TZ=Europe/Zurich

RUN sed -i 's/# fr_CH.UTF-8 UTF-8/fr_CH.UTF-8 UTF-8/' /etc/locale.gen && \
    sed -i 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen && \
    ln -fs /etc/locale.alias /usr/share/locale/locale.alias && \
    locale-gen && update-locale LANG=en_US.UTF-8

RUN mkdir -p /var/run/sshd \
  && mkdir -p /tmp/.X11-unix \
  && chmod 1777 /tmp/.X11-unix \
  && sed -i "s/UsePrivilegeSeparation.*/UsePrivilegeSeparation no/g" /etc/ssh/sshd_config \
  && sed -i "s/UsePAM.*/UsePAM no/g" /etc/ssh/sshd_config \
  && sed -i "s/PermitRootLogin.*/PermitRootLogin yes/g" /etc/ssh/sshd_config \
  && sed -i "s/#PasswordAuthentication/PasswordAuthentication/g" /etc/ssh/sshd_config

# Install XFCE
RUN set -ex \
    && apt-get update \
    && apt-get dist-upgrade -y \
    && apt-get install -y --no-install-recommends \
      task-xfce-desktop \
      atril \
      dbus-x11 \
      mousepad \
      system-config-printer \
      tango-icon-theme \
      xfce4-goodies \
      xfce4-terminal \
    && apt-get clean \
    && rm -rf /var/cache/apt/archives/* /var/lib/apt/lists/*

# Install firefox, chrome
RUN set -ex \
    && apt-get update \
    && apt-get dist-upgrade -y \
    && apt-get install -y --no-install-recommends \
      chromium \
      firefox-esr \
    && apt-get clean \
    && rm -rf /var/cache/apt/archives/* /var/lib/apt/lists/*

VOLUME ["/home", "/shared-data"]
ADD run.sh /run.sh
EXPOSE 22
WORKDIR /root
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]

