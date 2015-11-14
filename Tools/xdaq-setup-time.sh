#!/bin/bash

#########################################################################
# xdaq-setup-time.sh                                                    #
#                                                                       #
# This script is part of XDAQ v1.1 Open Source Software Ecosystem       # 
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

XDAQ_PACK_NAME=$XDAQ_PACKAGE

# XDAQ package manager functions (Setup/Status)
function Setup()
{
  xdaq_source=https://github.com/PaulStoffregen/Time/archive/master.zip
  xdaq_webpage=http://playground.arduino.cc/Code/Time

	if [[ "$XDAQ_PACK_NAME" != "" ]]; then rm -rf $HOMEDEV/Arduino/libraries/$XDAQ_PACK_NAME* ; fi
  
	cd /tmp
	rm -rf master*
	wget $xdaq_source
	unzip master -d $HOMEDEV/Arduino/libraries
	chown -R $USERDEV:$USERDEV $HOMEDEV/Arduino/libraries/$XDAQ_PACK_NAME-master

  echo -e "\n\rPlease visit following web page for more details: $xdaq_webpage\n"
}

function Status()
{
  xdaq_package_ver=`cat $HOMEDEV/Arduino/libraries/$XDAQ_PACK_NAME-master/library.properties |grep version|awk -F'=' '{print $2}'`
  GetPackageVersion $XDAQ_PACKAGE "$HOMEDEV/Arduino/libraries/$XDAQ_PACK_NAME-master" "echo $xdaq_package_ver" "$XDAQ_SUPPORT"
}

source ./xdaq-setup-main.sh
