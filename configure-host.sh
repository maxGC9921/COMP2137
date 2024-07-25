#!/bin/bash

trap '' TERM HUP INT

VERBOSE=false
HOSTNAME="/etc/hostname"
HOSTS="/etc/hosts"
NETPLAN="/etc/netplan/10-lxc.yaml"

logMessage() {
    local message="$1"
    if $VERBOSE; then
        echo "$message"
    fi
    logger "$message"
}

updateHostname() {
    local desiredName="$1"
    local currentName=$(hostname)

    if [ "$currentName" != "$desiredName" ]; then
        echo "$desiredName" > "$HOSTNAME"
        hostname "$desiredName"
        logMessage "Hostname changed from $currentName to $desiredName"
        
        # Update /etc/hosts with the new hostname
        sudo sed -i "s/$currentName/$desiredName/g" "$HOSTS"
        logMessage "Updated hostname in $HOSTS from $currentName to $desiredName"
    else
        if $VERBOSE; then
            echo "Hostname is already set to $desiredName"
        fi
    fi
}



updatedIp() {
    local interface="$1"
    local ipAddress="$2"
    if ! [[ "$ipAddress" =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}$ ]]; then
        echo "Invalid IP address format: $ipAddress"
        exit 1
    fi

    currentIp=$(ip addr show dev "$interface" | awk '/inet / {print $2}' | cut -d '/' -f 1)
    if [ "$currentIp" == "$ipAddress" ]; then
        logMessage "IP address of $interface is already $ipAddress. No change needed."
    else
        sudo ip addr flush dev "$interface"
        sudo ip addr add "$ipAddress/24" dev "$interface"
        sudo ip link set "$interface" up
        logMessage "IP address of $interface changed from $currentIp to $ipAddress"
   
        sudo sed -i "s/\b$currentIp\b/$ipAddress/g" "$HOSTS"
        logMessage "Updated IP address in $HOSTS from $currentIp to $ipAddress"
   
        sudo sed -i "s/\b$currentIp\b/$ipAddress/g" "$NETPLAN"
        logMessage "Updated IP address in $NETPLAN from $currentIp to $ipAddress"

        sudo netplan apply
    fi
}

if [ "$#" -lt 4 ]; then
    echo "Usage: $0 -name <hostname> -ip <ip_address> [-v]"
    exit 1
fi

while [ "$#" -gt 0 ]; do
    case $1 in
        -v)
            VERBOSE=true
            ;;
        -name)
            shift
            desiredName="$1"
            ;;
        -ip)
            shift
            ipAddress="$1"
            ;;
        *)
            echo "Unknown parameter passed: $1"
            exit 1
            ;;
    esac
    shift
done

updateHostname "$desiredName"

updatedIp "eth0" "$ipAddress"




