#!/bin/bash

#########################################################################
# xdaq-setup-gsl.sh                                                     #
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
XDAQ_PACKAGE=GSL
XDAQ_SUPPORT=DESKTOP

GSLVER=1.16


# XDAQ package manager functions (Setup/Status)
function Setup()
{
	cd /tmp
	package_name=gsl-$GSLVER
	wget http://ftp.gnu.org/gnu/gsl/gsl-latest.tar.gz -O $package_name.tar.gz
	rm -rf /opt/gsl*
  tar -xvzf $package_name.tar.gz -C /opt
	chown -R $USERDEV:$USERDEV /opt/$package_name
	cd /opt/$package_name
	./configure
	make
	make install
}

function Status()
{
  GetPackageVersion "GSL"	"/usr/local/include/gsl" "echo $GSLVER" "$XDAQ_SUPPORT"
}

source ./xdaq-setup-main.sh
