#!/usr/bin/python


#########################################################################
# xdaq-starter.sh - Script to build XDAQ v1.0 Virtual Appliance 	      # 
# Copyright (C) 2015 by AF                                              #
#                                                                       #
# xdaq-starter.sh is free software: you can redistribute it and/or 	    #
# modify it under the terms of the GNU General Public License 		      #
# as published by the Free Software Foundation, either version 3 of 	  #
# the License, or (at your option) any later version.                   #
#                                                                       #
# xdaq-starter.sh is distributed in the hope that it will be useful,	  #
# but WITHOUT ANY WARRANTY; without even the implied warranty of        #
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         #
# GNU General Public License for more details.                   	      #
#                                                                       #
# You should have received a copy of the GNU General Public      	      #
# License along with xdaq-starter.sh 					                          #
# If not, see <http://www.gnu.org/licenses/> 				                    #
#########################################################################

#
# @file    xdaq-test-firmata.py
# @author  AF
# @date    20/2/2015
# @version 1.0
#
# @brief This is a short script to check Firmata commands
#
# @section DESCRIPTION
#
#  This small script support testing of Firmata protocol over standard
#  serial connection. It is an easy I/O board access through the library
#  <pyfirmata> over Python environment. This example provide blinking of
#  standard led connected to digital pin 13.
# 
#  This example is part of XDAQ v1.0 Project.
#  This code is in the public domain as well as XDAQ.
# 
#  See more at www.embeddedrevolution.info
#

import sys
import time
import pyfirmata

print
print "This small script support testing of Firmata protocol over standard"
print "serial connection. It is an easy I/O board access through the library"
print "<pyfirmata> over Python environment. This example provide blinking of"
print "standard led connected to digital pin 13 (each 3 sec)."
print

# Check input parameter
if len(sys.argv) < 2:
   print "Error: ",sys.argv[0], ": missing operand"
   print "Usage: ", sys.argv[0], " COM"
   print "COM: this is the device (e.g. /dev/ttyACM0) related to standard"
   print "     serial port connected to the Arduino board."
   print
   exit(0)

print "Led status (on/off):"
board = pyfirmata.Arduino(sys.argv[1])

board.digital[13].mode = pyfirmata.OUTPUT

status = True
for i in range(1,10):
       print 'Led 13 On' if int(status) else 'Led 13 Off'
       board.digital[13].write(status)
       status = not status
       time.sleep(3)
