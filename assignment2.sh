#!/bin/bash

################################################################
#################### IP CONFIGURATION ##########################
################################################################

cat /etc/hosts
echo " "

#This command will quietly checked if the ip address for eth0 is 192.168.16.200/24
ip addr show eth0 | grep -q '192.168.16.200/24'
#If the last command was successful, then sed -i is used to replace the old ip address with the new one that is located in /etc/netplan/10-lxc.yaml and netplan apply will apply the configuration.
if [ $? -eq 0 ]; then
     sudo sed -i 's/192.168.16.200/192.168.16.21/' /etc/netplan/10-lxc.yaml
     sudo netplan apply
     sudo sed -i 's/^192.168.16.200\s\+server1/192.168.16.21\tserver1/g' /etc/hosts
else
    echo "The address 192.168.16.200 has already been replaced"
fi

################################################################
#################### APACHE2 AND SQUID #########################
################################################################

#This command will verify if apache2 is already installed
dpkg-query -l | grep apache2

#If the last command is succesful than the user will be notified that apache2 is already installed. Else, it will be installed for the user
if [ $? -eq 0 ]; then
	echo "Apache 2 is already installed"
else
	echo "################################################################"
	echo "Apache 2 will be installed"
	echo "################################################################"
	sudo apt install apache2 -y
fi

#This command will verify if squid is already installed
dpkg-query -l | grep squid
#If the last command is succesful than the user will be notified that squid is already installed. Else, it will be installed for the user
if [ $? -eq 0 ]; then
	echo "Squid is already installed"
else
	echo "################################################################"
	echo "Squid will be installed"
	echo "################################################################"
	sudo apt install squid -y
fi

################################################################
########################## UFW #################################
################################################################

#The following line of codes will allow ufw, enable ssh port 22 only on the mgmt network, allow http on both interfaces

which ufw

if [ $? -eq 1 ]; then
	echo "################################################################"
	echo "UFW will be installed"
	echo "################################################################"
	sudo apt install ufw -y
else
	echo "There is a problem with the UFW configuration"
	
fi

which ufw

if [ $? -eq 0 ]; then
	sudo ufw enable
	sudo ufw allow proto tcp from 172.16.1.200 to any port 22
	sudo ufw allow 80/tcp
	sudo ufw allow 3128
else
	echo "Something went wrong when applying the rules"
fi

################################################################
###################### USERS ###################################
################################################################

#The following commands will add dennis while also adding him to the sudo group. He will also received ssh keys for rsa and ed25519 algorithms
adduser dennis
usermod -aG sudo dennis
ssh-keygen -t ed25519

#All the other users have been assigned to the variable users
users=("aubrey" "captain" "snibbles" "brownie" "scooter" "sandy" "perrier" "cindy" "tiger" "yoda")
#A For loop is used to automate the adduser process for all of the users while also giving them ssh keys for rsa and ed25519 algorithms
for user in "${users[@]}"
do
    adduser $user
    ssh-keygen -t ed25519
    cat ~/id_rsa.pub >> ~/.ssh/authorized_keys
    echo "################################################################"

done
