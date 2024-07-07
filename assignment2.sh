#!/bin/bash

cat /etc/hosts
echo " "


ip addr show eth0 | grep -q '192.168.16.200/24'

if [ $? -eq 0 ]; then
     sudo sed -i 's/192.168.16.200/192.168.16.21/' /etc/netplan/10-lxc.yaml
     sudo netplan apply
     sudo sed -i 's/192.168.16.200/192.168.16.21/' /etc/hosts
else
    echo "The address 192.168.16.200 has already been replaced"
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
	sudo apt install squid -y
fi



#sudo ufw allow proto tcp from 172.16.1.200 to any port 22

