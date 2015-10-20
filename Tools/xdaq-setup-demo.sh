#!/bin/bash

#########################################################################
# xdaq-setup-demo.sh                                                    #
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
XDAQ_CATEGORY=OPTIONAL
XDAQ_PACKAGE=Demo
XDAQ_SUPPORT=ARDUINO

LIB_WASPMOTEVER=04
LIB_PLUGSENSEVER=02
SUNBED_SODAQVER=Rev.4
LT_LINDUINOVER=Rev.3659


function Setup_LibeliumWaspmote()
{
  echo
	echo "This option will install a Libelium product."
	echo "The Waspmote Pro IDE v$LIB_WASPMOTEVER (Wireless sensor networks open source platform)"
	echo "WARNING: Hardware is from manufacturer (only open source code)"
	echo

	package_name=waspmote-pro-ide-v$LIB_WASPMOTEVER-linux32
	cd /tmp
	rm -rf $package_name*
	wget http://downloads.libelium.com/$package_name.zip -O $package_name.zip
  unzip $package_name.zip
	rm -rf /opt/waspmote*
	mv $package_name /opt
	ln -sf /opt/$package_name/waspmote /usr/local/bin/waspmote
	chown -R $USERDEV:$USERDEV /opt/$package_name
	cp -f $HOMEDEV/XDAQ/Admin/xdaq-libelium-waspmote.desktop $GNOME_SHARE_APPS
	cp -f $HOMEDEV/XDAQ/Admin/xdaq-libelium-logo.png $GNOME_SHARE_ICONS

	echo "Install Plug & Sense!"
	cp $HOMEDEV/XDAQ/Admin/xdaq-libelium-plug-sense.desktop $GNOME_SHARE_APPS
}


# Sunbedded - SODAQ - Mbili 1284P
function Setup_SunbeddedSodaq()
{
  echo
	echo "This option will install a Sunbedded product."
	echo "SODAQ - SODAQ Mbili (Arduino 1284P) v$SUNBED_SODAQVER (Board ideal for low (solar) power applications)"
	echo "WARNING: Hardware is from manufacturer (only open source code)"
	echo

	package_name=Sodaq_bundle
	cd /tmp
	rm -rf $package_name*
	wget http://mbili.sodaq.net/wp-content/uploads/2015/04/$package_name.zip -O $package_name.zip
  unzip -d $package_name $package_name.zip
		
	# Clean Arduino environment from older SODAQ libraries
	rm -rf $HOMEDEV/Arduino/libraries/Sodaq*
	rm -rf $HOMEDEV/Arduino/libraries/RTCTimer
	rm -rf $HOMEDEV/Arduino/libraries/GPRSbee
	rm -rf $HOMEDEV/Arduino/hardware/sodaq-HardwareMbili
	rm -rf $HOMEDEV/Arduino/hardware/sodaq-HardwareMoja

	# Install SODAQ Board reference and libraries
	cp -R $package_name/hardware/* $HOMEDEV/Arduino/hardware
	cp -R $package_name/libraries/* $HOMEDEV/Arduino/libraries

	chown -R $USERDEV:$USERDEV $HOMEDEV/Arduino/libraries
	chown -R $USERDEV:$USERDEV $HOMEDEV/Arduino/hardware

	cp -f $HOMEDEV/XDAQ/Admin/xdaq-sunbedded-sodaq-mbili.desktop $GNOME_SHARE_APPS
	cp -f $HOMEDEV/XDAQ/Admin/xdaq-sunbedded-logo.png $GNOME_SHARE_ICONS
}


# Linear Technology - Linduino
function Setup_LTLinduino()
{
  echo
	echo "This option will install Linduino."
	echo "The highly portable C library Arduino compatible for LT devices $LT_LINDUINOVER"
	echo "WARNING: Hardware is from manufacturer"
	echo

  package_name=LTSketchbook
	cd /tmp
	rm -rf $package_name*
	wget http://www.linear.com/docs/43958 -O $package_name.zip
  unzip $package_name.zip

  # Remove current LT Linduino library
  if [ -d $HOMEDEV/Arduino/$package_name ];
  then
      cd $HOMEDEV/Arduino/libraries
      ls $HOMEDEV/Arduino/LTSketchbook/libraries | xargs rm -rf
	    rm -rf $HOMEDEV/Arduino/$package_name*
      cd /tmp
  fi

	mv $package_name $HOMEDEV/Arduino
  mv $HOMEDEV/Arduino/$package_name/Example\ Designs $HOMEDEV/Arduino/$package_name/Example_Designs
  cp -R $HOMEDEV/Arduino/$package_name/libraries/* $HOMEDEV/Arduino/libraries/

	chown -R $USERDEV:$USERDEV $HOMEDEV/Arduino
	cp -f $HOMEDEV/XDAQ/Admin/xdaq-lineartechnology-linduino.desktop $GNOME_SHARE_APPS
	cp -f $HOMEDEV/XDAQ/Admin/xdaq-lineartechnology-logo.png $GNOME_SHARE_ICONS
}


# XDAQ package manager functions (Setup/Status)
function Setup()
{
  echo
  echo "XDAQ Setup will install following XDAQ Demo products:"
  echo "1) Libelium > Waspmote"
  echo "2) Sunbedded > SODAQ"
  echo "3) Linear Technology > Linduino"
  echo

	Setup_LibeliumWaspmote
	Setup_SunbeddedSodaq
	Setup_LTLinduino
}

function Status()
{
	GetPackageVersion "Libel. Waspmote   " "waspmote" "echo $LIB_WASPMOTEVER" "$XDAQ_SUPPORT"
	GetPackageVersion "Libel. Plug&Sense!" "waspmote" "echo $LIB_PLUGSENSEVER" "$XDAQ_SUPPORT"
	GetPackageVersion "Sunbe. SODAQ Mbili" "$HOMEDEV/Arduino/libraries/Sodaq" "echo $SUNBED_SODAQVER" "$XDAQ_SUPPORT"
	GetPackageVersion "LT Linduino"	"$HOMEDEV/Arduino/LTSketchbook" "echo $LT_LINDUINOVER" "$XDAQ_SUPPORT"
}

source ./xdaq-setup-main.sh
