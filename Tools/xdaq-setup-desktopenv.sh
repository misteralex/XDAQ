#!/bin/bash

#########################################################################
# xdaq-setup-desktopenv.sh                                              #
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
XDAQ_PACKAGE=Desktop_Environment
XDAQ_SUPPORT=DEBIAN

# Select which Eclipse release to install
XDAQ_AUTO_CONFIRM=$2


function SelectRelease()
{
   # Default release
   nRelease=2

   if [[ $XDAQ_AUTO_CONFIRM != "Y" ]]; then
      echo "Desktop Environment installation - select a release"
      echo " [1] GNOME"
      echo " [2] Xfce (default)"
      echo
      echo " [0] Exit"
      echo ; sleep .5
      read -p "Which release? " nRelease
      echo
   fi

   if [[ "$nRelease" == "" ]]; then nRelease=2 ; fi

   case $nRelease in
     0) ;;
     1) packages="gnome libcanberra-gtk-module:i386"
        desktop_check="gnome-session"
        desktop_version="dpkg -l|grep gnome-session-bin|awk -F' ' '{print \"GNOME \" \$3}'"
        ;;
     2) packages="lightdm xfce4"
        desktop_check="xfce4-about"
        desktop_version="dpkg -l|grep \"xfce4 \"|awk -F' ' '{print \"Xfce \" \$3}'"
        ;;
    
     *) echo "Error: Invalid option..."	;;
   esac

   return $nRelease
}


# XDAQ package manager functions (Setup/Status/Support)
function Setup()
{
  echo "Manage Desktop Environment installation"
  
  SelectRelease
  if [[ $? != 0 ]]; 
  then 
      rm -rf /usr/bin/xdaq-desktop
      apt-get --yes --force-yes --reinstall install $packages
      ln -s /usr/bin/$desktop_check /usr/bin/xdaq-desktop
  fi
}

function Status()
{
    desktop_version=""
    if [ ! -z `which xdaq-desktop` ];
    then
        desktop_type=$(readlink -f `which xdaq-desktop` | awk -F'/' '{print $4}' | awk -F'-' '{print $1}')
        desktop_version="dpkg -l|grep \"$desktop_type \"|awk -F' ' '{print \"$desktop_type \" \$3}'|head -1"
    fi
    GetPackageVersion "Desktop Environment" "xdaq-desktop" "$desktop_version"
}

source ./xdaq-setup-main.sh
