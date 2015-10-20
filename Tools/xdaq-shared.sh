#!/bin/bash

#########################################################################
# xdaq-shared.sh                                                        #
#                                                                       #
# This script is part of XDAQ v1.1.0 Open Source Software Ecosystem     # 
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

# OS Restart  
function VMReboot() 
{	
	echo -n "Reboot OS now " ; sleep .3
	read -e -i Y -p "(Y/n)? "
	if [[ $REPLY =~ ^[Yy]$ ]];
	then
		echo "XDAQ is rebooting..."
		reboot
		exit
	fi
	echo
}


# Get current OS release (DEBIAN, UBUNTU, NODEBIAN)
function GetOSVersion()
{
    OSVERSION="NODEBIAN"
    kernel_ver=`uname -r|awk -F'-' '{print $1}'|awk -F'.' '{print $1}'`
    kernel_subver=`uname -r|awk -F'-' '{print $1}'|awk -F'.' '{print $2}'`

	  # DEBIAN
    if uname -a | grep -qi "DEBIAN" ; then
       if [[ $kernel_ver == 3 ]]; then 
	        if [[ $kernel_subver < 3 ]]; then OSVERSION="WHEEZY" ; fi
	        if [[ $kernel_subver > 2 ]]; then OSVERSION="JESSIE" ; fi
	     fi
       
       if [[ $kernel_ver > 3 ]]; then OSVERSION="JESSIE" ; fi
    fi

    # UBUNTU
    if uname -a | grep -qi "UBUNTU" ; then
	     OSVERSION="UBUNTU"
    fi
}



# Check User Administrator access
function CheckAccess()
{
  if [[ $1 != 0 ]];
  then
      echo "WARNING: This script must be executed as root."
      return 0
  fi

  return 1
}


# Check DESKTOP/ARDUINO/PYTHON environments
function CheckMainEnvironments()
{
	# Flag about Desktop Environment setup
	DESKTOP_SUPPORT=""
	if [ -z `which xdaq-desktop` ];
	then
		DESKTOP_SUPPORT="(Require a Desktop Environment)"
	fi

	# Flag about Arduino IDE setup
	ARDUINO_SUPPORT=""
	ARDUINOVER=""
	arduino_path=`which arduino`
	if [ -z $arduino_path ];
	then
		ARDUINO_SUPPORT="(Require Arduino)"
	else
		ARDUINOVER=`readlink -f $arduino_path | awk -F/ '{print $3}' | awk -F'-' '{print $2}'`
	fi

	# Flag about PYTHON setup
	PYTHON_SUPPORT=""
	if [ -z `which python` ];
	then
		PYTHON_SUPPORT="(Require Python)"
	fi

  if [[ "$XDAQ_SUPPORT" == "DEBIAN" ]]; then XDAQ_SUPPORT= ; fi
  if [[ "$XDAQ_SUPPORT" == "DESKTOP" ]]; then XDAQ_SUPPORT=$DESKTOP_SUPPORT ; fi
  if [[ "$XDAQ_SUPPORT" == "ARDUINO" ]]; then XDAQ_SUPPORT=$ARDUINO_SUPPORT ; fi
  if [[ "$XDAQ_SUPPORT" == "PYTHON" ]]; then XDAQ_SUPPORT=$PYTHON_SUPPORT ; fi
  if [[ "$XDAQ_SUPPORT" == "EXTRA" ]]; then XDAQ_SUPPORT= ; fi
}


#
# GLOBAL FLAGS
#


GetOSVersion
if [[ "$OSVERSION" == "NODEBIAN" ]];
then
	echo
	echo "WARNING: No Debian based distribution."
	echo "XDAQ is tested under releases: Debian Jessie, Debian Wheezy and Ubuntu (14.04)."
	echo "More info at www.embeddedrevolution.info"
	echo
fi

USERDEV=`who am i | awk '{print $1}'`
HOMEDEV=/home/$USERDEV

if [ "$USERDEV" == "" ];
then
	echo "Please specify User Account where is installed XDAQ environment."
	echo "Default Arduino user account: <arduinodev>"
	echo "More info at www.embeddedrevolution.info"
	exit
fi

if [ ! -d $HOMEDEV ];
then
	echo "Please check the Account name."
	echo "The Account <$HOMEDEV> does not exist."
	echo "More info at www.embeddedrevolution.info"
	exit
fi 

if [ ! -d $HOMEDEV/XDAQ ];
then
	echo "Please install XDAQ environment."
	echo "More info at www.embeddedrevolution.info"
	exit
fi



#
# GLOBAL CONST
#
XDAQVER=`cat $HOMEDEV/XDAQ/revisions.txt |head -1|awk -F' ' '{print $2}'`

XDAQ_LOG_FILE=/var/log/xdaq-setup.log
XDAQ_REPORT_FILE=/var/log/xdaq-packages.log
XDAQ_SETUP_FILE=$HOMEDEV/XDAQ/Tools/xdaq-setup-list
GNOME_SHARE_APPS=/usr/share/applications
GNOME_SHARE_ICONS=/usr/share/icons/gnome/256x256
CHECK_KEYBOARD_COMMAND="cat /etc/default/keyboard | awk -F'=' '/XKBLAYOUT/ {print \$2}'"

XDAQVER=`cat $HOMEDEV/XDAQ/revisions.txt |head -1|awk -F' ' '{print $2}'`
HOME_TOOLS=$HOMEDEV/XDAQ/Tools
HOME_EXAMPLES=$HOMEDEV/XDAQ/Examples
HOME_ARDUINO=""
HOME_ARDUINO_LIB=$HOMEDEV/Arduino
COM=""
