#!/bin/bash

#########################################################################
# xdaq-setup-xtable.sh                                                  #
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
XDAQ_PACKAGE=XTable
XDAQ_SUPPORT=ARDUINO


# XDAQ package manager functions (Setup/Status)
function Setup()
{
        cp -R $HOMEDEV/XDAQ/Projects/XTable-Arduino $HOMEDEV/Arduino/libraries
        chown -R $USERDEV:$USERDEV $HOMEDEV/Arduino/libraries/XTable-Arduino
        if [ ! -d $HOMEDEV/Arduino/libraries/XEEPROM ];
        then 
                ln -fs $HOMEDEV/Arduino/libraries/XTable-Arduino/src/XEEPROM $HOMEDEV/Arduino/libraries/XEEPROM
        fi

        if [[ -e /opt/of_libs_openFrameworks && -d $HOMEDEV/XDAQ/Projects/XTable-Arduino/BlinkingLEDs/BlinkingLEDs_of ]];
        then 
                echo "Create openFrameworks BlinkingLEDs_of example"
                cd $HOMEDEV/XDAQ/Projects/XTable-Arduino/BlinkingLEDs/BlinkingLEDs_of
                #make clean
                #make
                cp -f bin/BlinkingLEDs_of $HOMEDEV/XDAQ/Examples/XTable/BlinkingLEDs_of/
        fi
}

function Status()
{
  GetPackageVersion "XTable" "$HOMEDEV/Arduino/libraries/XTable-Arduino" "cat $HOMEDEV/Arduino/libraries/XTable-Arduino/library.properties 2>&1|grep version|awk -F'=' '{print \$2}'" "$XDAQ_SUPPORT"
}

source ./xdaq-setup-main.sh
