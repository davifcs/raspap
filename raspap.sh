#!/bin/bash
#RaspAP is intented to configure the RaspberryPi 3 as an access point.

declare -i valid=0
declare -i ipclass=0
dnsmasq_status=$(dpkg-query -f '${Status}' -W dnsmasq)
hostapd_status=$(dpkg-query -f '${Status}' -W hostapd)

if ! [ "$dnsmasq_status" == "install ok installed" ]; then
	while true
	do
		read -p "It is necessary to install the package dnsmasq. Whish to? [Y/n]? " answer
		case $answer in
			[yY] ) apt-get install dnsmasq
			break;;

			[nN] )
			while true
				do
					read -p "dnsmasq is necessary to configure RaspberryPi as an access point.
Are you sure you do not want to install it [Y/n]?" answer2
					case $answer2 in
						[yY] ) exit;;
						[nN] ) break;;
						* ) echo -e "Enter just Y or N, please.";
					esac
				done;;

			* ) echo -e "Enter just Y or N, please.";
		esac
	done
else
	echo "dnsmasq is already installed."
fi

if ! [ "$hostapd_status" == "install ok installed" ] ; then
	while true
	do
		read -p "It is necessary to install the package hostpad. Whish to? [Y/n]? " answer
		case $answer in
			[yY] ) apt-get install hostpad
			break;;

			[nN] )
			while true
				do
					read -p "hostpad is necessary to configure RaspberryPi as an access point.
Are you sure you do not want to install it [Y/n]?" answer2
					case $answer2 in
						[yY] ) exit;;
						[nN] ) break;;
						* ) echo -e "Enter just Y or N, please.";
					esac
				done;;

			* ) echo -e "Enter just Y or N, please.";
		esac
	done
else
	echo "hostpad is already installed."
fi


while true
	do
		read -p "Enter access point (Raspberry pi) IPv4 address. " ip
		declare -a part=( ${ip//\./ } )
		for p in ${part[@]} ; do
			if [[ $p =~ ^[[:digit:]]+$ ]] ; then
				((valid += p>>8 ))
				((ipclass += 1))
			else
				((valid++))
			fi
		done

		if [ $valid = 0 ] && [ $ipclass = 4 ] ; then

			echo -e "\niface wlan0 inet static\n   address $ip\n   netmask 255.255.255.0" >> /etc/network/interfaces

			echo -e "$ip defined as Raspberry Wireless IPv4 "

			break
		else
			echo -e "$ip is not a valid IPv4 adress, please enter a valid one."
		fi
		ipclass=0
	done

if [ -e /etc/dnsmasq.conf ]; then
	echo "exists"
else
	echo "Could not find ""/etc/dnsmasq.conf"". Try to manually apt-get install dnsmasq.conf "
fi
