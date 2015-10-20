#!/bin/bash

#########################################################################
# xdaq-setup-integration.sh                                             #
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
XDAQ_PACKAGE=Integration
XDAQ_SUPPORT=DESKTOP

# CuteCom
function Setup_CuteCom()
{
  apt-get --yes --force-yes -f install
  apt-get --yes --force-yes --reinstall install cutecom
  rm -rf $GNOME_SHARE_APPS/cutecom.desktop
  cp -f $HOMEDEV/XDAQ/Admin/xdaq-cutecom.desktop $GNOME_SHARE_APPS

  # Fix CuteCom configuration
  echo -e "\nFix serial port for CuteCom users"
  if [ -d $HOMEDEV/.config/CuteCom ]; then rm -rf $HOMEDEV/.config/CuteCom ; fi
  mkdir $HOMEDEV/.config/CuteCom
    
  # Update SerialLine parameter
  cat $HOMEDEV/XDAQ/Admin/xdaq-cutecom-conf | grep -v 'CurrentDevice\|AllDevices' > $HOMEDEV/.config/CuteCom/CuteCom.conf
  echo "CurrentDevice=$COM" >> $HOMEDEV/.config/CuteCom/CuteCom.conf
  echo "AllDevices=/dev/ttyS0, /dev/ttyS1, /dev/ttyS2, $COM" >> $HOMEDEV/.config/CuteCom/CuteCom.conf
}


# Python
function Setup_Python()
{
  echo -n "[SETUP] Check for [Python] "
  echo "Install Python (included <pip> package manager)"
  apt-get --yes --force-yes -f install
  apt-get --yes --force-yes --reinstall install python2.7
  ln -sf /usr/bin/python2.7 /usr/bin/python
  apt-get --yes --force-yes --reinstall install python-pip
  pip install yolk
}


# XDAQ package manager functions (Setup/Status)
function Setup()
{
  echo -e "Install: [Integration] and other basic integration."
  echo "XDAQ Integration includes:"
  echo "1. Sudo: run programs with Superuser security privileges"
  echo "2. Easy access for XDAQ tools from Desktop (Thunar File Manager)"
  echo "3. Serial receiver (i.e. CuteCom)"
  echo "4. Install SSH service for remote management"
  echo "5. Check Java and Python environments" 
  echo "6. Install some basic tools (unzip, xterm, ntp, cmake, giggle)"
  echo "7. Install Iceweasel web browser"
  echo "8. Install xfce4-terminal (Xfce Terminal)"
  echo ; sleep 1

  # 1. SUDO
  echo -e "\n[SETUP] Install Sudo tool: check for Sudo support"
  apt-get --yes --force-yes -f install
  apt-get --yes --force-yes --reinstall install sudo
  cp -f $HOMEDEV/XDAQ/Admin/sudoers /etc/sudoers


  # 2. USER ACCESS AND CONFIGURATION
  # Easy access through xdaq-starter.sh tool
  echo "[SETUP] Manage XDAQ access and configuration"
  cp -f $HOMEDEV/XDAQ/Admin/.bashrc /root/.bashrc 
  cp -f $HOMEDEV/XDAQ/Admin/xdaq-starter.desktop $GNOME_SHARE_APPS
  cp -f $HOMEDEV/XDAQ/Admin/xdaq-starter-logo.png $GNOME_SHARE_ICONS

  # Easy Desktop Access
  if [ ! -d $HOMEDEV/Desktop ]; then mkdir $HOMEDEV/Desktop ; fi
  cp -f $HOMEDEV/XDAQ/Admin/xdaq-panel.desktop $GNOME_SHARE_APPS/panel.desktop
  cp -f $HOMEDEV/XDAQ/Admin/xdaq-panel.desktop $HOMEDEV/Desktop/panel.desktop
  cp -f $HOMEDEV/XDAQ/Admin/xdaq-terminal.desktop $GNOME_SHARE_APPS
  ln -sf $HOMEDEV/XDAQ/Tools/xdaq-starter.sh $HOMEDEV

  # thunar
  apt-get --yes --force-yes --reinstall install thunar

  # customize xterm icon
  cp -f $HOMEDEV/XDAQ/Admin/xdaq-starter-logo.png /usr/share/icons/hicolor/scalable/apps/xterm-color.svg
  cp -f $HOMEDEV/XDAQ/Admin/xdaq-starter-logo.png /usr/share/icons/hicolor/48x48/apps/xterm-color.png


  # 3. SERIAL PORT
  SetSerialPort
  Setup_CuteCom

  
  # 4. SSH Connection
  echo -e "\n[SETUP] Install SSH tool for remote management"
  apt-get --yes --force-yes -f install
  apt-get --yes --force-yes --reinstall install ssh


  # 5. Java and Python
  Setup_Java
  Setup_Python


  # 6. Basic Tools
  apt-get --yes --force-yes --reinstall install xterm
  apt-get --yes --force-yes --reinstall install cmake
  apt-get --yes --force-yes --reinstall install ntp
  apt-get --yes --force-yes --reinstall install unzip

  # Giggle
  apt-get --yes --force-yes --reinstall install giggle
  ConfigGnomeMenu giggle


  # 7. BROWSER: Icewdpkg -l|grep giggle|awk -F' ' '{print \$3}'easel
  apt-get --yes --force-yes --reinstall install iceweasel
    
  # Fix user configuration and browser access
  if [[ "`which iceweasel`" == "" && "`which firefox`" ]]; then ln -s /usr/bin/firefox /usr/bin/iceweasel ; fi


  # 8. TERMINAL: xfce4-terminal
  apt-get --yes --force-yes --reinstall install xfce4-terminal
  ln -s /usr/bin/xfce4-terminal /usr/bin/xdaq-terminal
}


function Status()
{
    GetPackageVersion "Java" "java" "java -version 2>&1|grep \"java version\"|awk -F' ' '{print \$3}'|awk -F'\"' '{print \$2}'"
    GetPackageVersion "Python" "python" "python -V 2>&1 |awk -F' ' '{print \$2}'"
    GetPackageVersion "Sudo" "sudo" "sudo -V |grep \"Sudo version\"|awk -F' ' '{print \$3}'"
    GetPackageVersion "SSH" "ssh" "ssh -V 2>&1|awk -F' ' '{print \$1}'"
    GetPackageVersion "Serial Receiver" "cutecom" "dpkg -l|grep cutecom|awk -F' ' '{print \"CuteCom \" \$3}'" "$XDAQ_SUPPORT"
    GetPackageVersion "Git GUI front-end" "giggle" "dpkg -l|grep giggle|awk -F' ' '{print \"Giggle \" \$3}'" "$XDAQ_SUPPORT"
    GetPackageVersion "Web Browser" "iceweasel" "iceweasel --version 2>/dev/null" "$XDAQ_SUPPORT"
    GetPackageVersion "Terminal Desktop" "xfce4-terminal" "xfce4-terminal --version|head -1" "$XDAQ_SUPPORT"
}

source ./xdaq-setup-main.sh
