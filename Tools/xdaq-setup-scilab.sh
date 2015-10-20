#!/bin/bash

#########################################################################
# xdaq-setup-scilab.sh                                                  #
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
XDAQ_PACKAGE=Scilab
XDAQ_SUPPORT=DESKTOP

SCILABVER=5.5.2


# XDAQ package manager functions (Setup/Status)
function Setup()
{
	cd /tmp
	package_name=scilab-$SCILABVER
	wget http://www.scilab.org/download/$SCILABVER/$package_name.bin.linux-i686.tar.gz -O $package_name.tar.gz
	rm -rf /opt/scilab*
     	tar -xvzf $package_name.tar.gz -C /opt
	cd /opt/$package_name
	ln -sf /opt/$package_name/bin/scilab /usr/local/bin/scilab

	cp -f $HOMEDEV/XDAQ/Admin/xdaq-scilab.desktop $GNOME_SHARE_APPS
	cp -f $HOMEDEV/XDAQ/Admin/xdaq-scilab-logo.png $GNOME_SHARE_ICONS
}

function Status()
{
  GetPackageVersion "Scilab" "/usr/local/bin/scilab" "echo $SCILABVER" "$XDAQ_SUPPORT"
}

source ./xdaq-setup-main.sh
