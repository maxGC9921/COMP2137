#!/bin/bash

trap '' TERM HUP INT

read -p "Enter the new hostname: " userHostname

if [ -z "$userHostname" ]; then
    echo "No hostname entered. Exiting."
    exit 1
fi

sudo hostnamectl set-hostname "$userHostname"

if [ $? -eq 0 ]; then
    echo "Hostname changed to: $userHostname"
else
    echo "Failed to change hostname."
fi

read -p "Enter the new IP address: " newIp

if [ -z "$newIp" ]; then
    echo "No IP address entered. Exiting."
    exit 1
fi

networkDevice=$(ip route get 1 | awk '{print $5}')

#sudo ip addr replace "$newIp" dev "$networkDevice"

#sudo sed -i 's/192.168.16.200/192.168.16.21/' /etc/netplan/10-lxc.yaml
#sudo netplan apply
#sudo sed -i 's/^192.168.16.200\s\+server1/192.168.16.21\tserver1/g' /etc/hosts

sudo sed -i "s/\b[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\b/$newIp/" /etc/netplan/10-lxc.yaml
sudo netplan apply
sudo sed -i "s/^\([0-9]\{1,3\}\.\)\{3\}[0-9]\{1,3\}\s\+server1/$newIp\tserver1/" /etc/hosts




if [ $? -eq 0 ]; then
    echo "IP address changed to: $newIp"
else
    echo "Failed to change IP address."
fi

