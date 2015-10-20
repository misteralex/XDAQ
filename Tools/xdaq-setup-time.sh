#!/bin/bash

#########################################################################
# xdaq-setup-time.sh                                                    #
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
XDAQ_CATEGORY=LIBRARY
XDAQ_PACKAGE=Time
XDAQ_SUPPORT=ARDUINO

VER=1.4
WEBPAGE=http://playground.arduino.cc/Code/Time


# XDAQ package manager functions (Setup/Status)
function Setup()
{
	rm -rf $HOMEDEV/Arduino/libraries/Time*
	cd /tmp
	rm -rf master*
  wget https://github.com/PaulStoffregen/Time/archive/master.zip
	unzip master -d $HOMEDEV/Arduino/libraries
  mv $HOMEDEV/Arduino/libraries/Time-master $HOMEDEV/Arduino/libraries/Time
	chown -R $USERDEV:$USERDEV $HOMEDEV/Arduino/libraries/Time

  echo -e "\n\rPlease visit following web page for more details: $WEBPAGE"
}

function Status()
{
  GetPackageVersion "Time" "$HOMEDEV/Arduino/libraries/Time" "echo $VER" "$XDAQ_SUPPORT"
}

source ./xdaq-setup-main.sh
