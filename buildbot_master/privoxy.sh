#!/bin/bash
IP=$(/sbin/ifconfig eth0 | grep 'inet ' | tr -s ' ' | cut -d" " -f3)
if ! grep -q "listen-address  $IP:8118" /etc/privoxy/config
then
        echo "listen-address  $IP:8118" >>/etc/privoxy/config
fi
privoxy --no-daemon /etc/privoxy/config
