#!/usr/bin/python

##############################################################################
# xdaq-eclipse-import.py - Script to import older version of Arduino C++     #
# project Eclipse based.						                                         #
# 									                                                         #
# This component is part of XDAQ v1.0 Virtual Appliance 		                 # 
# Copyright (C) 2015 by AF                                                   #
#                                                                            #
# xdaq-eclipse-import.py is free software: you can redistribute it and/or    #
# modify it under the terms of the GNU General Public License         	     #
# as published by the Free Software Foundation, either version 3 of          #
# the License, or (at your option) any later version.                        #
#                                                                            #
# xdaq-eclipse-import.py is distributed in the hope that it will be useful   #
# but WITHOUT ANY WARRANTY; without even the implied warranty of             #
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the              #
# GNU General Public License for more details.                               #
#                                                                            #
# You should have received a copy of the GNU General Public                  #
# License along with xdaq-eclipse-import.py                                  #
# If not, see <http://www.gnu.org/licenses/> 				                         #
##############################################################################

import sys
import os
import fileinput
import subprocess
import string

# Check input parameter
if len(sys.argv) < 2:
   print "Error: ",sys.argv[0], ": missing operand"
   print "Usage: ", sys.argv[0], " FOLDER"
   print "FOLDER: this is full path where is the project to import."
   print
   exit(0)

input_file = sys.argv[1]+'/.project'


# Check Arduino IDE environment
try:
    bash_cmd="which arduino"
    ARDUINOPATH=subprocess.check_output(bash_cmd, shell=True, stderr=subprocess.STDOUT)
except subprocess.CalledProcessError as e:
    print "This tool requires Arduino IDE."
    exit(0)

bash_cmd="readlink -f `which arduino` | awk -F/ '{print $3}' | awk -F'-' '{print $2}'"
ARDUINOVER=subprocess.check_output(bash_cmd, shell=True) 
ARDUINOVER=ARDUINOVER.translate(string.maketrans("\n\t\r", "   "))
ARDUINOVER=ARDUINOVER.strip()
print ("Arduino IDE is installed (version %s)" % ARDUINOVER)
print

if not os.path.isfile(input_file):
   print sys.argv[0], ": missing folder. Please check the project location."
   exit(0)


f = open(input_file,'r')
filedata = f.read()
f.close()

# check current version of the project
vstart = filedata.find("arduino-")
if vstart > 0:
   vend = filedata.find("/",vstart+1)
   vold = filedata[vstart+8:vend]
   print ("Current version is <%s>" % vold)
else:
   print "Please check expected eclipse configuration file <.project>"
   exit(0)

# backup current configuration project 
os.system('cp ' + input_file + ' ' + input_file + '_BACK')

print 'Import Eclipse project under folder', sys.argv[1]
newdata = filedata.replace(vold, ARDUINOVER)

f = open(input_file,'w')
f.write(newdata)
f.close()


print 'Fix configuration files'
input_file = sys.argv[1]+'/.settings/org.eclipse.cdt.core.prefs'

# backup current configuration project 
os.system('cp ' + input_file + ' ' + input_file + '_BACK')

f = open(input_file,'r')
filedata = f.read()
f.close()

newdata = filedata.replace(vold, ARDUINOVER)

f = open(input_file,'w')
f.write(newdata)
f.close()

print ('Project successfully updated to version <%s>' % str(ARDUINOVER))
