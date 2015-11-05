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

# Select which release to install
XDAQ_AUTO_CONFIRM=$2

function SelectRelease()
{
   # Default release
   nRelease=2

   if [[ $XDAQ_AUTO_CONFIRM != "Y" ]]; then
      echo "Arduino installation - select a release"
      echo " [1] Arduino 1.6.6 Nightly Build Release"
      echo " [2] Arduino 1.6.5-r5 Official Release (default)"
      echo
      echo " [0] Exit"
      echo ; sleep .5
      read -p "Which release? " nRelease
      echo
   fi

   if [[ "$nRelease" == "" ]]; then nRelease=2 ; fi

   case $nRelease in
     0) ;;
     1) echo "Install Arduino IDE (Nightly Build Release)"
        arduino_ver=arduino-nightly
        package_name=arduino-nightly-linux32.tar.xz
        ;;
     2) echo "Install Arduino IDE (Official Release)"
        arduino_ver=arduino-1.6.5
        package_name=arduino-1.6.5-r5-linux32.tar.xz
        ;;
    
     *) echo "Error: Invalid option..."	;;
   esac

   return $nRelease
}


# XDAQ package manager functions (Setup/Status/Support)
function Setup()
{
  SelectRelease
  if [[ $? != 0 ]];
  then
      if [[ -e /opt/$arduino_ver ]]; then
          sudo ln -sf /opt/$arduino_ver/arduino /usr/local/bin/arduino
          echo "Arduino <$package_name> already installed. Ready to use."
          echo

          echo -n "Do you want reinstall this environment? " ; sleep .3
          read -e -i Y -p "(Y/n)? " ; echo
          if [[ $REPLY =~ ^[Nn]$ ]]; then echo ; return ; fi
      fi

      echo -e "\nInstall Arduino IDE (Package: $package_name}"

      Setup_Java

      rm -rf /usr/local/bin/arduino
      rm -rf /opt/$arduino_ver
      rm -f $GNOME_SHARE_APPS/xdaq-arduino.desktop
      rm -f $GNOME_SHARE_ICONS/xdaq-arduino-logo.png

      cd /tmp
      rm -rf $package_name
      rm -rf /opt/arduino

      wget http://arduino.cc/download.php?f=/$package_name -O $package_name
      mkdir /opt/$arduino_ver
      tar xvf $package_name -C /opt/$arduino_ver --strip-components=1
      if [ -d /opt/$arduino_ver ];
      then
          chown -R $USERDEV:$USERDEV /opt/$arduino_ver
          ln -fs /opt/$arduino_ver/arduino /usr/local/bin/arduino
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
  fi
}

function Status()
{
    GetPackageVersion "Arduino IDE"	"arduino" "echo $ARDUINOVER" "$XDAQ_SUPPORT"
}

source ./xdaq-setup-main.sh
