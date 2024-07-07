#!/bin/bash

cat /etc/hosts
echo " "


ip addr show eth0 | grep -q '192.168.16.200/24'

if [ $? -eq 0 ]; then
     sudo sed -i 's/192.168.16.200/192.168.16.22/' /etc/netplan/10-lxc.yaml
     sudo netplan apply
else
    echo "Something went wrong"
fi




dpkg-query -l | grep apache2

if [ $? -eq 0 ]; then
	echo "Apache 2 is already installed"
else
	sudo apt install apache2
fi

dpkg-query -l | grep squid

if [ $? -eq 0 ]; then
	echo "Squid is already installed"
else
	sudo apt install sqid
fi
