#!/bin/bash

#########################################################################
# xdaq-setup.sh                                                         #
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

source ./xdaq-shared.sh


# Show package status
function InitPackagesStatus()
{
	CheckMainEnvironments

	# Global variable to manage the Menu
	XDAQ_MENU=(
     "[  0] Exit   [ -1] Reboot"
     ""
     ""
     ""
     "[  1] Core               "
     "[  2] Libraries          "
     "[  3] Optional           "
     ""
     ""
     ""
     "[110] Install XDAQ       "
     "[111] Install Debianinux "
     "[112] Install Libraries  "
     "[113] Install Optional   "
     "[114] Install VMwareTools"
     "" "" "" "" ""
     "[120] Show Config        "
     "[121] Refresh Config     "
     "[122] Serial Port        "
     "[123] Time Zone          "
     "[124] Keyboard           "
     "[125] XDAQ Panel         "
	)
}


# Check current XDAQ/Desktop Applications
function CheckXDAQDesktop()
{
	rm -rf $HOMEDEV/XDAQ/Desktop
	mkdir $HOMEDEV/XDAQ/Desktop
	cp $GNOME_SHARE_APPS/xdaq*.desktop $HOMEDEV/XDAQ/Desktop

	# Validate all current applications
	chmod +x $HOMEDEV/XDAQ/Desktop/*
	chown -R $USERDEV:$USERDEV $HOMEDEV/XDAQ

	sudo -u $USERDEV gsettings set org.gnome.desktop.background show-desktop-icons true
}
 

function XDAQTools()
{
  COMMAND=$1
  ARG=$2
  
  dir_org=`pwd`
  cd $HOMEDEV/XDAQ/Tools
  ./$COMMAND $ARG

  cd $dir_org
}


# Check current configuration
function CheckCategory()
{
  CATEGORY=$1
  
  echo -e "\n[ XDAQ $CATEGORY ]" >> $XDAQ_REPORT_FILE

  dir_org=`pwd`
  cd $HOMEDEV/XDAQ/Tools

  unset IFS
  PCK_LIST=$(find xdaq-setup-* -type f -print | xargs grep XDAQ_CATEGORY=$CATEGORY|awk -F':' '{print $1}')
  PCK_LIST=(${PCK_LIST})
 
  pkg_counter=${#PCK_LIST[@]}
  for (( i=0; i<$pkg_counter; i++ ));
  do
    package_script=${PCK_LIST[$i]}
    XDAQTools $package_script "--version" >> $XDAQ_REPORT_FILE

    perc=$(($(($i*100))/$pkg_counter))
    echo -ne "Checking current XDAQ $CATEGORY configuration: $perc%\r"
  done
  echo "[$CATEGORY] check completed.                                         "

  cd $dir_org
}


function ShowSetup()
{
  CATEGORY=$1

  # Main Loop
  while :
  do

  echo
  echo "XDAQ Package Manager [$CATEGORY]"
  echo
  unset IFS

  PCK_LIST=($(find xdaq-setup-* -type f -print | xargs grep XDAQ_CATEGORY|grep $CATEGORY|awk -F':' ' {print $1}'|xargs grep XDAQ_PACKAGE|awk -F'=' '{print $2}'))
  PCK_COMM=($(find xdaq-setup-* -type f -print | xargs grep XDAQ_CATEGORY|grep $CATEGORY|awk -F':' ' {print $1}'))
 
  pkg_counter=${#PCK_LIST[@]}
  for (( i=0; i<$pkg_counter; i++ ));
  do
    unset IFS
    STRSPACE='                     '
    STRSPACE=${STRSPACE:0:21-${#PCK_LIST[$i]}}
    IFS='%'

    package_script=`grep "XDAQ_PACKAGE=${PCK_LIST[$i]}" xdaq-setup-* | awk -F':' '{print $1}'`
    package_status=$(XDAQTools $package_script -status)
    if [[ $package_status != "INSTALLED" ]]; then 
       PCK_LIST[$i]="${PCK_LIST[$i]}$STRSPACE Not Installed"
    fi
    
    PCK_LIST[$i]=${PCK_LIST[$i]//_/ }
    echo -e "[$(($i+1))]\t${PCK_LIST[$i]}"
  done

  echo 
  echo -e "[0]\tExit"
  echo -e "[-1]\tReboot" 

  echo ; sleep .5
  read -p "Which setup operation? " nSetup
  echo

  # Run required setup
  if [[ $nSetup == 0 ]]; then return ; fi
  if (( ( $nSetup > 0 ) && ( $nSetup <= $pkg_counter ) )); 
  then
      XDAQTools ${PCK_COMM[$(($nSetup-1))]} -reinstall
      nSetup=0
  fi
  if [[ $nSetup == -1 ]]; then nSetup=0 ; VMReboot ; fi
  if [[ $nSetup != 0 ]]; then echo "Error: Invalid option..." ; fi

  done

  unset IFS
}


# Check current configuration
function CheckConfig()
{
  # Initialize global variables
  InitPackagesStatus

  # Update XDAQ/Desktop
  CheckXDAQDesktop

  # Store current XDAQ configuration
  rm -rf $XDAQ_REPORT_FILE
  echo
  LogConfig

  CHECK_CONFIG=0
}


# Log current configuration
function LogConfig()
{
  echo -e "\n*** XDAQ Configuration ***\n"                                                                          >> $XDAQ_REPORT_FILE
  echo "[ Global Setting ]"                                                                                         >> $XDAQ_REPORT_FILE
  echo -e "XDAQ\t       v$XDAQVER"                                                                                  >> $XDAQ_REPORT_FILE 
  echo -e "USER\t       $USERDEV"                                                                                   >> $XDAQ_REPORT_FILE
  echo -e "HOME\t       $HOMEDEV"                                                                                   >> $XDAQ_REPORT_FILE
  echo -e "COM\t       $COM"                                                                                        >> $XDAQ_REPORT_FILE
  echo -e "ETH\t       $(sudo ifconfig|head -1|cut -c1-4)"                                                          >> $XDAQ_REPORT_FILE
  echo -e "TZ\t       `cat /etc/timezone` (`date`)"                                                                 >> $XDAQ_REPORT_FILE
  echo -e "KYBRD\t       `eval $CHECK_KEYBOARD_COMMAND`"                                                            >> $XDAQ_REPORT_FILE

  # Initialize global variables
  InitPackagesStatus
  
  CheckCategory CORE
  CheckCategory LIBRARY
  CheckCategory OPTIONAL

  echo                                            >> $XDAQ_REPORT_FILE
  echo "[ DEBIANINUX ]"                           >> $XDAQ_REPORT_FILE
  XDAQTools xdaq-setup-debianinux.sh --version    >> $XDAQ_REPORT_FILE
  echo                                            >> $XDAQ_REPORT_FILE
}


# Show current configuration
function ShowConfig()
{
  more $XDAQ_REPORT_FILE
}


# XDAQ Libraries Auto Installer
function XDAQAutoInstaller()
{
  CATEGORY=$1

  unset IFS

  dir_org=`pwd`
  cd $HOME_TOOLS
  PCK_LIST=($(find xdaq-setup-* -type f -print | xargs grep XDAQ_CATEGORY|grep $CATEGORY|awk -F':' ' {print $1}'))

	pkg_counter=${#PCK_LIST[@]}
  for (( i=0; i<$pkg_counter; i++ ));
  do
	  perc=$(($(((($i+1))*100))/$pkg_counter))
	  echo -e "\n[XDAQ Installer] $perc% ( $(($i+1))/$pkg_counter ) Packages\n"
   
    ./${PCK_LIST[$i]} -reinstall Y
  done

  echo
	echo "XDAQ installation completed [$CATEGORY Packages]"
  echo

  cd $dir_org
}



# Debianunix Auto Installer
function Setup_Debianinux()
{
      echo
      echo "This option will install Debianinux."
      echo
      echo "Debianinux includes:"
      echo "1. OS Update and Upgrade"
      echo "2. VMware Tools"
      echo "3. GNOME Desktop environment"
      echo "4. XDAQ Integrations"
      echo "4.1 Java Runtime Environment"
      echo "4.2 Python Environment and package management tools (pip and yolk)"
      echo "5, GitHub tools: Git and Giggle"
      echo "6. Arduino IDE"
      echo "7. Eclipse IDE"
      echo

      XDAQTools xdaq-setup-debianinux.sh "-reinstall"
      CheckMainEnvironments

      # Customize Debianinux Desktop (add desktop background)
      cp -f $HOMEDEV/XDAQ/Admin/debianinux-background_1* /usr/share/images/desktop-base
      cp -f $HOMEDEV/XDAQ/Admin/debianinux-desktop-background.xml /usr/share/images/desktop-base/desktop-background.xml

      echo -e "\n*** Debianinux Installation Completed ***\n"
      echo "Please reboot the system when complete setup of"
      echo -e "your XDAQ environment.\n"
}


# XDAQ Auto Installer
function Setup_XDAQ()
{
  echo
  echo "This option will install all XDAQ packages."
  echo
  echo "XDAQ v$XDAQVER includes:"
  echo "1. Debianinux"
  echo "2. XDAQ Core"
  echo "3. XDAQ Core - Libraries"
  echo

  echo -n "[SETUP] Install XDAQ " ; sleep .3
  read -e -i Y -p "(Y/n)? " ; echo
  if [[ $REPLY =~ ^[Yy]$ ]];
  then
      Setup_Debianinux

      # Install XDAQ extra core packages
      echo -e "\nInstall XDAQ Core\n"

      PCK_LIST=(
        "xdaq-setup-doxygen.sh"
        "xdaq-setup-fritzing.sh"
        "xdaq-setup-gnuoctave.sh"
        "xdaq-setup-gnuplot.sh"
        "xdaq-setup-gsl.sh"
        "xdaq-setup-openframeworks.sh"
        "xdaq-setup-processing.sh"
        "xdaq-setup-qt.sh"
        "xdaq-setup-scilab.sh"
        "xdaq-setup-scipy.sh"
        "xdaq-setup-sqlite.sh"
        "xdaq-setup-texmaker.sh"
      )

      pkg_counter=${#PCK_LIST[@]}
      for (( i=0; i<$pkg_counter; i++ ));
      do
        perc=$(($(((($i+1))*100))/$pkg_counter))
        echo -e "\n[XDAQ Installer] $perc% ( $(($i+1))/$pkg_counter ) Packages\n"
   
        XDAQTools ${PCK_LIST[$i]} "-reinstall Y"
      done

      Setup_Libraries

      # Customize XDAQ Desktop (add desktop background)
      cp -f $HOMEDEV/XDAQ/Admin/xdaq-background_1* /usr/share/images/desktop-base
      cp -f $HOMEDEV/XDAQ/Admin/xdaq-desktop-background.xml /usr/share/images/desktop-base/desktop-background.xml

      echo -e "\n*** XDAQ Installation Completed ***\n"
      echo "Please reboot the system when complete setup of"
      echo -e "your XDAQ environment.\n"
fi
}


# XDAQ Libraries Auto Installer
function Setup_Libraries()
{
  XDAQAutoInstaller LIBRARY

  # Customize XDAQ Desktop (add desktop background)
  cp -f $HOMEDEV/XDAQ/Admin/xdaq-background_1* /usr/share/images/desktop-base
  cp -f $HOMEDEV/XDAQ/Admin/xdaq-desktop-background.xml /usr/share/images/desktop-base/desktop-background.xml

  echo -e "\n*** XDAQ Libraries Installation Completed ***\n"
}


# XDAQ Optional Components Auto Installer
function Setup_Optional()
{
  
  XDAQAutoInstaller OPTIONAL
  echo -e "\n*** XDAQ Optional Components installation completed ***\n"
}


# Gnome Menu Customization
# Input: "desktop" configuration file (e.g. arduino.desktop)
function ConfigGnomeMenu()
{
	echo "Categories=Development" >> $GNOME_SHARE_APPS/$1.desktop
	echo "GenericName=XDAQ Debianinux" >> $GNOME_SHARE_APPS/$1.desktop
	mv $GNOME_SHARE_APPS/$1.desktop $GNOME_SHARE_APPS/xdaq-$1.desktop
}


# VMware Tools
function Setup_VMwareTools()
{
  XDAQTools xdaq-setup-vmware.sh "-reinstall"
}


# SERIAL PORT
function SetSerialPort()
{
	# Serial Port configuration
	COM_SETTING="115200 -parenb -parodd cs8 -hupcl -cstopb cread clocal -crtscts -ignbrk -brkint -ignpar -parmrk inpck -istrip -inlcr -igncr -icrnl -ixon -ixoff -iuclc -ixany -imaxbel -iutf8 -opost -olcuc -ocrnl -onlcr -onocr -onlret -ofill -ofdel nl0 cr0 tab0 bs0 vt0 ff0 -isig -icanon -iexten -echo -echoe -echok -echonl -noflsh -xcase -tostop -echoprt -echoctl -echoke"

	check_com=TRUE
	max_attempts=5
	while [[ $check_com == TRUE && $max_attempts > 0 ]]
	do
		COM=/dev/`dmesg | grep tty|tail -1|awk -F: '{print $3}'|awk -F: '{print $1}'|awk -F' ' '{print $1}'`
		ls $COM &>/dev/null
		echo -e "\n[SETUP] Default Serial Port for Arduino connection: $COM\n"
		if [ ! -c $COM ];
		then
			echo "WARNING: expected serial port does not work."
			echo "Please check standard serial Arduino board connection."
			echo "and check WMware Player > Removable Devices > Arduino XXX > Connect"
			echo "Arduino Serial Port within XDAQ environment has default value of 115200 bps."
			echo
	
			echo -n "Try again " ; sleep .3
			read -e -i Y -p "(Y/n)? " ; echo
			if [[ $REPLY =~ ^[Nn]$ ]]; then check_com=FALSE ; fi
		else
			check_com=FALSE
		fi
		
		# Exit after 5 attempts
		max_attempts=$(($max_attempts - 1))
	done

	if [ "$1" == "" ]; 
	then
		# Set permissions
		echo "Grant permissions to <$USERDEV> to use Arduino Serial Port ($COM)"
		adduser $USERDEV dialout
		chmod a+rw $COM

		# Set serial port configuration
		stty -F $COM $COM_SETTING
		echo -e "\nArduino Serial Port configured."
	fi
}


# TIME ZONE
function SetTimeZone()
{
	echo -n "[SETUP] Check for [TimeZone] " ; sleep .3
	read -e -i Y -p "(Y/n)? " ; echo
	if [[ $REPLY =~ ^[Yy]$ ]];
	then
		dpkg-reconfigure tzdata
	else
		echo "Current Time Zone is `cat /etc/timezone` (`date`)"
	fi
}


# KEYBOARD
function SetKeyboard()
{
	echo -n "[SETUP] Check for [Keyboard] " ; sleep .3
	read -e -i Y -p "(Y/n)? " ; echo
	if [[ $REPLY =~ ^[Yy]$ ]];
	then
		dpkg-reconfigure keyboard-configuration
	else
		echo "Current Keyboard is `eval $CHECK_KEYBOARD_COMMAND`"
	fi
}


# Show PXDAQ Panel
function ShowPanel()
{
	su - $USERDEV -c "nautilus ~/XDAQ/Desktop " &>/dev/null &
}



#
# MAIN SECTION
#

# PRIVILEGES
CheckAccess $EUID
if [[ $? == 0 ]];
then
    XDAQ_COMMAND="--help"
    echo
fi


echo -e "\n*** XDAQ Setup Tool ***\n"
echo "Insights to use this tool are available in the XDAQ Guide $XDAQVER."
echo "Please visit www.embeddedrevolution.info to get more info."
echo
echo "This script manage all required XDAQ packages to build a"
echo "scientific software ecosystem for Virtual Appliance, Debian"
echo "or Ubuntu contexts."
echo
date
echo
echo
echo "Current XDAQ Log Files:"
echo -e "Setup Monitoring: \t$XDAQ_LOG_FILE"
echo -e "Packages Status: \t$XDAQ_REPORT_FILE"
echo

# Check User Administrator access
if [[ $EUID != 0 ]]; 
then
	echo "This script must be executed as root."
	echo -e "Usage: sudo ~/XDAQ/Admin/xdaq-starter.sh\n"
	exit
fi


# CHECK SERIAL PORT for Arduino connection
SetSerialPort SCAN

# Global flag to check the status of all expected packages
CHECK_CONFIG=1


# Main Loop
while :
do
  # Check current installation status of some critical packages
  if [[ $CHECK_CONFIG == 1 ]]; then CheckConfig ; fi

  # Show Main Menu
  echo -e "\n\n[ XDAQ Setup ]   [Host IP `ifconfig |awk -F' ' '/Bcast/ {print $2}'`]\n"
  echo -e "\e[4mXDAQ Packages                                                                 \e[0m"
  echo -e "${XDAQ_MENU[4]} ${XDAQ_MENU[5]} ${XDAQ_MENU[6]}"
  echo

  echo -e "\e[4mXDAQ Management Tools                                                        \e[0m"
  echo -e "${XDAQ_MENU[10]} ${XDAQ_MENU[11]} ${XDAQ_MENU[12]}"
  echo -e "${XDAQ_MENU[13]} ${XDAQ_MENU[14]} ${XDAQ_MENU[20]}"
  echo -e "${XDAQ_MENU[21]} ${XDAQ_MENU[22]} ${XDAQ_MENU[23]}"
  echo -e "${XDAQ_MENU[24]} ${XDAQ_MENU[25]} ${XDAQ_MENU[0]}"

  echo ; sleep .5
  read -p "Which setup operation? " nSetup
  echo

  # Run required setup
  setup_function=""
  case $nSetup in
    -1) VMReboot ;;
     0) exit ;;

     1) ShowSetup CORE ;;
     2) ShowSetup LIBRARY ;;
     3) ShowSetup OPTIONAL ;;

   110) setup_function="Setup_XDAQ" ;;
   111) setup_function="Setup_Debianinux" ;;
   112) setup_function="Setup_Libraries" ;;
   113) setup_function="Setup_Optional" ;;
   114) setup_function="Setup_VMwareTools" ;;
   120) ShowConfig ;;
   121) CheckConfig ;;
   122) SetSerialPort ;;
   123) SetTimeZone ;;
   124) SetKeyboard ;;
   125) ShowPanel ;;

     *) echo "Error: Invalid option..."	;;
esac


if [[ "$setup_function" != "" ]];
then
    setup_option=`echo ${XDAQ_MENU[$(($nSetup-100))]}`
    setup_option=${setup_option##*]}
    setup_option=${setup_option%\\*}
    setup_option=`echo ${setup_option}`

    echo -e "\n[--------------------------------------------------]" >> $XDAQ_LOG_FILE
    date +"[SETUP:$nSetup] [%Y-%m-%d %H:%M] [$setup_option]" >> $XDAQ_LOG_FILE
    echo -e "[--------------------------------------------------]\n" >> $XDAQ_LOG_FILE

    echo -n "[SETUP:$nSetup] Confirm [$setup_option] Installation " ; sleep .3
    read -e -i Y -p "(Y/n)? " ; echo
    if [[ $REPLY =~ ^[Nn]$ ]];
    then
        echo "***Process Aborted***"  >> $XDAQ_LOG_FILE
        echo
    else
        CHECK_CONFIG=1
        echo -e "[SETUP:$nSetup] Install [$setup_option]"
        $setup_function | tee -a $XDAQ_LOG_FILE
        CheckMainEnvironments
    fi

    echo ; sleep .3
    read -p "Operation completed. Press [Enter] to continue..." readEnterKey
fi

done


echo
echo "See more details on XDAQ Guide available at www.embeddedrevolution.info" 
echo
