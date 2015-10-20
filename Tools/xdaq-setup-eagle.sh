#!/bin/bash

#########################################################################
# xdaq-setup-eagle.sh                                                   #
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
XDAQ_PACKAGE=EAGLE_PCB_Design
XDAQ_SUPPORT=DESKTOP

EAGLEPCBVER=7.3.0


# XDAQ package manager functions (Setup/Status)
function Setup()
{
	rm -rf /usr/local/bin/eagle
  rm -rf /tmp/eagle*
	cd /tmp
	wget http://web.cadsoft.de/ftp/eagle/program/7.3/eagle-lin32-$EAGLEPCBVER.run
	chmod +x eagle-lin32-$EAGLEPCBVER.run
	ln -sf /opt/eagle-$EAGLEPCBVER/bin/eagle /usr/local/bin/eagle
	cp -f $HOMEDEV/XDAQ/Admin/xdaq-eagle.desktop $GNOME_SHARE_APPS
	cp -f $HOMEDEV/XDAQ/Admin/xdaq-eagle-logo.png $GNOME_SHARE_ICONS
	./eagle-lin32-$EAGLEPCBVER.run /opt
	chown -R $USERDEV:$USERDEV /opt/eagle-$EAGLEPCBVER
}

function Status()
{
  GetPackageVersion "EAGLE PCB Design" "eagle" "echo $EAGLEPCBVER" "$XDAQ_SUPPORT"
}

source ./xdaq-setup-main.sh
