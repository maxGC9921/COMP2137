#!/bin/bash
#This script shows loooping and  testing
function networkreport {
	interfaces="$( ip l|
		     grep -v link|
		     awk '{print $2}'|
       	             grep -v @| 
		     sed s/:// )"
			
			
	for interface in $interfaces; do
		printf "$interface : "
		address="$(ip a s $interfaces| awk '/inet /{print $2}')"
		if [ -n "$address" ]; then
			echo $address
		else
		    echo "No address assigned"
		fi 
	done

}


networkreport
