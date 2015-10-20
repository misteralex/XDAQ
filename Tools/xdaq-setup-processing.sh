#!/bin/bash

#########################################################################
# xdaq-setup-processing.sh                                              #
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
XDAQ_PACKAGE=Processing
XDAQ_SUPPORT=DESKTOP


# XDAQ package manager functions (Setup/Status)
function Setup()
{
	cd /tmp
	rm -rf /tmp/processing*
	rm -rf /opt/processing*

	#package_name=processing-2.2.1	
	package_name=processing-3.0	
	wget http://download.processing.org/$package_name-linux32.tgz
      	tar -xvzf $package_name-linux32.tgz -C /opt
       	ln -sf /opt/$package_name/processing /usr/local/bin/processing
	cp -f $HOMEDEV/XDAQ/Admin/xdaq-processing.desktop $GNOME_SHARE_APPS
	cp -f $HOMEDEV/XDAQ/Admin/xdaq-processing-logo.png $GNOME_SHARE_ICONS
}

function Status()
{
  GetPackageVersion "Processing" "processing" "readlink -f `which processing` | awk -F/ '{print \$3}' | awk -F'-' '{print \$2}'" "$XDAQ_SUPPORT"
}

source ./xdaq-setup-main.sh
