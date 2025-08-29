#!/bin/bash
export LC_ALL=C
pwd
ls -al
mkdir -p master/public_html/releases/
chmod 777 master/
chmod 777 master/public_html/
chmod 777 master/public_html/releases/
if [ ! -e master/master.cfg ]; then
  buildbot create-master master
fi
if [ -e master.cfg ]; then
  mv master.cfg master/
fi
/usr/sbin/nginx &
buildbot start master
sleep 10
tail -f master/*.log