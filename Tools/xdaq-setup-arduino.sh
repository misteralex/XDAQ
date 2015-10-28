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
        package_name=arduino-nightly-linux32.tar.xz
        package_ftp=
        ;;
     2) echo "Install Arduino IDE (Official Release)"
        package_name=arduino-1.6.5-r5-linux32.tar.xz
        package_ftp=
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

      Setup_Java

      echo -e "\nInstall Arduino IDE (Package: $package_name}"
      rm -rf $HOMEDEV/Arduino_BACK
      mv $HOMEDEV/Arduino $HOMEDEV/Arduino_BACK
      echo "Previous Arduino user context (i.e. ~/Arduino) is preserved for XDAQ user purposes (i.e. ~/Arduino_BACK)."
      echo

      package_root=`echo $package_name|awk -F'-' '{print $1"-"$2}'`
      cd /tmp
      rm -rf $package_name $package_root
      wget http://arduino.cc/download.php?f=/$package_name -O $package_name
      tar xvf $package_name $package_root/revisions.txt
      arduino_ver=`cat arduino-nightly/revisions.txt|head -n1|awk -F' ' '{print $2}'`
      rm -rf /opt/arduino*
      mkdir /opt/arduino-$arduino_ver
      tar xvf $package_name -C /opt/arduino-$arduino_ver --strip-components=1
      if [ -d /opt/arduino-$arduino_ver ];
      then
          chown -R $USERDEV:$USERDEV /opt/arduino-$arduino_ver
          rm -rf arduino-$arduino_ver-linux32.tar.xz
          rm -rf /usr/local/bin/arduino
          ln -fs /opt/arduino-$arduino_ver/arduino /usr/local/bin/arduino
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
    GetPackageVersion "Arduino IDE"	"arduino" "echo $arduino_ver" "$XDAQ_SUPPORT"
}

source ./xdaq-setup-main.sh
