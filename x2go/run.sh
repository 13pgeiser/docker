#!/bin/bash
if [ ! -f /.configured ]; then
  echo "root:insecure" | chpasswd
  adduser --disabled-password --gecos "" docker
  echo "docker:insecure" | chpasswd
  usermod -a -G chrome-remote-desktop docker
  mkdir -p /home/docker/.config/chrome-remote-desktop
  chown -R docker:docker /home/docker/.config
  adduser docker sudo
  touch /.configured
fi
