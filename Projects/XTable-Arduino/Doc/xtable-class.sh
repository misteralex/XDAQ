#!/bin/bash

#############################################################################
# xtable-class.sh - Script to build Doxygen documents                       #
# Copyright (C) 2015 by AF                                                  #
#                                                                           #
# xtable-class.sh is free software: you can redistribute it and/or          #
# modify it under the terms of the GNU General Public License 	            #
# as published by the Free Software Foundation, either version 3 of 	      #
# the License, or (at your option) any later version.                       #
#                                                                           #
# xtable-class.sh is distributed in the hope that it will be useful,        #
# but WITHOUT ANY WARRANTY; without even the implied warranty of            #
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the             #
# GNU General Public License for more details.                              #
#                                                                           #
# You should have received a copy of the GNU General Public                 #
# License along with xtable-class.sh                                        #
# If not, see <http://www.gnu.org/licenses/> 				                        #
#############################################################################

RNAME=xtable-class

if [ ! -f $RNAME.cfg ];
then
	doxygen -g $RNAME.cfg
	echo "Please check new doxygen configuration file <$RNAME>"
	exit
fi

doxygen $RNAME.cfg

cd latex
make pdf
cp -f refman.pdf ../$RNAME.pdf
