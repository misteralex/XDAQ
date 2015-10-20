#!/bin/bash

#########################################################################
# xdaq-setup-pyfirmata.sh                                               #
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
XDAQ_PACKAGE=pyFirmata
XDAQ_SUPPORT=PYTHON


# XDAQ package manager functions (Setup/Status)
function Setup()
{
	python_home=/usr/local/lib/python2.7/dist-packages
	rm -rf $python_home/pyfirmata
	bash -c 'pip install pyfirmata'
	pyFirmata_home=`ls $python_home|grep -i pyfirmata`
	if [ ! -z $pyFirmata_home ];
	then 
		ln -sf $python_home/$pyFirmata_home $python_home/pyfirmata
	fi
}

function Status()
{
  GetPackageVersion "pyFirmata"	"/usr/local/lib/python2.7/dist-packages/pyfirmata" "exec pip freeze 2>&1 |grep -i pyFirmata|awk -F'==' '{print \$2}'" "$XDAQ_SUPPORT"
}

source ./xdaq-setup-main.sh
