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
      echo " [4] Eclipse for Arduino"
      echo
      echo " [0] Exit"
      echo ; sleep .5
      read -p "Which Eclipse release? " nRelease
      echo
   fi

   if [[ "$nRelease" == "" ]]; then nRelease=3 ; fi

   eclipse_dest=eclipse
   eclipse_exec=eclipse
   case $nRelease in
     0) ;;
     1) echo "Install Eclipse Neon IDE"
        eclipse_ver=eclipse-neon
        package_name=eclipse-cpp-neon-M2-linux-gtk.tar.gz
        package_ftp=http://ftp.jaist.ac.jp/pub/eclipse/technology/epp/downloads/release/neon/M2
        ;;
     2) echo "Install Eclipse Mars IDE"
        eclipse_ver=eclipse-mars
        package_name=eclipse-cpp-mars-M4-linux-gtk.tar.gz
        package_ftp=http://www.eclipse.org/downloads/download.php?file=/technology/epp/downloads/release/mars/M4
        ;;
     3) echo "Install Eclipse Luna IDE"
        eclipse_ver=eclipse-luna
        package_name=eclipse-cpp-luna-SR2-linux-gtk.tar.gz
        package_ftp=http://ftp.heanet.ie/pub/eclipse/technology/epp/downloads/release/luna/SR2
        ;;

     4) echo "Install Eclipse for Arduino (ArduinoEclipsePlugin)"
        eclipse_ver=eclipse-arduino
        package_ftp=http://eclipse.baeyens.it/download/product
        eclipse_dest=eclipseArduino
        eclipse_exec=eclipseArduinoIDE
        echo ; sleep .5
        read -p "Which ArduinoEclipse (Linux Nightly Builds) package? " package_name
        echo
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
      if [[ -e /opt/$eclipse_ver ]]; then
          sudo ln -sf /opt/$eclipse_ver/eclipse /usr/local/bin/eclipse
          echo "Eclipse <$package_name> already installed. Ready to use."
          echo

          echo -n "Do you want reinstall this environment? " ; sleep .3
          read -e -i Y -p "(Y/n)? " ; echo
          if [[ $REPLY =~ ^[Nn]$ ]]; then echo ; return ; fi
      fi

      echo -e "\nInstall Eclipse IDE (Package: $package_name}"

      Setup_Java

      rm -rf /usr/local/bin/eclipse
      rm -rf /opt/$eclipse_ver
      rm -f $GNOME_SHARE_APPS/xdaq-eclise.desktop
      rm -f $GNOME_SHARE_ICONS/xdaq-eclipse-icon.png

      cd /tmp
      rm -rf $package_name
      rm -rf /opt/eclipse

      wget $package_ftp/$package_name -O $package_name
      tar xvzf $package_name -C /opt/
      
      if [ -d /opt/$eclipse_dest ];
      then
          mv /opt/$eclipse_dest /opt/$eclipse_ver
          chown -R $USERDEV:$USERDEV /opt/$eclipse_ver
          ln -sf /opt/$eclipse_ver/$eclipse_exec /usr/local/bin/eclipse
          echo $package_name > /opt/$eclipse_ver/eclipse_release

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
    eclipse_release=`readlink -f /usr/local/bin/eclipse | awk -F/ '{print $3}'`
    eclipse_ver=`readlink -f /usr/local/bin/eclipse | awk -F/ '{print $3}' | awk -F'-' '{print $2}'`
    package_ver_param=`cat /opt/$eclipse_release/.eclipseproduct 2>/dev/null|grep version|awk -F= '{print \$2}'`
    package_ver_param="echo $package_ver_param \($eclipse_ver\)"
    GetPackageVersion "Eclipse IDE"	"eclipse" "$package_ver_param" "$XDAQ_SUPPORT"
}

source ./xdaq-setup-main.sh
