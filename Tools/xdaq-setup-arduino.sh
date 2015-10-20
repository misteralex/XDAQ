#!/bin/bash

#########################################################################
# xdaq-setup-arduino.sh                                                 #
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

# SETTING
XDAQ_CATEGORY=CORE
XDAQ_PACKAGE=Arduino_IDE
XDAQ_SUPPORT=DESKTOP

ARDUINOPACKAGE=arduino-nightly-linux32.tar.xz


# XDAQ package manager functions (Setup/Status/Support)
function Setup()
{
  	Setup_Java

  	echo -e "\nInstall Arduino IDE (Package: $ARDUINOPACKAGE}"
    rm -rf $HOMEDEV/Arduino_BACK
    mv $HOMEDEV/Arduino $HOMEDEV/Arduino_BACK
    echo "Previous Arduino user context (i.e. ~/Arduino) is preserved for XDAQ user purposes (i.e. ~/Arduino_BACK)."
    echo

  	package_root=`echo $ARDUINOPACKAGE|awk -F'-' '{print $1"-"$2}'`
  	cd /tmp
  	rm -rf $ARDUINOPACKAGE $package_root
  	wget http://arduino.cc/download.php?f=/$ARDUINOPACKAGE -O $ARDUINOPACKAGE
  	tar xvf $ARDUINOPACKAGE $package_root/revisions.txt
  	ARDUINOVER=`cat arduino-nightly/revisions.txt|head -n1|awk -F' ' '{print $2}'`
  	rm -rf /opt/arduino*
  	mkdir /opt/arduino-$ARDUINOVER
  	tar xvf $ARDUINOPACKAGE -C /opt/arduino-$ARDUINOVER --strip-components=1
  	if [ -d /opt/arduino-$ARDUINOVER ];
  	then
  		chown -R $USERDEV:$USERDEV /opt/arduino-$ARDUINOVER
  		rm -rf arduino-$ARDUINOVER-linux32.tar.xz
  		rm -rf /usr/local/bin/arduino
  		ln -fs /opt/arduino-$ARDUINOVER/arduino /usr/local/bin/arduino
  		cp -f $HOMEDEV/XDAQ/Admin/xdaq-arduino.desktop $GNOME_SHARE_APPS
  		cp -f $HOMEDEV/XDAQ/Admin/xdaq-arduino-logo.png $GNOME_SHARE_ICONS

  		# Check Arduino user folders
  		if [ ! -d $HOMEDEV/Arduino ];
  		then
    			mkdir $HOMEDEV/Arduino
  	  		mkdir $HOMEDEV/Arduino/libraries
  		  	mkdir $HOMEDEV/Arduino/hardware
          chown -R $USERDEV:$USERDEV $HOMEDEV/Arduino
  		fi
  	else
  		echo "*** Installation Error. Try again Arduino IDE setup process."
  	fi
}

function Status()
{
    GetPackageVersion "Arduino IDE"	"arduino" "echo $ARDUINOVER" "$XDAQ_SUPPORT"
}

source ./xdaq-setup-main.sh
