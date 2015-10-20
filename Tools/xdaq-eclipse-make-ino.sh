#!/bin/bash

##############################################################################
# xdaq-eclipse-make-ino.sh - Script to convert Arduino C++ to Arduino format #
#                                                                            #
# This component is part of XDAQ v1.0 Virtual Appliance                      # 
# Copyright (C) 2015 by AF                                                   #
#                                                                            #
# xdaq-eclipse-make-ino.sh is free software: you can redistribute it and/or  #
# modify it under the terms of the GNU General Public License                #
# as published by the Free Software Foundation, either version 3 of          #
# the License, or (at your option) any later version.                        #
#                                                                            #
# xdaq-eclipse-make-ino.sh is distributed in the hope that it will be useful #
# but WITHOUT ANY WARRANTY; without even the implied warranty of             #
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the              #
# GNU General Public License for more details.                               #
#                                                                            #
# You should have received a copy of the GNU General Public                  #
# License along with xdaq-eclipse-make-ino.sh                                #
# If not, see <http://www.gnu.org/licenses/>                                 #
##############################################################################

if [ -z "$1" ];
then
	echo -e "Usage: ./xdaq-eclipse-make-ino.sh <full name of cpp module to convert>\n"
	exit
fi

SRC=$1

if [ -f ${SRC} ];
then
	SRCFOLDER=`dirname $SRC`
	DSTFOLDER=`dirname $SRCFOLDER`
	FILE=`basename $SRC`
	MODULE="${FILE%.*}"\_ino
	echo "Source folder name: $SRCFOLDER"
	
	echo "Module Arduino project name: $MODULE"
	if [ -d $DSTFOLDER/$MODULE ];
	then
		echo "Attempt to create folder: <$DSTFOLDER/$MODULE>"
		read -p "This folder already exist. Do you want delete it (Y/n)? " -n 1 -r
		echo    
		if [[ $REPLY =~ ^[Yy]$ ]];
		then
			rm -rf $DSTFOLDER/$MODULE
		else
			echo "*ERROR* Cannot process your request."
			exit
		fi
	fi
	
	echo "Create folder: <$DSTFOLDER/$MODULE>"
	mkdir $DSTFOLDER/$MODULE
	cp $SRC $DSTFOLDER/$MODULE/$MODULE.ino
	if [ -f $DSTFOLDER/$MODULE/$MODULE.ino ];
	then
		echo -e "Convertion completed. \nCreated Arduino project available at \n$DSTFOLDER/$MODULE/"
	else
		echo "*ERROR* Cannot create Arduino project."
	fi
else
	echo -e "*ERROR* Specified CPP module <${SRC}> does not exit. \nPlease check required input name."
fi
