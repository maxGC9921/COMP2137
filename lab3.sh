#!/bin/bash

VERBOSE=false

logMessage() {
    local message="$1"
    if $VERBOSE; then
        echo "$message"
    fi
    logger "$message"
}

errorExit() {
    local message="$1"
    echo "$message" >&2
    exit 1
}

while [ "$#" -gt 0 ]; do
    case $1 in
        -v)
            VERBOSE=true
            ;;
        *)
            echo "Unknown option or argument: $1"
            echo "Usage: $0 [-v]"
            exit 1
            ;;
    esac
    shift
done

transferExecution() {
    local server="$1"
    local arguments="$2"

    logMessage "Transferring configure-host.sh to $server"
    scp configure-host.sh remoteadmin@"$server":/root || errorExit "Failed to transfer script to $server"

    logMessage "Executing configure-host.sh on $server"
    ssh remoteadmin@"$server" "bash /root/configure-host.sh $arguments $( [ "$VERBOSE" = true ] && echo '-v' )" || errorExit "Failed to execute script on $server"
}

transferExecution "server1-mgmt" "-name loghost -ip 192.168.16.3 -hostentry webhost 192.168.16.4"

transferExecution "server2-mgmt" "-name webhost -ip 192.168.16.4 -hostentry loghost 192.168.16.3"

logMessage "Updating local /etc/hosts file"
./configure-host.sh -hostentry loghost 192.168.16.3 $( [ "$VERBOSE" = true ] && echo '-v' )
./configure-host.sh -hostentry webhost 192.168.16.4 $( [ "$VERBOSE" = true ] && echo '-v' )

logMessage "Script execution completed"

