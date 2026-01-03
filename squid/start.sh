#!/bin/bash
set -ex
echo "Updating list of blocked domains"
curl -sS -L --compressed "http://pgl.yoyo.org/adservers/serverlist.php?hostformat=nohtml&showintro=0&mimetype=plaintext" > /etc/squid/ad_block.txt
echo "Starting bind9"
echo "192.168.0.222 debiand843e635fb7" >>/etc/hosts
/etc/init.d/named start
echo "Starting squid..."
/usr/sbin/squid -z
/etc/init.d/squid start
sleep 1
tail -f /var/log/squid/*

