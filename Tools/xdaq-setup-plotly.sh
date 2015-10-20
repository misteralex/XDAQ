#!/bin/bash

#########################################################################
# xdaq-setup-plotly.sh                                                  #
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
XDAQ_PACKAGE=Plotly
XDAQ_SUPPORT=ARDUINO

PLOTLYVER=1.0
NODEJSVER=0.12.2


# XDAQ package manager functions (Setup/Status)
function Setup()
{
	plotly_opt=/opt/plotly-arduino-api
	cd /tmp
	rm -rf plotly* arduino-api-master
	wget https://github.com/plotly/arduino-api/archive/master.zip -O plotly-master.zip
	unzip plotly-master.zip
	rm -rf $plotly_opt
	cp -R arduino-api-master $plotly_opt
	if [ ! -d /opt/plotly-arduino-api ]; 
	then 
		echo "*** Installation Error. Try again setup process."
	else
		# Install Node.js
		echo "Install Node.js"
		rm -rf node-v$NODEJSV.tar.gz
		wget http://nodejs.org/dist/v$NODEJSVER/node-v$NODEJSVER.tar.gz -O node-v$NODEJSVER.tar.gz
		tar xvzf node-v$NODEJSVER.tar.gz
		cd node-v$NODEJSVER
		./configure
		make
		make install

		# Create example project (Arduino connected by standard serial streaming online)
		mkdir $plotly_opt/plotly_project
		chown -R $USERDEV:$USERDEV $plotly_opt
		cd $plotly_opt/plotly_project
		su - $USERDEV -c "cd $plotly_opt/plotly_project ; npm install plotly"
		su - $USERDEV -c "cd $plotly_opt/plotly_project ; npm install johnny-five"
		cp $plotly_opt/plotly_streaming_serial/simple.js .
		cp -f $HOMEDEV/XDAQ/Admin/simple-url.js .
		chown -R $USERDEV:$USERDEV $plotly_opt
	fi
}

function Status()
{
  GetPackageVersion "Plotly" "/opt/plotly-arduino-api" "echo $PLOTLYVER" "$XDAQ_SUPPORT"
  GetPackageVersion "Node.js"	"node" "echo $NODEJSVER"
}

source ./xdaq-setup-main.sh
