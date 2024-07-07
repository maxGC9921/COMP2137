#!/bin/bash

cat /etc/hosts
echo " "

apache2=$(dpkg-query -l | grep apache2)

squid=$(dpkg-query -l | grep squid)

ip addr show eth0 | grep -q '192.168.16.200/24'

if [ $? -eq 0 ]; then
     ifconfig eth0 down;
     ifconfig eth0 192.168.16.200 255.255.255.0;
     ifconfig eth0 up
else
    echo "Something went wrong"
fi
