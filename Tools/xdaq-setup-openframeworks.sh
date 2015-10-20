#!/bin/bash

#########################################################################
# xdaq-setup-openframeworks.sh                                          #
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
XDAQ_PACKAGE=openFrameworks
XDAQ_SUPPORT=DESKTOP

OFVER=0.8.4


# XDAQ package manager functions (Setup/Status)
function Setup()
{
	rm -rf /opt/of_v$OFVER\_linux_release
	rm -rf /tmp/of_v$OFVER\_linux_release.tar.gz
	cd /tmp
	wget http://www.openframeworks.cc/versions/v$OFVER/of_v$OFVER\_linux_release.tar.gz
  tar -xvzf of_v$OFVER\_linux_release.tar.gz -C /opt
	if [ -d /opt/of_v$OFVER\_linux_release/libs/openFrameworks ];
	then
		ln -sf /opt/of_v$OFVER\_linux_release/libs/openFrameworks /opt/of_libs_openFrameworks
	fi

	cd /opt/of_v$OFVER\_linux_release/scripts/linux/debian

	# Fix Jessie exception for <python-argparse> virtual package now part of Python standard library
	# XDAQ Jessie release ignore the this virtual package. 
	# See more at https://code.google.com/p/argparse and https://github.com/openframeworks/openFrameworks/issues/3703
	if [[ "$OSVERSION" == "JESSIE" ]]; then cp -f $HOMEDEV/XDAQ/Admin/of-install_dependencies.sh install_dependencies.sh ; fi

	echo "Y" | ./install_dependencies.sh
	echo "Y" | ./install_dependencies.sh

	cd /opt/of_v$OFVER\_linux_release/scripts/linux
	echo "Y" | ./compileOF.sh

	chown -R $USERDEV:$USERDEV /opt/of_libs_openFrameworks
	chown -R $USERDEV:$USERDEV /opt/of_v$OFVER\_linux_release
}

function Status()
{
  GetPackageVersion "openFrameworks" "/opt/of_libs_openFrameworks" "echo $OFVER" "$XDAQ_SUPPORT"
}

source ./xdaq-setup-main.sh
