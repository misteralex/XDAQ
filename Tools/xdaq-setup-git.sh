#!/bin/bash

#########################################################################
# xdaq-setup-git.sh                                                     #
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
XDAQ_PACKAGE=Git
XDAQ_SUPPORT=DEBIAN


# XDAQ package manager functions (Setup/Status/Support)
function Setup()
{
    echo -e "\n[SETUP] Install Git Terminal tool."
    echo ; sleep 1

    apt-get --yes --force-yes -f install
    apt-get --yes --force-yes --reinstall install git
}


function Status()
{
    GetPackageVersion "Git" "git" "git --version|awk -F' ' '{print \$3}'" ""
}

source ./xdaq-setup-main.sh
