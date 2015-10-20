#!/bin/bash

#########################################################################
# xdaq-setup-fritzing.sh                                                #
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
XDAQ_PACKAGE=Fritzing
XDAQ_SUPPORT=DESKTOP

FRITZINGVER=0.9.2b


# XDAQ package manager functions (Setup/Status)
function Setup()
{
  cd /tmp
  rm -rf fritzing-$FRITZINGVER.linux.i386.tar.bz2
  wget http://fritzing.org/download/$FRITZINGVER/linux-32bit/fritzing-$FRITZINGVER.linux.i386.tar.bz2
  rm -rf /opt/fritzing*
  mkdir /opt/fritzing-$FRITZINGVER
  tar -xvjf fritzing-$FRITZINGVER.linux.i386.tar.bz2 -C /opt/fritzing-$FRITZINGVER/
  rm -rf /usr/local/bin/fritzing
  ln -fs /opt/fritzing-$FRITZINGVER/fritzing-$FRITZINGVER.linux.i386/Fritzing /usr/local/bin/fritzing
  chown -R $USERDEV:$USERDEV /opt/fritzing-$FRITZINGVER/
  cp -f $HOMEDEV/XDAQ/Admin/xdaq-fritzing.desktop $GNOME_SHARE_APPS
  cp -f $HOMEDEV/XDAQ/Admin/xdaq-fritzing-logo.png $GNOME_SHARE_ICONS
}

function Status()
{
  GetPackageVersion "Fritzing" "fritzing" "echo $FRITZINGVER" "$XDAQ_SUPPORT"
}

source ./xdaq-setup-main.sh
