#!/bin/bash

cat /etc/hosts
echo " "


ip addr show eth0 | grep -q '192.168.16.200/24'

#if [ $? -eq 0 ]; then
#     ifconfig eth0 down;
#     ifconfig eth0 192.168.16.21 255.255.255.0;
#     ifconfig eth0 up
#else
#    echo "Something went wrong"
#fi




dpkg-query -l | grep apache2

if [ $? -eq 0 ]; then
	echo "Apache 2 is already installed"
else
	apt install apache2
fi

dpkg-query -l | grep squid

if [ $? -eq 0 ]; then
	echo "Squid is already installed"
else
	apt install sqid
fi
