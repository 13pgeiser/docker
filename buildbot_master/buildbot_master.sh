#!/bin/bash
export LC_ALL=C
currdir="$(pwd)"
mkdir -p master/public_html/releases/
chmod 777 master/
chmod 777 master/public_html/
chmod 777 master/public_html/releases/
if [ ! -d master ]; then
  buildbot create-master master
fi
if [ -e master.cfg ]; then
  mv master.cfg master/
  mv buildbot.tac master/
fi
echo "$BUILDBOT_REPOS" | tr \; \\n | while read repository
do
  name="${repository##*/}"
  echo "---------------------------------------------------------"
  echo "$name"
  echo "---------------------------------------------------------"
  folder="$currdir/master/$name"
  if [ ! -d "$folder" ]; then
    mkdir -p "$folder"
    cd "$folder"
    git config --global init.defaultBranch master
    git init
    git remote add origin "$repository"
    git sparse-checkout init
    git sparse-checkout set ".buildbot"
    git sparse-checkout list
  fi
  cd "$folder"
  git pull origin master
done
cd "$currdir"
echo "starting nginx"
/usr/sbin/nginx &
echo "Starting buildbot"
cd master
figlet "upgrade"
buildbot upgrade-master
figlet "checkconfig"
buildbot checkconfig
figlet "start"
buildbot start --nodaemon
