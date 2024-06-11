#!/bin/bash
userName=$USER
dateTime="$(date)"
hostnameReport="$(hostname)" 
#This line will print only the name of the Operating System with the version
operatingSystem="$(grep 'PRETTY_NAME' /etc/os-release | cut -d'"' -f2)"
timeUp="$(uptime -p)"
#This line will print info on the CPU, the delimiter will remove the "Model name" from the output while awk while be used to bring closer the output to "cpu:"
cpuInfo="$(lscpu | grep 'Model name: ' | cut -d " " -f3- | awk '{$1=$1;print}')"
cpuSpeed="$(grep 'cpu MHz' /proc/cpuinfo | cut -d ":" -f2 | uniq && sudo dmidecode -t processor | grep "Speed" | uniq | head -n 1 | awk '{$1=$1;print}')"
ramInfo="$(hwinfo --memory | grep 'Memory Size' | cut -d ":" -f2)"
diskInfo="$(lshw -class disk | grep 'product' | cut -d ":" -f2 | awk '{$1=$1;print}'| uniq)"
videoCard="$(lshw -C display | grep vendor | cut -d ":" -f2 && lshw -C display | grep product | cut -d ":" -f2 )"
fqdnInfo="$(sudo hostname -f)"
hostAddress="$(hostname -I)"
gatewayAddress="$(ip route | grep 'default' |  cut -d " " -f3- | cut -d " " -f1)"
dnsAddress="$(grep -i nameserver /etc/resolv.conf |head -1| awk '{print $2}')"
interfaceName="$(hwinfo --network --short | cut -d " " -f3-)"
ipAddresses="$(ip r)"
loggedUser="$(who -u)"
spaceDiskMounted="$(df -h)"
countProcess="$(ps)"
averageLoad="$(cat /proc/loadavg)"
allocatedMemory="$(free -h)"
listenNetwork="$(sudo ss -tunlp)"
rulesUfw="$(sudo ufw status)"
cat <<EOF

System Report generated by $userName, $dateTime
 
System Information
------------------
Hostname: $hostnameReport
OS: $operatingSystem
Uptime: $timeUp
 
Hardware Information
--------------------
cpu: $cpuInfo
Speed: $cpuSpeed
Ram: $ramInfo
Disk(s): $diskInfo
Video: $videoCard
 
Network Information
-------------------
FQDN:$fqdnInfo
Host Address: $hostAddress
Gateway IP: $gatewayAddress
DNS Server: $dnsAddress
 
InterfaceName: $interfaceName
IP Address: $ipAddresses
 
System Status
-------------
Users Logged In: $loggedUser
Disk Space: $spaceDiskMounted
Process Count: $countProcess
Load Averages: $averageLoad
Memory Allocation: $allocatedMemory
Listening Network Ports: $listenNetwork
UFW Rules: $rulesUfw

EOF
