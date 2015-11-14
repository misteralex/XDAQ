#!/bin/bash

#########################################################################
# xdaq-starter.sh                                                       #
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

cd ~/XDAQ/Tools
source ./xdaq-shared.sh

# XDAQ MENU TEMPLATE
function Menu()
{
	echo -e "\n$1\n"

	menu_size=${#MENU[@]}
 	for (( i=0; i<$menu_size; i++ ));
    	do
		echo -e "${MENU[$i]}"
	done

	echo ; sleep .5
	read -p "Which XDAQ operation? " nSetup
	echo
	
	return -- $nSetup
}


# Get current Arduino toolchain full path
# OUTPUT: HOME_ARDUINO (global variable)
function GetArduinoHome()
{
	HOME_ARDUINO=`which arduino`

	if [ -z "$HOME_ARDUINO" ];
	then
		echo -e "\nWARNING: *** Please install Arduino IDE ***"
		HOME_ARDUINO=""
	else
		# Set Arduino Home
		HOME_ARDUINO=`readlink -f $HOME_ARDUINO`
		HOME_ARDUINO=`dirname $HOME_ARDUINO`

		# Set Serial Port
		COM=/dev/`dmesg | grep tty|tail -1|awk -F: '{print $3}'|awk -F: '{print $1}'|awk -F' ' '{print $1}'`
		echo -e "\n[***] Default Serial Port for Arduino connection: $COM\n"
		echo -e "If Serial Port does not work properly check it"
		echo -e "through the option: [XDAQ Setup] > [Serial Port]\n" ; sleep .5
	fi
}


# OPEN ARDUINO EXAMPLE
function OpenArduinoExample()
{
	FILENAME=`basename $1`
	CHECK_ARDUINO_IDE=`ps afx |grep -i $FILENAME|grep -v grep|grep java|tail -1`
	
	if [ "$CHECK_ARDUINO_IDE" == "" ];
	then
		echo -e "\nWARNING: check Arduino IDE: Verify and Update your Arduino board.\n"
		arduino $1 &>/dev/null &
	else
		echo -e "\nWARNING: Arduino IDE is already opened for this project."
	fi
}


# EXECUTE CUTECOM as serial port tool
function ExecCuteCom()
{
	# Run XDAQ Serial Receiver (CuteCom) or Serial Monitor tool
	# Open remote section through Serial Port
	CHECK_CUTECOM=`which cutecom`
	if [ "$CHECK_CUTECOM" == "" ]; 
	then 	
		echo "WARNING: Missing CuteCom tool."
	else
		CHECK_CUTECOM=`ps -C cutecom -o pid=`
		if [ "$CHECK_CUTECOM" != "" ]; 
		then 
			echo "WARNING: CuteCom is already running."
		else 
			cutecom &
		fi
	fi
}


# XDAQ Setup
function XDAQSetup()
{
	sudo $HOMEDEV/XDAQ/Tools/xdaq-setup.sh $OSVERSION $USER
}


# XDAQ Tools
function XDAQTools()
{
while :
do
	# Global variable to manage the Menu
	MENU=(
        " [ 1] Manage Eclipse project version    "
        " [ 2] Make Arduino Project from Eclipse "
        " [ 3] Test Firmata Protocol             "
        ""
        " [99] Terminal                          "
        " [ 0] Exit                              "
	)
	Menu "\n [ XDAQ Tools ]"
	nChoice=$?

	case $nChoice in
		0)	return ;;
    99)	xdaq-terminal & ;;
		1) 	echo "[***] Import old Eclipse projects to current Arduino IDE."
        echo "Please specify full pathname of Eclipse project to update." ; sleep .3
        read -p "Which folder? " project
        echo
        $HOME_TOOLS/xdaq-eclipse-import.py $project
        ;;
    2) 	echo "[***] Make Arduino projects from Eclipse IDE."
        echo "Please specify full pathname of the Eclipse cpp module to convert." ; sleep .3
        read -p "Which module? " module
        echo
        $HOME_TOOLS/xdaq-eclipse-make-ino.sh $module
        ;;
    3) 	echo "[***] Test Firmata protocol from Python environment."
        echo "Use the Standard Firmata example from Arduino IDE"
        echo "to test the communication."
			
        echo
        echo "WARNING: Arduino board must be ready with a valid"
        echo "         Firmata protocol implementation."
        echo

        GetArduinoHome
        if [ "$HOME_ARDUINO" != "" ];
        then
            # Open Arduino IDE to build the example
				    OpenArduinoExample `find $HOME_ARDUINO -name StandardFirmata.ino`
				
            # Run Python test
            read -p "Press [Enter] to continue..." answer ; echo	
            $HOME_TOOLS/xdaq-test-firmata.py $COM
        fi
        ;;

    *)	echo "Error: Invalid option..."	;;
  esac
done
}



# XTable  > BlinkingLEDs (Arduino)
function XDAQExample_XTable_BlinkingLEDsArduino()
{
	echo "[***] XTable  > BlinkingLEDs (Arduino)."
	echo "This example show how works XTable class."
	echo 
	
	GetArduinoHome
	if [ "$HOME_ARDUINO" != "" ];
	then
		# Open Arduino IDE to build the example
		OpenArduinoExample $HOME_EXAMPLES/XTable/BlinkingLEDs_ino/BlinkingLEDs_ino.ino
			
		# Run BlinkingLEDs in Console Mode
		ExecCuteCom

		echo "Now you can configure your serie of blinking LEDs from default serial"
		echo "receiver (CuteCom) or from your favorite serial I/O management tool."
		echo
		echo "Press 'm' to show the menu to configure the behavior of Blinking LEDs."
		echo "The application can switch between two configuration (<a> and <b>)"
		echo "The Console Mode is available from statup of the Arduino Board within"
		echo "5 sec. then it swithes to Firmata Mode to process remote control."
		echo 
		echo "Find more about it in the XDAQ Guide"
		echo "available at www.embeddedrevolution.info"
		echo 
	fi
}



# XTable  > BlinkingLEDs_of (Arduino)
function XDAQExample_XTable_BlinkingLEDs_of()
{
	echo "[***] XTable  > TestXTableArduino"
	echo "This is a Unit Test for XTable class ."
	echo 
	
	GetArduinoHome
	if [ "$HOME_ARDUINO" != "" ];
	then
		# Open Arduino IDE to build the example
		OpenArduinoExample $HOME_EXAMPLES/XTable/BlinkingLEDs_ino/BlinkingLEDs_ino.ino

		# Run openFrameworks demo application
		echo "Now you should watch the demo and switch configuration clicking on"
		echo "the application window. If it does not work check the BlinkingLEDs"
		echo "firmware, reboot the board or review the Serial Port configuration"
		echo "from [XDAQ Setup] > [Serial Port] as already described."
		echo 
		echo "Find more about it in the XDAQ Guide"
		echo "available at www.embeddedrevolution.info"
		echo 

		# Open openFrameworks demo application 
		$HOME_EXAMPLES/XTable/BlinkingLEDs_of/BlinkingLEDs_of
	fi
}


# XTable  > TestXTableArduino (Arduino)
function XDAQExample_XTable_TestXTableArduino()
{
	echo "[***] XTable  > BlinkingLEDs_of"
	echo "This example show how works XTable class ."
	echo 
	
	GetArduinoHome
	if [ "$HOME_ARDUINO" != "" ];
	then
		# Open Arduino IDE to build the example
		OpenArduinoExample $HOME_EXAMPLES/XTable/TestXTable_ino/TestXTable_ino.ino
		
		# Monitor serial communication
		ExecCuteCom

		echo "Now you can monitor all test from default serial receiver"
		echo "(CuteCom) or from your favorite serial I/O management tool."
		echo
		echo "You will find two different test related to XTable class behaviour."
		echo "Within the source code there is a flag (CHECK_STORAGE_OPERATIONS)"
		echo "to select which set of test to perfome."
		echo
		echo "CHECK_STORAGE_OPERATIONS=0 to test all functionality that involve SRAM"
		echo "Expected test summary: 17 passed, 0 failed, and 0 skipped, out of 17 test(s)."
		echo
		echo "CHECK_STORAGE_OPERATIONS=1 to test all functionality that involve EEPROM"
		echo "Expected test summary: 5 passed, 0 failed, and 0 skipped, out of 5 test(s)."
		echo 
		echo "Find more about it in the XDAQ Guide"
		echo "available at www.embeddedrevolution.info"
		echo
	fi
}


# XEEPROM > xeeprom_read (Arduino)
function XDAQExample_XTable_xeeprom_readArduino()
{
	echo "[***] XTable  > xeeprom_read"
	echo "This example show how works XEEPROM class ."
        echo
	
	GetArduinoHome
	if [ "$HOME_ARDUINO" != "" ];
	then
		# Open Arduino IDE to build the example
		OpenArduinoExample $HOME_EXAMPLES/XEEPROM/xeeprom_read/xeeprom_read.ino
			
		# Monitor serial communication
		ExecCuteCom

		echo "Now you can monitor EEPROM content from default serial receiver"
		echo "(CuteCom) or from your favorite serial I/O management tool."
		echo
		echo "Find more about it in the XDAQ Guide"
		echo "available at www.embeddedrevolution.info"
		echo
	fi
}


# Libelium > Waspmote	
function XDAQExample_Libelium_Waspmote()
{
	echo "[***] Libelium > Waspmote"
	echo "This is a Libelium Waspmote Demo."
	echo
	
	if [ "`which waspmote`" != "" ];
	then
		# Start Libelium IDE
		iceweasel http://www.libelium.com/development/waspmote/code_generator &>/dev/null &
		waspmote &>/dev/null &

		echo "Find more about it in the XDAQ Guide"
		echo "available at www.embeddedrevolution.info"
		echo "and Libelium web site at www.libelium.com"
		echo 
    echo "Please wait while opening the applications..."
	else
		echo "Please install Demo products."
	fi
  echo
}


# Sunbedded > SODAQ > Mbili 
function XDAQExample_Sunbedded_SODAQ_Mbili()
{
	echo "[***] Sunbedded > SODAQ > Mbili"
	echo "This is a Sunbedded SODAQ Mbile Demo."
	echo
	
	GetArduinoHome
	if [ "$HOME_ARDUINO" != "" ];
	then
		if [ -d "$HOME_ARDUINO_LIB/libraries/Sodaq" ];
		then
			# Open Arduino IDE with Sunbedded SODAQ Mbili (Arduino 1284P) Demo
			iceweasel http://mbili.sodaq.net &>/dev/null &
			OpenArduinoExample $HOME_ARDUINO_LIB/libraries/Sodaq/tph_demo/tph_demo.ino

			echo "Now you can browse Sunbedded SODAQ Mbili (Arduino 1284P) Demo code"
			echo "Please check current board from Tools > Board"
			echo "and select the board > SODAQ Mbili 1284p 8MHz using Optiboot at 57600 baud"
			echo
			echo "Find more about it in the XDAQ Guide"
			echo "available at www.embeddedrevolution.info"
			echo "and Sunbedded at www.sunbedded.nl"
			echo 
      echo "Please wait while opening the applications..."
		else
			echo "Please install Demo products."
		fi
    echo
	fi
}


# Plotly > Streaming demo 
function XDAQExample_Plotly()
{
	echo "[***] Plotly > plotly_streaming_serial"
	echo "This is a Plotly Streaming Demo."
	echo
	
	GetArduinoHome
	if [ "$HOME_ARDUINO" != "" ];
	then
		if [ -d "/opt/plotly-arduino-api/plotly_project" ];
		then
			# Open Arduino IDE with Standard Firmata
			OpenArduinoExample `find $HOME_ARDUINO -name StandardFirmata.ino`
  
			echo "Use the Standard Firmata example from Arduino IDE"
			echo "to test streaming data."
			
			# Run nodejs demo
			read -p "Press [Enter] to continue..." answer ; echo

			echo "Starting serial streaming data process..."
			cd /opt/plotly-arduino-api/plotly_project
			simple_url=$(node simple-url.js |grep STREAMING|awk -F'=' '{print $2}' 2>&1)
			
			echo "Real-time Graphing and Data Logging: now you should see"
			echo "streaming data flow from your board directly to to the web page."
			echo
			echo "WARNING: Press Ctrl-d to exit from streaming."
			iceweasel $simple_url 2>&1 &
	
			echo
			echo "Find more about it in the XDAQ Guide"
			echo "available at www.embeddedrevolution.info"
			echo "and Plotly at https://plot.ly"
			echo 
      echo "Please wait while opening the applications..."
			
			node simple.js 2>&1
		else
			echo "Please install [Plotly] package."
		fi
    echo
	fi
}


# Linear technology > Linduino
function XDAQExample_LT_Linduino()
{
	echo "[***] Linear Technology > Linduino"
	echo "This is a Linduino Demo."
	echo
	
	GetArduinoHome
	if [ "$HOME_ARDUINO" != "" ];
	then
		if [ -d "$HOME_ARDUINO_LIB/LTSketchbook" ];
		then
			# Open Arduino IDE with Linduino example (i.e. LTC2449_Datalogger.ino)
			OpenArduinoExample $HOME_ARDUINO_LIB/LTSketchbook/Example_Designs/LTC2449_Datalogger/LTC2449_Datalogger.ino

			echo "Now you can browse Linduino LTCD2449_Datalogger Demo code"
			echo "Please also browse: Arduino > File > Sketchbook > LTSketchbook"
			echo
			echo "Find more about it in the XDAQ Guide"
			echo "available at www.embeddedrevolution.info"
			echo 
      echo "Please wait while opening the applications..."
		else
			echo "Please install Demo products."
		fi
    echo
	fi
}



# XDAQ EXAMPLES
function XDAQExamples
{

# Check current Arduino IDE Home
GetArduinoHome
if [ "$HOME_ARDUINO" == "" ]; then return ; fi

while :
do
	# Global variable to manage the Menu
	MENU=(
    	   " [ 1] XTable   > BlinkingLEDs        (Arduino)        "
    	   " [ 2] XTable   > BlinkingLEDs_of     (openFrameworks) "
         " [ 3] XTable   > TestXTable          (Arduino)        "
         " [ 4] XEEPROM  > xeeprom_read        (Arduino)	      "
         " [ 5] Plotly   > Streaming demo      (Plotly)         "
         " [ 6] Waspmote > Waspmote Pro Demo   (Libelium)       "
         " [ 7] SODAQ    > Mbili Demo          (Sunbedded)      "
         " [ 8] Linduino > LTC2449_Datalogger  (LT)             "
         ""
         " [ 0] Exit                                            "
  )
	Menu "\n [ XDAQ Examples ]"
	nChoice=$?

	case $nChoice in
		0)	return ;;
		1) 	XDAQExample_XTable_BlinkingLEDsArduino ;;
		2) 	XDAQExample_XTable_BlinkingLEDs_of ;;
		3) 	XDAQExample_XTable_TestXTableArduino ;;
		4) 	XDAQExample_XTable_xeeprom_readArduino ;;
		5) 	XDAQExample_Plotly ;;
		6) 	XDAQExample_Libelium_Waspmote ;;
		7) 	XDAQExample_Sunbedded_SODAQ_Mbili ;;
		8) 	XDAQExample_LT_Linduino ;;
		*)	echo "Error: Invalid option..."	;;
	esac

done
}


# Check current User
if [ "$USER" == "root" ];
then
	echo "Please start xdaq-starter.sh as user account."
	exit
fi


# Check current OS version (Debian/Ubuntu)
GetOSVersion
if [[ "$OSVERSION" == "NODEBIAN" ]];
then
	echo
	echo "WARNING: No Debian based distribution."
	echo "XDAQ is tested under releases: Debian Jessie, Debian Wheezy and Ubuntu (14.04)."
	echo "More info at www.embeddedrevolution.info"
	echo
fi

# Check XDAQ Project installation
if [ ! -d $HOMEDEV/XDAQ ];
then
   echo "Please install XDAQ environment."
   echo "More info are available at www.embeddedrevolution.info"
   exit
fi


# Check arguments to process XDAQ Tools requests
if [[ "$1" != "" ]];
then
    echo
    echo "Execute the XDAQ Tools: <XDAQ/Tools/xdaq-setup-$1.sh>" 
    sudo $HOMEDEV/XDAQ/Tools/xdaq-setup-$1.sh $2
    exit
fi


echo -e "\n[ XDAQ Starter ]\n"
echo "Insights to use this tool are available in the XDAQ Guide $XDAQVER."
echo "Please visit www.embeddedrevolution.info to get more info."
echo
date
echo
echo
echo "Current XDAQ Environment (Debian based):"
echo -e "Host OS: \t$OSVERSION"
echo -e "USER NAME: \t$USERDEV"
echo -e "USER HOME: \t$HOMEDEV"
echo -e "XDAQ HOME: \t$HOMEDEV/XDAQ"
echo -e "XDAQ TOOLS: \t$HOME_TOOLS"
echo -e "XDAQ EXAMPLES: \t$HOME_EXAMPLES"
echo -e "XDAQ VER: \t$XDAQVER"
echo

# Check Superuser access
if [ "`which sudo`" == "" ];
then
	echo "WARNING: Sudo tool is required to process installation packages."
	echo 
	echo -n "Install Sudo tool " ; sleep .3
	read -e -i Y -p "(Y/n)? " ; echo
	if [[ $REPLY =~ ^[Nn]$ ]];
	then
		echo
		exit
	else
		# INSTALL SUDO
		echo -e "\n[SETUP] Install Sudo tool: check for Sudo support."
		echo "(Require Administrator Privileges) "
		echo 
		su -c "apt-get --yes --force-yes --reinstall install sudo ; cp -f $HOMEDEV/XDAQ/Admin/sudoers /etc"
	fi
fi


# Check Arduino toolchain
GetArduinoHome


# Check update from GitHub
echo -n "Check for XDAQ updates " ; sleep .3
read -e -i Y -p "(Y/n)? "
if [[ $REPLY =~ ^[Yy]$ ]];
then
	echo "(Require Administrator Privileges) "
	cd /tmp
	su -c "rm -rf /tmp/XDAQ"
	git clone https://github.com/misteralex/XDAQ
	xdaq_update=`cat /tmp/XDAQ/revisions.txt |head -1|awk -F' ' '{print $2}'`
	if [ "$xdaq_update" != "$XDAQVER" ];
	then
		echo "New release $xdaq_update available"
		mv $HOMEDEV/XDAQ $HOMEDEV/XDAQ_$XDAQVER
		mv /tmp/XDAQ $HOMEDEV
		echo "XDAQ updated successfully."
		echo
		exec $HOMEDEV/xdaq-starter.sh
	else
		echo -e "\n *** This is latest XDAQ release. No update required. ***\n"
	fi
fi


# Check XTable-Arduino project
if [ ! -d $HOMEDEV/XDAQ/Projects/XTable-Arduino ];
then
    echo
    echo "Add latest release of XTable-Arduino project..."
    git clone git://github.com/misteralex/XTable-Arduino $HOMEDEV/XDAQ/Projects/XTable-Arduino
    echo
fi


# Main Loop
while :
do
	# Global variable to manage the Menu
	MENU=(
          " [ 1] XDAQ Setup    "
          " [ 2] XDAQ Tools    "
          " [ 3] XDAQ Examples "
          ""
          " [ 0] Exit   [ -1] Reboot"
  )
	Menu "\n [ XDAQ Starter ]"
	nChoice=$?
	
	case $nChoice in
  255)  VMReboot ;;
    0)  exit ;;
    1)  XDAQSetup ;;
    2)  XDAQTools ;;
    3)  XDAQExamples ;;

    *)  echo "Error: Invalid option..."	;;
	esac
done


echo
echo "See more details on XDAQ Guide available at www.embeddedrevolution.info" 
echo
