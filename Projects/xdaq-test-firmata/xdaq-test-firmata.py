#!/usr/bin/python

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
import subprocess

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
   
   print "Try to get automatically expected Serial Port connected to your Arduino board"
   bash_cmd="dmesg | grep tty|tail -1|awk -F: '{print $3}'|awk -F: '{print $1}'|awk -F' ' '{print $1}'"
   COM="/dev/"+subprocess.check_output(bash_cmd, shell=True)
   COM=COM.strip()
   print ("Serial Port: %s" % COM)
   
else:
       COM=sys.argv[1]


print "Led status (on/off):"
board = pyfirmata.Arduino(COM)

board.digital[13].mode = pyfirmata.OUTPUT

status = True
for i in range(1,10):
       print 'Led 13 On' if int(status) else 'Led 13 Off'
       board.digital[13].write(status)
       status = not status
       time.sleep(3)
