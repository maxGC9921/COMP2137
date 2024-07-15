#!/bin/bash

################################################################
#################### IP CONFIGURATION ##########################
################################################################

#This command will quietly checked if the ip address for eth0 is 192.168.16.200/24
ip addr show eth0 | grep -q '192.168.16.200/24'

#If the last command was successful, then sed -i is used to replace the old ip address with the new one that is located in /etc/netplan/10-lxc.yaml and netplan apply will apply the configuration.
#sed -i will also replace the old address where server1 is located with new addresss
#Else the user will be notified that the address 192.168.16.200 does not exist anymore

if [ $? -eq 0 ]; then
	echo "################################################################"
	echo "The old address 192.168.16.200 will be replace with 192.168.16.21 on server1"
	echo "################################################################"
	sudo sed -i 's/192.168.16.200/192.168.16.21/' /etc/netplan/10-lxc.yaml
	sudo netplan apply
	sudo sed -i 's/^192.168.16.200\s\+server1/192.168.16.21\tserver1/g' /etc/hosts
else
	echo "################################################################"
	echo "The address 192.168.16.200 doesn't exist"
	echo "################################################################"
fi

#Could be better checked 

################################################################
#################### APACHE2 AND SQUID #########################
################################################################

#This command will verify if apache2 is already installed
dpkg-query -l | grep apache2

#If the last command is succesful than the user will be notified that apache2 is already installed. Else, it will be installed for the user. Yes is inputed for the user to automate the install
if [ $? -eq 0 ]; then
	echo "################################################################"
	echo "Apache 2 is already installed"
	echo "################################################################"
else
	echo "################################################################"
	echo "Apache 2 will be installed"
	echo "################################################################"
	sudo apt install apache2 -y >/dev/null 2>&1
fi

#This command will verify if squid is already installed
dpkg-query -l | grep squid
#If the last command is succesful than the user will be notified that squid is already installed. Else, it will be installed for the user. Yes is inputed for the user to automate the install
if [ $? -eq 0 ]; then
	echo "################################################################"
	echo "Squid is already installed"
	echo "################################################################"
else
	echo "################################################################"
	echo "Squid will be installed"
	echo "################################################################"
	sudo apt install squid -y >/dev/null 2>&1
fi

################################################################
########################## UFW #################################
################################################################

#Which ufw is used to verify if ufw is already installed. If the last line was not successful, ufw will be installed. Else the user will be notified if it's already installed or there was an error

which ufw >/dev/null 2>&1

if [ $? -eq 1 ]; then
	echo "################################################################"
	echo "UFW will be installed"
	echo "################################################################"
	sudo apt install ufw -y >/dev/null 2>&1
	#check that the install worked
else
	echo "################################################################"
	echo "UFW is either already installed or there was a problem in it's configuration"
	echo "################################################################"
fi

which ufw >/dev/null 2>&1

#The following line of codes will allow ufw, enable ssh port 22 only on the mgmt network, allow http on both interfaces and finally allow web proxy on both interfaces.
#Else the user will notified of an error when applying the rules

if [ $? -eq 0 ]; then
	echo "y" | sudo ufw enable >/dev/null 2>&1
	sudo ufw allow proto tcp from 172.16.1.200 to any port 22 >/dev/null
	sudo ufw allow 80/tcp >/dev/null
	sudo ufw allow 3128 >/dev/null
else
	echo "################################################################"
	echo "Something went wrong when applying the rules"
	echo "################################################################"
fi

################################################################
###################### USERS ###################################
################################################################

#The following commands will add dennis while also adding him to the sudo group. He will also received ssh keys for rsa and ed25519 algorithms

echo "########################### Adding Dennis #####################################"
if ! id -u dennis >/dev/null 2>&1; then
	sudo useradd dennis >/dev/null
else
	echo "User $user already exists"
fi
usermod -aG sudo dennis >/dev/null
mkdir -p /home/dennis/.ssh >/dev/null
if [ ! -f "/home/dennis/.ssh/id_ed25519" ]; then
	ssh-keygen -t ed25519 -f /home/dennis/.ssh/id_ed25519 -N "" >/dev/null
fi

if ! grep -q "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIG4rT3vTt99Ox5kndS4HmgTrKBT8SKzhK4rhGkEVGlCI student@generic-vm" /home/dennis/.ssh/authorized_keys; then
	echo "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIG4rT3vTt99Ox5kndS4HmgTrKBT8SKzhK4rhGkEVGlCI student@generic-vm" >> /home/dennis/.ssh/authorized_keys
	chmod 700 /home/dennis/.ssh >/dev/null
	chmod 600 /home/dennis/.ssh/authorized_keys >/dev/null
fi
echo "################################################################"
#All the other users have been assigned to the variable users
#A For loop is used to automate the useradd process for all of the users while also giving them ssh keys for rsa and ed25519 algorithms
#Within the loop, verifications are in place to ensure that the user and their keys don't already exist. Directories are created, made executable, ownerships are changed
users=("aubrey" "captain" "snibbles" "brownie" "scooter" "sandy" "perrier" "cindy" "tiger" "yoda")
for user in "${users[@]}"
do
	echo "####################### Adding $user #########################################"
	if ! id -u $user >/dev/null 2>&1; then
        	sudo useradd -m -d /home/$user -s /bin/bash $user >/dev/null
	else
	        echo "User $user already exists"
        fi
    	if [ ! -f "/home/$user/.ssh/id_ed25519" ]; then
		sudo -u $user ssh-keygen -t ed25519 -N "" -f "/home/$user/.ssh/id_ed25519" -C "$user@$(hostname)" >/dev/null
        fi
    	if [ ! -f "/home/$user/.ssh/id_rsa" ]; then
		sudo -u $user ssh-keygen -t rsa -b 4096 -N "" -f "/home/$user/.ssh/id_rsa" -C "$user@$(hostname)" >/dev/null
        fi
    	sudo mkdir -p /home/$user/.ssh >/dev/null 2>&1
    	sudo chmod 700 /home/$user/.ssh >/dev/null
    	sudo chown $user:$user /home/$user/.ssh >/dev/null
    	cat /home/$user/.ssh/id_ed25519.pub | sudo tee -a /home/$user/.ssh/authorized_keys >/dev/null
    	cat /home/$user/.ssh/id_rsa.pub | sudo tee -a /home/$user/.ssh/authorized_keys >/dev/null
    	sudo chmod 600 /home/$user/.ssh/authorized_keys >/dev/null
    	sudo chown $user:$user /home/$user/.ssh/authorized_keys >/dev/null
    	echo "###############################################################"
done

