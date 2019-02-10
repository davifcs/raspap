#!/bin/bash
#RaspAP is intented to configure the RaspberryPi 3 as an access point.

declare -i valid=0
declare -i ipclass=0
dnsmasq_status=$(dpkg-query -f '${Status}' -W dnsmasq);
hostapd_status=$(dpkg-query -f '${Status}' -W hostapd);

function validateIP()
        {
         local ip=$1
         local stat=1
         if [[ $ip =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
                OIFS=$IFS
                IFS='.'
                ip=($ip)
                IFS=$OIFS
                [[ ${ip[0]} -le 255 && ${ip[1]} -le 255 \
                && ${ip[2]} -le 255 && ${ip[3]} -le 255 ]]
                stat=$?
        fi        
        return $stat
}

if [ "$dnsmasq_status" == "install ok installed" ]; then
	echo "dnsmasq is already installed."
else
	while ! [ "$dnsmasq_status" == "install ok installed" ];
		do
			read -p "It is necessary to install the package dnsmasq. Whish to? [Y/n]? " answer
			case $answer in
				[yY] ) apt-get install dnsmasq
				break;;
				[nN] )
				while true
					do
						read -p "dnsmasq is necessary to configure RaspberryPi as an access point. Are you sure you do not want to install it [Y/n]?" answer2
						case $answer2 in
							[yY] ) exit;;
							[nN] ) break;;
							* ) echo -e "Enter just Y or N, please.";
						esac
					done;;

				* ) echo -e "Enter just Y or N, please.";
			esac
		done
fi


if [ "$hostapd_status" == "install ok installed" ]; then	
	echo "hostpad is already installed."
else
	while ! [ "$hostapd_status" == "install ok installed" ];
		do 		
			read -p "It is necessary to install the package hostpad. Whish to? [Y/n]? " answer
			case $answer in
				[yY] ) apt-get install hostapd
				break;;
				[nN] )
				while true
					do
						read -p "hostpad is necessary to configure RaspberryPi as an access point.Are you sure you do not want to install it [Y/n]?" answer2
						case $answer2 in
							[yY] ) exit;;
							[nN] ) break;;
							* ) echo -e "Enter just Y or N, please.";
						esac
					done;;
				* ) echo -e "Enter just Y or N, please.";
			esac
		done
fi


while true
	do
		read -p "Enter access point (Raspberry Pi) IPv4 address. " ip		
		validateIP $ip		
		if [[ $? -ne 0 ]]; then
			echo -e "$ip is not a valid IPv4 adress, please enter a valid one."		
		else			
			echo -e "\ninterface wlan0\n   static ip_address=$ip/24\n   nohook wpa_supplicant">> /etc/dhcpcd.conf
			echo -e "$ip defined as Raspberry Wireless IPv4 "					
			break
		fi
	done

if [ -e /etc/dnsmasq.conf ]; then

	OIFS=$IFS
	IFS='.'
	ip=($ip)
	IFS=$OIFS
	ipStart=$((${ip[3]}+1))
	ipEnd=$((${ip[3]}+20))
	
	echo -e "\ninterface=wlan0\n   wlan0\n   dhcp-range=${ip[0]}.${ip[1]}.${ip[2]}.$ipStart,${ip[0]}.${ip[1]}.${ip[2]}.$ipEnd,255.255.255.0,24h">> /etc/dnsmasq.conf
else
	echo "Could not find ""/etc/dnsmasq.conf"". Try to manually apt-get install dnsmasq.conf "
fi



