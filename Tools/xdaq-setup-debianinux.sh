#!/bin/bash

#########################################################################
# xdaq-setup-debianinux.sh                                              #
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
XDAQ_CATEGORY=EXTRA
XDAQ_PACKAGE=DEBIANINUX
XDAQ_SUPPORT=EXTRA


# XDAQ package manager functions (Setup/Status)
function Setup()
{
    echo -e "\n[SETUP] Install Debianinux."
    echo ; sleep 1

    dir_org=`pwd`
    cd `dirname -- "$0"`
    ./xdaq-setup-vmware.sh -reinstall
    ./xdaq-setup-osupdate.sh -reinstall
    ./xdaq-setup-desktopenv.sh -reinstall
    ./xdaq-setup-integration.sh -reinstall
    ./xdaq-setup-git.sh -reinstall
    ./xdaq-setup-arduino.sh -reinstall
    ./xdaq-setup-eclipse.sh -reinstall
    cd $dir_org
}


function Status()
{
    dir_org=`pwd`
    cd `dirname -- "$0"`
    ./xdaq-setup-vmware.sh --version
    ./xdaq-setup-osupdate.sh --version
    ./xdaq-setup-desktopenv.sh --version
    ./xdaq-setup-integration.sh --version
    ./xdaq-setup-arduino.sh --version
    ./xdaq-setup-eclipse.sh --version
    cd $dir_org
}

source ./xdaq-setup-main.sh
