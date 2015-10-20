#!/bin/bash

#########################################################################
# xdaq-setup-main.sh                                                    #
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

source ./xdaq-shared.sh

# Get XDAQ package version (empty result equal to "Not installed")
function GetPackageVersion()
{
    pkg_name=$1
    pkg_check=$2
    pkg_version=$3
    pkg_support=$4

    PKG_VER=""
    if [[ "`which $pkg_check`" != "" ]] || [[ ${pkg_check:0:1} == "/" && -d $pkg_check ]];
    then
      if [ ! -z "`eval $pkg_version`" ]; then PKG_VER=`eval $pkg_version` ; fi
    fi

    pkg_status=1
    PKGVER=$PKG_VER
    if [ "$PKG_VER" == "" ];
    then
        PKGVER="Not Installed"
        pkg_status=0
    fi

    if [[ "$XDAQ_COMMAND" == "--version" ]];
    then
        printf "%-22s %-20s  %s" "$pkg_name" "$PKGVER" "$pkg_support"
        echo
    fi

    xdaq_package_status=$(( $xdaq_package_status & $pkg_status ))
}


# Gnome Menu Customization
# Input: "desktop" configuration file (e.g. arduino.desktop)
function ConfigGnomeMenu()
{
	echo "Categories=Development" >> $GNOME_SHARE_APPS/$1.desktop
	echo "GenericName=XDAQ Debianinux" >> $GNOME_SHARE_APPS/$1.desktop
	mv $GNOME_SHARE_APPS/$1.desktop $GNOME_SHARE_APPS/xdaq-$1.desktop
}


# SERIAL PORT
function SetSerialPort()
{
  # Serial Port configuration
  COM_SETTING="115200 -parenb -parodd cs8 -hupcl -cstopb cread clocal -crtscts -ignbrk -brkint -ignpar -parmrk inpck -istrip -inlcr -igncr -icrnl -ixon -ixoff -iuclc -ixany -imaxbel -iutf8 -opost -olcuc -ocrnl -onlcr -onocr -onlret -ofill -ofdel nl0 cr0 tab0 bs0 vt0 ff0 -isig -icanon -iexten -echo -echoe -echok -echonl -noflsh -xcase -tostop -echoprt -echoctl -echoke"

  check_com=TRUE
  max_attempts=5
  while [[ $check_com == TRUE && $max_attempts > 0 ]]
  do
    COM=/dev/`dmesg | grep tty|tail -1|awk -F: '{print $3}'|awk -F: '{print $1}'|awk -F' ' '{print $1}'`
    ls $COM &>/dev/null
    echo -e "\n[SETUP] Default Serial Port for Arduino connection: $COM\n"
    if [ ! -c $COM ];
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

  if [ "$1" == "" ]; 
  then
    # Set permissions
    echo "Grant permissions to <$USERDEV> to use Arduino Serial Port ($COM)"
    adduser $USERDEV dialout
    chmod a+rw $COM

    # Set serial port configuration
    stty -F $COM $COM_SETTING
    echo -e "\nArduino Serial Port configured."
  fi
}


# JAVA
function Setup_Java()
{
  echo -n "[SETUP] Check for [Java] setup "

  # Update Java VM
  echo "Check Java environment"
  apt-get --yes --force-yes -f install
  apt-get --yes --force-yes --reinstall install openjdk-7-jre
  update-alternatives --set java /usr/lib/jvm/java-7-openjdk-i386/jre/bin/java
}


# Check DESKTOP/ARDUINO/PYTHON environments
CheckMainEnvironments

# SETTING
XDAQ_COMMAND=$1
XDAQ_PARAM=$2

# PRIVILEGES
CheckAccess $EUID
if [[ $? == 0 ]];
then
    XDAQ_COMMAND="--help"
    echo
fi

# HELP
if [[ "$XDAQ_COMMAND" == "--help" || "$XDAQ_COMMAND" == "" ]];
then
    echo
    echo "This script is part of XDAQ project."
    echo "It works only under root privileges."
    echo "Use <sudo> or work as System Adiministrator (root)."
    echo
    echo "An <XDAQ package> is a group of one or more Debian based packages."
    echo
    echo "Usage: `basename $0` [options]"
    echo "Options:"
    echo "  --help                   Display this information"
    echo "  --version                Display package version information"
    echo "  -install [-reboot]       Install the XDAQ package ([-reboot] restart the system after installation)"
    echo "  -reinstall [-reboot]     Reinstall the XDAQ package ([-reboot] restart the system after reinstallation)"
    echo "  -status                  Display the installation status of the XDAQ package (INSTALLED/NOT INSTALLED)"
    echo
    exit
fi


# VERSION
if [ "$XDAQ_COMMAND" == "--version" ]; 
then
    xdaq_package_status=1
    Status
    exit
fi


# STATUS
if [ "$XDAQ_COMMAND" == "-status" ];
then
      xdaq_package_status=1
      Status

      if [[ $xdaq_package_status == 1 ]];
      then
          echo "INSTALLED"
      else
          echo "NOT INSTALLED"
      fi

      exit
fi


# INSTALL
if [[ "$XDAQ_COMMAND" == "-install" || "$XDAQ_COMMAND" == "-reinstall" ]];
then
    # CHECK ENVIRONMENT
    if [[ "$XDAQ_SUPPORT" != "" ]]; then
       echo
       echo "WARNING: cannot install XDAQ package '${XDAQ_PACKAGE//_/ }' $XDAQ_SUPPORT"
       echo
       exit
    fi

    # CHECK INSTALLATION
    if [ "$XDAQ_COMMAND" == "-install" ];
    then
        xdaq_package_status=1
        Status
        if [[ $xdaq_package_status == 1 ]];
        then
            echo "[$XDAQ_PACKAGE] already installed."
            exit
        fi
    fi

    echo -e "\nReady to install the package [$XDAQ_PACKAGE]\n"

    if [[ $XDAQ_PARAM != "Y" ]];
    then

        # INSTALL REQUIRED XDAQ PACKAGES
        echo -n "Confirm [$XDAQ_PACKAGE] Installation " ; sleep .3
        read -e -i Y -p "(Y/n)? " ; echo
        if [[ $REPLY =~ ^[Nn]$ ]];
        then
            echo "***Process Aborted***"
            echo
            exit
        fi
    fi

    Setup
    exit
fi


# Missing request
echo "Missing operand."
echo "Try '`basename $0` --help' for more information."
echo
