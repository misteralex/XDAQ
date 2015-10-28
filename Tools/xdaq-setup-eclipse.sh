#!/bin/bash

#########################################################################
# xdaq-setup-eclipse.sh                                                 #
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
XDAQ_PACKAGE=Eclipse_IDE
XDAQ_SUPPORT=DESKTOP


# Select which Eclipse release to install
XDAQ_AUTO_CONFIRM=$2

function SelectRelease()
{
   # Default release
   nRelease=3

   if [[ $XDAQ_AUTO_CONFIRM != "Y" ]]; then
      echo "Eclipse installation - select a release"
      echo " [1] Eclipse Neon"
      echo " [2] Eclipse Mars"
      echo " [3] Eclipse Luna (default)"
      echo
      echo " [0] Exit"
      echo ; sleep .5
      read -p "Which Eclipse release? " nRelease
      echo
   fi

   if [[ "$nRelease" == "" ]]; then nRelease=3 ; fi

   case $nRelease in
     0) ;;
     1) echo "Install Eclipse Neon IDE"
        package_name=eclipse-cpp-neon-M2-linux-gtk.tar.gz
        package_ftp=http://ftp.jaist.ac.jp/pub/eclipse/technology/epp/downloads/release/neon/M2
        ;;
     2) echo "Install Eclipse Mars IDE"
        package_name=eclipse-cpp-mars-M4-linux-gtk.tar.gz
        package_ftp=http://www.eclipse.org/downloads/download.php?file=/technology/epp/downloads/release/mars/M4
        ;;
     3) echo "Install Eclipse Luna IDE"
        package_name=eclipse-cpp-luna-SR2-linux-gtk.tar.gz
        package_ftp=http://ftp.heanet.ie/pub/eclipse/technology/epp/downloads/release/luna/SR2
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

      cd /tmp
      rm -rf eclipse*
      rm -rf /opt/eclipse

      wget $package_ftp/$package_name -O $package_name
      tar xvzf $package_name -C /opt/
      if [ -d /opt/eclipse ];
      then
        chown -R $USERDEV:$USERDEV /opt/eclipse
        ln -s /opt/eclipse/eclipse /usr/local/bin/eclipse
        cp -f $HOMEDEV/XDAQ/Admin/xdaq-eclipse.desktop $GNOME_SHARE_APPS
        cp -f $HOMEDEV/XDAQ/Admin/xdaq-eclipse-icon.png $GNOME_SHARE_ICONS
      
        # Check external plugin
        echo
        echo "Please setup Arduino and PyDev Plugins from Eclipse Marketplace"
        echo "as described in the XDAQ User Guide."
      else
        echo "*** Installation Error. Try again setup process."
      fi
  fi
}

function Status()
{
    GetPackageVersion "Eclipse IDE"	"eclipse" "cat /opt/eclipse/.eclipseproduct |grep version|awk -F= '{print \$2}'" "$XDAQ_SUPPORT"
}

source ./xdaq-setup-main.sh
