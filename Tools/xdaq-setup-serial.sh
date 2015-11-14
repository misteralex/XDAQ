#!/bin/bash

#########################################################################
# xdaq-setup-serial.sh                                                  #
#                                                                       #
# This script is part of XDAQ v1.1   Open Source Software Ecosystem     # 
# Copyright (C) 2015 by AF                                              #
#                                                                       #
# It is free software: you can redistribute it and/or                   #
# modify it under the terms of the GNU General Public License           #
# as published by the Free Software Foundation, either version 3 of     #
# the License, or (at your option) any later version.                   #
#                                                                       #
# It is distributed in the hope that it will be useful,                 #
# but WITHOUT ANY WARRANTY; without even the implied warranty of        #
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the          #
# GNU General Public License for more details.                          #
#                                                                       #
# You should have received a copy of the GNU General Public License     #
# along with this program.                                              #
# If not, see <http://www.gnu.org/licenses/>                            #
#########################################################################

source ./xdaq-shared.sh

# SERIAL PORT

	# Serial Port configuration
	COM_SETTING="115200 -parenb -parodd cs8 -hupcl -cstopb cread clocal -crtscts -ignbrk -brkint -ignpar -parmrk inpck -istrip -inlcr -igncr -icrnl -ixon -ixoff -iuclc -ixany -imaxbel -iutf8 -opost -olcuc -ocrnl -onlcr -onocr -onlret -ofill -ofdel nl0 cr0 tab0 bs0 vt0 ff0 -isig -icanon -iexten -echo -echoe -echok -echonl -noflsh -xcase -tostop -echoprt -echoctl -echoke"

	check_com=TRUE
	max_attempts=5
	while [[ $check_com == TRUE && $max_attempts > 0 ]]
	do
    COM=`ls -l /sys/class/tty/ttyA* 2>/dev/null |awk -F'/' '{print $NF}'`
		if [ "$COM" == "" ];
    then 
       COM=`ls -l /sys/class/tty/ttyU* 2>/dev/null |awk -F'/' '{print $NF}'`
    fi

		if [ "$COM" == "" ];
		then
			echo "WARNING: expected serial port does not work."
			echo "Please check standard serial Arduino board connection."
			echo "and check WMware Player > Removable Devices > Arduino XXX > Connect"
			echo "Arduino Serial Port within XDAQ environment has default value of 115200 bps."
			echo
	
			echo -n "Try again " ; sleep .3
			read -e -i Y -p "(Y/n)? " ; echo
			if [[ $REPLY =~ ^[Nn]$ ]]; then check_com=FALSE ; fi
		else
			check_com=FALSE
		fi
		
		# Exit after 5 attempts
		max_attempts=$(($max_attempts - 1))
	done

	if [ "$COM" != "" ];
  then
    echo -e "\n[SETUP] Default Serial Port for Arduino connection: $COM\n"

		# Set permissions
		echo "Grant permissions to <$USERDEV> to use Arduino Serial Port ($COM)"
		adduser $USERDEV dialout
		chmod a+rw /dev/$COM

		# Set serial port configuration
		stty -F /dev/$COM $COM_SETTING
		echo -e "\nArduino Serial Port configured."
	fi
