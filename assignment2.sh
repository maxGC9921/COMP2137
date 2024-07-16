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
	echo "----------------------------------------------------------------"
	echo "The old address 192.168.16.200 will be replace with 192.168.16.21 on server1"
	sudo sed -i 's/192.168.16.200/192.168.16.21/' /etc/netplan/10-lxc.yaml
	sudo netplan apply
	sudo sed -i 's/^192.168.16.200\s\+server1/192.168.16.21\tserver1/g' /etc/hosts
else
	echo "----------------------------------------------------------------"
	echo "The address 192.168.16.200 doesn't exist"
fi



################################################################
#################### APACHE2 AND SQUID #########################
################################################################

#This command will verify if apache2 is already installed
dpkg-query -l | grep apache2


#If the last command is succesful than the user will be notified that apache2 is already installed.
# Else, an update will take place before the packages are installed. Following the update, apache2 is installed.

if [ $? -eq 0 ]; then
	echo "----------------------------------------------------------------"
	echo "Apache 2 is already installed"
else
	echo "----------------------------------------------------------------"
	echo "An update is taking place before the installation of apache2 and squid"
	sudo apt update -y >/dev/null 2>&1
	echo "----------------------------------------------------------------"
	echo "Apache2 is being installed"
	sudo apt install apache2 -y >/dev/null 2>&1
fi

#This command will verify if squid is already installed
dpkg-query -l | grep squid
#If the last command is succesful than the user will be notified that squid is already installed. Else, it will be installed for the user. Yes is inputed for the user to automate the install
if [ $? -eq 0 ]; then
	echo "----------------------------------------------------------------"
	echo "Squid is already installed"
else
	echo "----------------------------------------------------------------"
	echo "Squid will be installed"
	sudo apt install squid -y >/dev/null 2>&1
fi

################################################################
########################## UFW #################################
################################################################

#Which ufw is used to verify if ufw is already installed. 

which ufw >/dev/null 2>&1
#If the last line was not successful, ufw will be installed and then a verifcation will occur to ensure the installation was a success.
#Else the user will be notified if it's already installed.
if [ $? -eq 1 ]; then
	echo "----------------------------------------------------------------"
	echo "UFW will be installed"
	echo "----------------------------------------------------------------"
	sudo apt install ufw -y >/dev/null 2>&1
	if [ $? -eq 0 ]; then
		echo "UFW installation was a success !"
	else
		echo "A problem has occured during the installation of UFW"
		exit 1 
	fi	
else
	echo "----------------------------------------------------------------"
	echo "UFW is already installed"
fi

#Which ufw is used to verify if ufw is already installed. 
which ufw >/dev/null 2>&1
#If the last line was successfull
#then the following line of codes will allow ufw, enable ssh port 22 only on the mgmt network, allow http on both interfaces and finally allow web proxy on both interfaces.
#Else the user will notified of an error when applying the rules
if [ $? -eq 0 ]; then
	echo "y" | sudo ufw enable >/dev/null 2>&1
	sudo ufw allow proto tcp from 172.16.1.200 to any port 22 >/dev/null
	sudo ufw allow 80/tcp >/dev/null
	sudo ufw allow 3128 >/dev/null
	echo "----------------------------------------------------------------"
	echo "Rules for UFW are being applied"
else
	echo "----------------------------------------------------------------"
	echo "An error regarding the UFW rules occured"
	echo "----------------------------------------------------------------"
fi

################################################################
###################### USERS ###################################
################################################################

#The following commands will verify if Dennis already exists than useradd him if he does not. The line also makes bash the default shell
echo "----------------------------------------------------------------"
echo "Adding Dennis"
if ! id -u dennis >/dev/null 2>&1; then
	sudo useradd -m -d /home/dennis -s /bin/bash dennis >/dev/null
else
	echo "User Dennis already exists"
fi
#His account will be given sudo privileges along by creating the directory .ssh and make him the only one that has access to it
usermod -aG sudo dennis >/dev/null
mkdir -p /home/dennis/.ssh >/dev/null
chown -R dennis:dennis /home/dennis/.ssh >/dev/null
chmod 700 /home/dennis/.ssh >/dev/null

#The following if statement will test if Dennis already has an ed25519 algorithm key, if he doesn't then he will receive it.
if [ ! -f "/home/dennis/.ssh/id_ed25519" ]; then
	ssh-keygen -t ed25519 -f /home/dennis/.ssh/id_ed25519 -N "" >/dev/null
fi
#The following if statement will test if Dennis already has an RSA algorithm key, if he doesn't then he will receive it.
if [ ! -f "/home/dennis/.ssh/id_rsa" ]; then
	sudo -u dennis ssh-keygen -t rsa -b 4096 -N "" -f "/home/dennis/.ssh/id_rsa" -C "dennis@$(hostname)" >/dev/null
fi
#The following if statement will test if Dennis already has an authorized_keys file. If he doesn't, it will be created and given the proper permissions.
if [ ! -f "/home/dennis/.ssh/authorized_keys" ]; then
	sudo touch /home/dennis/.ssh/authorized_keys >/dev/null
	sudo chmod 600 /home/dennis/.ssh/authorized_keys >/dev/null
	sudo chown dennis:dennis /home/dennis/.ssh/authorized_keys >/dev/null
fi

#The following if statement will verify if the provided key is already present in authorized_keys file. If not, it will be appended.
if ! grep -q "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIG4rT3vTt99Ox5kndS4HmgTrKBT8SKzhK4rhGkEVGlCI student@generic-vm" /home/dennis/.ssh/authorized_keys; then
	echo "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIG4rT3vTt99Ox5kndS4HmgTrKBT8SKzhK4rhGkEVGlCI student@generic-vm" >> /home/dennis/.ssh/authorized_keys	
fi
#All the other users have been assigned to the variable users
users=("aubrey" "captain" "snibbles" "brownie" "scooter" "sandy" "perrier" "cindy" "tiger" "yoda")
#A For loop is used to automate the useradd process for all of the users while also giving them ssh keys for rsa and ed25519 algorithms
for user in "${users[@]}"
do 
	echo "----------------------------------------------------------------"
	echo "Adding $user"
	#The following commands will verify if the user already exists than useradd them if they don't. The line also makes bash their default shell
	if ! id -u $user >/dev/null 2>&1; then
        	sudo useradd -m -d /home/$user -s /bin/bash $user >/dev/null
	else
	        echo "User $user already exists"
        fi
        ##The following if statement will test if the user already has an ed25519 algorithm key, if he doesn't then he will receive it.
    	if [ ! -f "/home/$user/.ssh/id_ed25519" ]; then
		sudo -u $user ssh-keygen -t ed25519 -N "" -f "/home/$user/.ssh/id_ed25519" -C "$user@$(hostname)" >/dev/null
        fi
        ##The following if statement will test if the user already has an RSA algorithm key, if he doesn't then he will receive it.
    	if [ ! -f "/home/$user/.ssh/id_rsa" ]; then
		sudo -u $user ssh-keygen -t rsa -b 4096 -N "" -f "/home/$user/.ssh/id_rsa" -C "$user@$(hostname)" >/dev/null
        fi
        #The following lines will create the directory, give proper permissions and ownerships to both .ssh directory and authorized_keys file, append the keys to the authorized_keys file.
    	sudo mkdir -p /home/$user/.ssh >/dev/null 2>&1
    	sudo chmod 700 /home/$user/.ssh >/dev/null
    	sudo chown $user:$user /home/$user/.ssh >/dev/null
    	cat /home/$user/.ssh/id_ed25519.pub >> /home/$user/.ssh/authorized_keys >/dev/null
    	cat /home/$user/.ssh/id_rsa.pub >> /home/$user/.ssh/authorized_keys >/dev/null
    	sudo chmod 600 /home/$user/.ssh/authorized_keys >/dev/null
    	sudo chown $user:$user /home/$user/.ssh/authorized_keys >/dev/null
done

