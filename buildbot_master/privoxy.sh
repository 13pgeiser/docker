#!/bin/bash
IP=$(/sbin/ifconfig eth0 | grep 'inet ' | tr -s ' ' | cut -d" " -f3)
echo "listen-address  $IP:8118" >>/etc/privoxy/config
privoxy --no-daemon /etc/privoxy/config
