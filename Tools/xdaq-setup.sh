#!/bin/bash

#########################################################################
# xdaq-setup.sh Script to build XDAQ v1.0 Virtual Appliance             # 
# Copyright (C) 2015 by AF                                              #
#                                                                       #
# xdaq-setup.sh is free software: you can redistribute it and/or        #
# modify it under the terms of the GNU General Public License           #
# as published by the Free Software Foundation, either version 3 of     #
# the License, or (at your option) any later version.                   #
#                                                                       #
# xdaq-setup.sh is distributed in the hope that it will be useful,      #
# but WITHOUT ANY WARRANTY; without even the implied warranty of        #
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         #
# GNU General Public License for more details.                          #
#                                                                       #
# You should have received a copy of the GNU General Public             #
# License along with xdaq-setup.sh.                                     #
# If not, see <http://www.gnu.org/licenses/>                            #
#########################################################################


# Show installation process status
function UpdateSetupStatus()
{
	perc=$(($(($1*100))/$TOTAL_PACKAGES))
	echo -e "\n[XDAQ] $perc% ($1/$TOTAL_PACKAGES) $2\n"
}


# Check GNOME/ARDUINO/PYTHON environments
function CheckMainEnvironments()
{
	# Flag about GNOME setup
	GNOME_SUPPORT=""
	if [ -z `which gnome-session` ];
	then
		GNOME_SUPPORT="(Require GNOME)"
	fi

	# Flag about Arduino IDE setup
	ARDUINO_SUPPORT=""
	ARDUINOVER=""
	arduino_path=`which arduino`
	if [ -z $arduino_path ];
	then
		ARDUINO_SUPPORT="(Require Arduino)"
	else
		ARDUINOVER=`readlink -f $arduino_path | awk -F/ '{print $3}' | awk -F'-' '{print $2}'`
	fi

	# Flag about PYTHON setup
	PYTHON_SUPPORT=""
	if [ -z `which python` ];
	then
		PYTHON_SUPPORT="(Require Python)"
	fi
}


# Show package status
function InitPackagesStatus()
{
	CheckMainEnvironments

	# Global variable to manage the Menu
	XDAQ_MENU=(
	   "[  0] Exit   [ -1] Reboot"		""
	   ""					""
	   ""					""
	   ""					""
	   ""					""
	   ""					""
	   ""					""
	   ""					""
	   ""		 			""
	   ""		 			""
	   "[10] OS Update           " 		""
	   "[11] GNOME Desktop       " 		""
	   "[12] Integrations        "		""
	   "[13] GitHub              "		""
	   "[14] Arduino IDE         "		""
	   "[15] Eclipse IDE         "		""
	   ""					""
	   ""					""
	   ""					""
	   ""					""
	   "[20] Doxygen             "		""
	   "[21] Texmaker            "		""
	   "[22] Fritzing            "		""
	   "[23] Processing          "		""
	   "[24] openFrameworks      "		""
	   "[25] SQLite              "		""
	   "[26] SciPy Stack         "		""
	   "[27] GNU Octave          "		""
	   "[28] Gnuplot             "		""
	   "[29] GSL                 "		""
	   "[30] Scilab              "		""
	   "[31] Qt                  " 		"" 
	   "" "" "" "" "" "" ""	"" "" 		"" "" "" "" "" "" "" "" "" 
	   "" "" "" "" "" "" "" "" "" 		"" "" "" "" "" "" "" "" ""
	   "[50] ArduinoUnit         "		""
	   "[51] XTable              "		""
	   "[52] pyFirmata           "		""
	   "[53] Plotly              "		""
	   "" "" "" "" "" "" "" 		"" "" "" "" "" "" ""
	   "" "" "" "" "" "" "" "" ""	   	"" "" "" "" "" "" "" "" ""
	   "[70] Vim                 "		""
	   "[71] Xfig                "		""
	   "[72] GNU Units           "		""
	   "[73] PuTTY               "		""
	   "[74] EAGLE PCB Design    "		""
	   "" "" "" "" "" "" "" "" "" "" "" ""  "" "" "" "" "" "" "" "" "" "" "" ""
	   "" "" "" "" "" "" "" "" "" "" "" ""  "" "" "" "" "" "" "" "" "" "" "" ""
	   ""			 		""
	   "[100] XDAQ Demo          "		""
	   "" "" "" "" "" "" "" "" ""		"" "" "" "" "" "" "" "" ""
     "[110] Install XDAQ       "		""
	   "[111] Install Debianinux "		""
	   "[112] Install Libraries  "		""
	   "[113] Install Optional   "		""
	   "[114] Install VMwareTools"		""
	   "" "" "" "" ""			"" "" "" "" ""
	   "[120] Show Config        "		""
	   "[121] Refresh Config     "		""
  	 "[122] Serial Port        "		""
	   "[123] Time Zone          "		""
	   "[124] Keyboard           "		""
	   "[125] XDAQ Panel         "		""

	)

	# Global variable to manage packages version
	PKG_VER=(
	"VMware Tools      "	""	""			            203	"vmware-toolbox-cmd" 					                      "vmware-toolbox-cmd -v"
	"System info       "	""	""			            10	"uname" 						                                "uname -v" 								
	"GCC Toolchain     "  ""	""			            10	"gcc" 							                                "gcc --version |grep gcc|awk -F' '  '{print \$4}'"	
	"Gnome Desktop     "	""	""			            11	"gnome-session" 					                          "dpkg -l|grep gnome-session-bin|awk -F' ' '{print \$3}'"
	"Java              "	""	""			            12	"java" 							                                "java -version 2>&1|grep \"java version\"|awk -F' ' '{print \$3}'|awk -F'\"' '{print \$2}'"
	"Python            "	""	""			            12	"python" 						                                "python -V 2>&1 |awk -F' ' '{print \$2}'"
	"Sudo              "	""	""			            12	"sudo" 							                                "sudo -V |grep \"Sudo version\"|awk -F' ' '{print \$3}'"
	"SSH               "	""	""			            12	"ssh" 							                                "ssh -V 2>&1|awk -F' ' '{print \$1}'"
	"Serial Receiver   "	""	"$GNOME_SUPPORT"	  12	"cutecom" 						                              "dpkg -l|grep cutecom|awk -F' ' '{print \$3}'"
	"Git               "	""	""			            13	"git" 							                                "git --version|awk -F' ' '{print \$3}'"
	"Giggle            "	""	"$GNOME_SUPPORT"	  13	"giggle" 						                                "dpkg -l|grep giggle|awk -F' ' '{print \$3}'"
	"Arduino IDE       "	""	"$GNOME_SUPPORT"	  14	"arduino" 						                              "echo $ARDUINOVER"
	"Eclipse IDE       "	""	"$GNOME_SUPPORT"	  15	"eclipse" 						                              "cat /opt/eclipse/.eclipseproduct |grep version|awk -F= '{print \$2}'"

	"Doxygen           "	""	""			            20	"doxygen" 						                              "doxygen --version"		
	"Texmaker          "	""	"$GNOME_SUPPORT"	  21	"texmaker" 						                              "dpkg -l|grep texmaker-data|awk -F' ' '{print \$3}'"
	"Fritzing          "	""	"$GNOME_SUPPORT"	  22	"fritzing" 						                              "echo $FRITZINGVER"
	"Processing        "	""	"$GNOME_SUPPORT"	  23	"processing"						                            "readlink -f `which processing` | awk -F/ '{print \$3}' | awk -F'-' '{print \$2}'"
	"openFrameworks    "	""	"$GNOME_SUPPORT"	  24	"/opt/of_libs_openFrameworks"				                "echo $OFVER"
	"SQLite            "	""	""			            25	"sqlite3" 						                              "sqlite3 --version|awk -F' ' '{print \$1}'"
	"[SciPy] numpy     "	""	"$PYTHON_SUPPORT"	  26	"/usr/lib/python2.7/dist-packages/numpy" 		        "dpkg -l|grep python-numpy|awk -F' ' '{print \$3}'"
	"[SciPy] scipy     "	""	"$PYTHON_SUPPORT"	  26	"/usr/lib/python2.7/dist-packages/scipy"		        "dpkg -l|grep python-scipy|awk -F' ' '{print \$3}'|awk -F'+' '{print \$1}'"
	"[SciPy] matplotlib"	""	"$PYTHON_SUPPORT"	  26	"/usr/lib/python2.7/dist-packages/matplotlib"	      "dpkg -l |grep python-matplotlib| grep i386 | awk -F' ' '{print \$3}'"
	"[SciPy] ipython   "	""	"$PYTHON_SUPPORT"	  26	"ipython" 						                              "exec ipython --version 2>&1"
	"[SciPy] notebook  "	""	"$PYTHON_SUPPORT"	  26	"/usr/share/ipython/notebook"				                "dpkg -l|grep ipython-notebook-common|awk -F' ' '{print \$3}'|awk -F'+' '{print \$1}'"
	"[SciPy] pandas    "	""	"$PYTHON_SUPPORT"	  26	"/usr/lib/python2.7/dist-packages/pandas"		        "dpkg -l|grep python-pandas|grep i386|awk -F' ' '{print \$3}'"
	"[SciPy] sympy     "	""	"$PYTHON_SUPPORT"	  26	"/usr/lib/python2.7/dist-packages/sympy"		        "dpkg -l|grep python-sympy|awk -F' ' '{print \$3}'"
	"[SciPy] nose      "	""	"$PYTHON_SUPPORT"	  26	"/usr/lib/python2.7/dist-packages/nose"			        "dpkg -l|grep python-nose|awk -F' ' '{print \$3}'"
	"GNU Octave        "	""	"$GNOME_SUPPORT"	  27	"octave"						                                "octave --version 2>&1|grep \"GNU Octave\"|awk -F' ' '{print \$4}'"
	"Gnuplot           "	""	"$GNOME_SUPPORT"	  28	"gnuplot" 						                              "echo $GNUPLOTVER"
	"GSL               "	""	"$GNOME_SUPPORT"	  29	"/usr/local/include/gsl" 				                    "echo $GSLVER"
	"Scilab            "	""	"$GNOME_SUPPORT"	  30	"/usr/local/bin/scilab" 				                    "echo $SCILABVER"
	"Qt                "	""	"$GNOME_SUPPORT"	  31	"designer-qt4" 						                          "dpkg -l|grep qt4-dev-tools|awk -F' ' '{print \$3}'|awk -F'+' '{print \$1}'"

	"ArduinoUnit       "  ""	"$ARDUINO_SUPPORT"  50	"$HOMEDEV/Arduino/libraries/arduinounit-master"     "echo $ARDUINOUNITVER"
	"XTable            "  ""	"$ARDUINO_SUPPORT"	51	"$HOMEDEV/Arduino/libraries/XTable-Arduino"		      "cat $HOMEDEV/Arduino/libraries/XTable-Arduino/library.properties 2>&1|grep version|awk -F'=' '{print \$2}'"
	"pyFirmata         "	""	"$PYTHON_SUPPORT"	  52	"/usr/local/lib/python2.7/dist-packages/pyfirmata"	"exec pip freeze 2>&1 |grep -i pyFirmata|awk -F'==' '{print \$2}'"
	"Plotly            "	""	"$ARDUINO_SUPPORT"	53	"/opt/plotly-arduino-api"				                    "echo $PLOTLYVER"
	"Node.js           "	""	""			            53	"node" 							                                "echo $NODEJSVER"

	"Vim               "	""	"$GNOME_SUPPORT"	  70	"gvim" 							                                "dpkg -l|grep vim-gnome|awk -F' ' '{print \$3}'"
	"Xfig              "	""	"$GNOME_SUPPORT"	  71	"xfig" 							                                "dpkg -l|grep xfig|grep i386|awk -F' ' '{print \$3}'"
	"GNU Units         "	""	"$GNOME_SUPPORT"	  72	"units" 						                                "dpkg -l|grep units|awk -F' ' '{print \$3}'"
	"PuTTY             "	""	"$GNOME_SUPPORT"	  73	"putty" 						                                "dpkg -l|grep putty-tools|awk -F' ' '{print \$3}'|awk -F'+' '{print \$1}'"
	"EAGLE PCB Design  "	""	"$GNOME_SUPPORT"	  74	"eagle" 						                                "echo $EAGLEPCBVER"

	"Libel. Waspmote   "	""	"$GNOME_SUPPORT"	  100	"waspmote" 						                              "echo $LIB_WASPMOTEVER"
	"Libel. Plug&Sense!"	""	"$GNOME_SUPPORT"	  100	"waspmote" 						                              "echo $LIB_PLUGSENSEVER"
	"Sunbe. SODAQ Mbili"	""	"$ARDUINO_SUPPORT"	100	"$HOMEDEV/Arduino/libraries/Sodaq" 			            "echo $SUNBED_SODAQVER"
	)
}


# Check current XDAQ/Desktop Applications
function CheckXDAQDesktop()
{
	rm -rf $HOMEDEV/XDAQ/Desktop/*
	cd  $HOMEDEV/XDAQ/Desktop
	cp $GNOME_SHARE_APPS/xdaq*.desktop .

	# Validate all current applications
	chmod +x *
	chown -R $USERDEV:$USERDEV $HOMEDEV/XDAQ

	sudo -u $USERDEV gsettings set org.gnome.desktop.background show-desktop-icons true

}
 


# Check groups of packages for each XDAQ section
function CheckPkgGroup()
{
	required_id=$1
	installed_section=1
	pkg_counter=${#PKG_VER[@]}
 	for (( i=0; i<$pkg_counter; i+=6 ));
	do
		if [ "${PKG_VER[$i+3]}" == "$required_id" ];
		then
		 	if [ "${PKG_VER[$i+1]}" == "" ]; then installed_section=0 ; fi
		fi
	done
	XDAQ_MENU[$(($1*2+1))]=$installed_section
}


# Check current configuration
function CheckConfig()
{
	# Initialize global variables
	InitPackagesStatus

	pkg_counter=${#PKG_VER[@]}
 	for (( i=0; i<$pkg_counter; i+=6 ));
    	do
		PKG_VER[$i+1]=""
		pkg_check=${PKG_VER[$i+4]}
		if [[ "`which $pkg_check`" != "" ]] || [[ ${pkg_check:0:1} == "/" && -d $pkg_check ]]; 
		then 
			if [ ! -z "`eval ${PKG_VER[$i+5]}`" ]; then PKG_VER[$i+1]=`eval ${PKG_VER[$i+5]}` ; fi
		fi

		idx=${PKG_VER[$i+3]}
		idx=$(($idx*2+1))
		XDAQ_MENU[$idx]="1"
		if [ "${PKG_VER[$i+1]}" == "" ]; then XDAQ_MENU[$idx]="0" ; fi

		perc=$(($(($i*100))/$pkg_counter))
		echo -ne "Checking current XDAQ configuration: $perc%\r"
	done
	echo "Check completed.                              "


	# Check groups of packages for each XDAQ section
	  # Check <OS Update> section
	  CheckPkgGroup 10

	  # Check <Integrations> section
	  CheckPkgGroup 12

	  # Check <GitHub> section
	  CheckPkgGroup 13

	  # Check <SciPy Stack> section
	  CheckPkgGroup 26

	  # Check <Plotly> section
	  CheckPkgGroup 53

	  # Check <Marketplace Products> section
	  CheckPkgGroup 100


	# Update Menu Layout
	pkg_counter=${#XDAQ_MENU[@]}
	for (( i=20; i<$pkg_counter; i+=2 ));
	do
		if [[ "${XDAQ_MENU[$(($i+1))]}" == "0" ]]; then XDAQ_MENU[$i]="\e[7m${XDAQ_MENU[$i]}\e[0m" ; fi
	done

	# Update XDAQ/Desktop
	CheckXDAQDesktop

	# Store current XDAQ configuration
	rm -rf $XDAQ_REPORT_FILE
	LogConfig > $XDAQ_REPORT_FILE

	CHECK_CONFIG=0
}


# Log current configuration
function LogConfig()
{
	echo -e "\n*** XDAQ Configuration ***\n"
	echo "[ Global Setting ]"
	echo -e "XDAQ\t\t       v$XDAQVER"
	echo -e "USER\t\t       $USERDEV"
	echo -e "HOME\t\t       $HOMEDEV"
	echo -e "COM\t\t       $COM"
	echo -e "ETH\t\t       `ifconfig |awk -F' ' '/HWaddr/ {print $1}'` (`ifconfig |awk -F' ' '/Bcast/ {print $2}'`)"
	echo -e "TZ\t\t       `cat /etc/timezone` (`date`)"
	echo -e "KYBRD\t\t       `eval $CHECK_KEYBOARD_COMMAND`"

	echo -e "\n[ XDAQ Core - DEBIANINUX ]"
	pkg_counter=${#PKG_VER[@]}
	for (( i=0; i<$pkg_counter; i+=6 ));
    	do
	    if [ "${PKG_VER[$i+3]}" == "20" ];
	    then
		echo
	    	echo "[ XDAQ Core - Libraries - Optional ]"
	    fi

	    PKGVER=${PKG_VER[$i+1]}
	    if [ "${PKG_VER[$i+1]}" == "" ]; then PKGVER="Not Installed" ; fi
	    printf "%-22s %-20s  %s" "${PKG_VER[$i]}" "$PKGVER" "${PKG_VER[$i+2]}"
	    echo
    	done
}


# Show current configuration
function ShowConfig()
{
	more $XDAQ_REPORT_FILE
}


# OS Restart  
function VMReboot 
{	
	echo -n "Reboot OS now " ; sleep .3
	read -e -i Y -p "(Y/n)? "
	if [[ $REPLY =~ ^[Yy]$ ]];
	then
		echo "XDAQ is rebooting..."
		reboot
		exit
	fi
	echo
}


# Debianunix Auto Installer
function DebianinuxInstaller()
{
	# Set global variable about progress status indicator
	TOTAL_PACKAGES=7
	if [ "$1" != "" ]; then TOTAL_PACKAGES=$1 ; fi

  	echo
	  echo "This option will install Debianinux."
  	echo
  	echo "Debianinux includes:"
  	echo "1. OS Update and Upgrade"
  	echo "2. GNOME Desktop environment"
  	echo "3. XDAQ Integrations"
  	echo "3.1 Java Runtime Environment"
  	echo "3.2 Python Environment and package management tools (pip and yolk)"
  	echo "4, GitHub tools: Git and Giggle"
  	echo "5. Arduino IDE"
  	echo "6. Eclipse IDE"
  	echo

		echo "Install Debianinux Substack"
		UpdateSetupStatus 0 "Install Debianinux Substack"

		UpdateSetupStatus 1 "Install OS Update/Upgrade"
		echo "Y"|Setup_OSUpdate
		
		UpdateSetupStatus 2 "Install GNOME Desktop environment"
		echo "Y"|Setup_GNOME ${XDAQ_MENU[23]}
		CheckMainEnvironments

		UpdateSetupStatus 3 "Install XDAQ Integrations: sudo, serial receiver and easy user access"
		echo "Y"|Setup_Integrations ${XDAQ_MENU[25]}
		CheckMainEnvironments

		UpdateSetupStatus 4 "Install Git Tools: Git terminal tool and Giggle"
		echo "Y"|Setup_GitTools ${XDAQ_MENU[27]}

		UpdateSetupStatus 5 "Install Arduino IDE version $ARDUINOVER"
		echo "Y"|Setup_ArduinoIDE ${XDAQ_MENU[29]}
		CheckMainEnvironments

		UpdateSetupStatus 6 "Install Eclipse IDE (Luna release)"
		Setup_EclipseIDE ${XDAQ_MENU[31]}

		# Customize Debianinux Desktop (add desktop background)
		cp -f $HOMEDEV/XDAQ/Admin/debianinux-background_1* /usr/share/images/desktop-base
		cp -f $HOMEDEV/XDAQ/Admin/debianinux-desktop-background.xml /usr/share/images/desktop-base/desktop-background.xml

		UpdateSetupStatus 7 "Debianinux Installation Completed"
		echo -e "\n*** Debianinux Installation Completed ***\n"
		echo "Please reboot the system when complete setup of"
		echo -e "your XDAQ environment.\n"
}


# XDAQ Auto Installer
function XDAQInstaller()
{	
  # Set global variable about progress status indicator
	TOTAL_PACKAGES=27

	echo
	echo "This option will install all XDAQ packages."
	echo
	echo "XDAQ v$XDAQVER includes:"
	echo "1. Debianinux"
	echo "2. XDAQ Core"
	echo "3. XDAQ Core - Libraries"

	echo -n "[SETUP] Install XDAQ " ; sleep .3
	read -e -i Y -p "(Y/n)? " ; echo
	if [[ $REPLY =~ ^[Yy]$ ]];
	then
	  	UpdateSetupStatus 0 "Install XDAQ Stack v$XDAQVER"
	  	echo "Install XDAQ Stack v$XDAQVER"

		  DebianinuxInstaller $TOTAL_PACKAGES
		
  		UpdateSetupStatus 8 "Install Doxygen"
  		echo "Y"|Setup_Doxygen ${XDAQ_MENU[41]}

	  	UpdateSetupStatus 9 "Install Texmaker"
	  	Setup_Texmaker ${XDAQ_MENU[43]}

		  UpdateSetupStatus 10 "Install Fritzing"
		  echo "Y"|Setup_Fritzing ${XDAQ_MENU[45]}

	  	UpdateSetupStatus 11 "Install Processing"
	  	echo "Y"|Setup_Processing ${XDAQ_MENU[47]}

		  UpdateSetupStatus 12 "Install openFrameworks"
		  echo "Y"|Setup_openFrameworks ${XDAQ_MENU[49]}

		  UpdateSetupStatus 13 "Install SQLite"
		  echo "Y"|Setup_SQLite ${XDAQ_MENU[51]}

		  UpdateSetupStatus 14 "Install SciPy Stack"
	  	echo "Y"|Setup_SciPyStack ${XDAQ_MENU[53]}

	  	UpdateSetupStatus 15 "Install GNU Octave"
	  	echo "Y"|Setup_GNUOctave ${XDAQ_MENU[55]}
		
	  	UpdateSetupStatus 16 "Install Gnuplot"
	  	echo "Y"|Setup_Gnuplot ${XDAQ_MENU[57]}

		  UpdateSetupStatus 17 "Install GSL"
		  echo "Y"|Setup_GSL ${XDAQ_MENU[59]}

		  UpdateSetupStatus 18 "Install Scilab"
  		echo "Y"|Setup_Scilab ${XDAQ_MENU[61]}

	  	UpdateSetupStatus 19 "Install Qt"
	  	echo "Y"|Setup_Qt ${XDAQ_MENU[63]}

		  XDAQLibrariesInstaller $TOTAL_PACKAGES "20"

	  	# Customize XDAQ Desktop (add desktop background)
	  	cp -f $HOMEDEV/XDAQ/Admin/xdaq-background_1* /usr/share/images/desktop-base
	  	cp -f $HOMEDEV/XDAQ/Admin/xdaq-desktop-background.xml /usr/share/images/desktop-base/desktop-background.xml
  
		  UpdateSetupStatus 27 "XDAQ Installation Completed"
		  echo -e "\n*** XDAQ Installation Completed ***\n"
		  echo "Please reboot the system when complete setup of"
		  echo -e "your XDAQ environment.\n"
	fi
}


# XDAQ Libraries Auto Installer
function XDAQLibrariesInstaller()
{
	# Set global variable about progress status indicator
	TOTAL_PACKAGES=5
	FIRST_PACKAGES=0
	if [ "$1" != "" ]; 
	then 
		TOTAL_PACKAGES=$1
		FIRST_PACKAGES=$2
	fi

	echo
	echo "This option will install only XDAQ Core - Libraries."
	echo

	UpdateSetupStatus $((0+$FIRST_PACKAGES)) "Install XDAQ Libraries"
	echo "Install XDAQ Libraries"

	UpdateSetupStatus $((1+$FIRST_PACKAGES)) "Install ArduinoUnit Library"
	echo "Y"|Setup_ArduinoUnit ${XDAQ_MENU[101]}

	UpdateSetupStatus $((2+$FIRST_PACKAGES)) "Install XTable Library"
	echo "Y"|Setup_XTable ${XDAQ_MENU[103]}

	UpdateSetupStatus $((3+$FIRST_PACKAGES)) "Install pyFirmata Library"
	echo "Y"|Setup_pyFirmata ${XDAQ_MENU[105]}

	UpdateSetupStatus $((4+$FIRST_PACKAGES)) "Install Plotly Library"
	echo "Y"|Setup_Plotly ${XDAQ_MENU[107]}

	# Customize XDAQ Desktop (add desktop background)
	cp -f $HOMEDEV/XDAQ/Admin/xdaq-background_1* /usr/share/images/desktop-base
	cp -f $HOMEDEV/XDAQ/Admin/xdaq-desktop-background.xml /usr/share/images/desktop-base/desktop-background.xml

	UpdateSetupStatus $((5+$FIRST_PACKAGES)) "XDAQ Libraries Installation Completed"
	echo -e "\n*** XDAQ Libraries Installation Completed ***\n"
}


# XDAQ Optional Components Auto Installer
function XDAQOptionalInstaller()
{
	TOTAL_PACKAGES=7

	echo
	echo "This option will install only XDAQ - Optional ."
	echo

	UpdateSetupStatus 0 "Install XDAQ - Optional Components"
	echo "Install XDAQ Optional Components"

	UpdateSetupStatus 1 "Install Vim"
	echo "Y"|Setup_gVim ${XDAQ_MENU[141]}

	UpdateSetupStatus 2 "Install Xfig"
	echo "Y"|Setup_Xfig ${XDAQ_MENU[143]}

	UpdateSetupStatus 3 "Install GNU Units"
	echo "Y"|Setup_GNUUnits ${XDAQ_MENU[145]}

	UpdateSetupStatus 4 "Install PuTTY"
	echo "Y"|Setup_PuTTY ${XDAQ_MENU[147]}

	UpdateSetupStatus 5 "Install EAGLE"
	Setup_EAGLE ${XDAQ_MENU[149]}

	UpdateSetupStatus 6 "Install Demo Products"
	Setup_Demo ${XDAQ_MENU[201]}

	UpdateSetupStatus 7 "XDAQ Optional Components installation completed"
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


# OS Update
function Setup_OSUpdate()
{
	echo "Manage OS updating"
	apt-get --yes --force-yes -f install
	apt-get --yes --force-yes --reinstall install build-essential
	apt-get --yes --force-yes --reinstall install linux-headers-$(uname -r)
	apt-get --yes --force-yes update
	apt-get --yes --force-yes upgrade
	apt-get --yes --force-yes -f install
	apt-get --yes --force-yes autoremove
	dpkg --configure -a

	if [ "$1" == "REBOOT" ];
	then
  		VMReboot
	fi
}


# GNOME
function Setup_GNOME()
{
if [ "$1" != "1" ];
then
	echo "Manage GNOME Desktop installation"
	apt-get --yes --force-yes --reinstall install gnome
	apt-get --yes --force-yes --reinstall install libcanberra-gtk-module:i386

#	CheckMainEnvironments
else
	echo "[GNOME] already installed."
fi
}



# XDAQ Integrations
function Setup_Integrations()
{
if [ "$1" != "1" ];
then
	echo -e "Install: [Integrations] and other basic integrations."
	echo "XDAQ Integrations includes:"
	echo "1. Sudo: run programs with Superuser security privileges"
	echo "2. Easy access for XDAQ tools from Desktop"
	echo "3. Serial receiver (i.e. CuteCom)"
	echo "4. Install SSH service for remote management"
	echo "5. Check Java and Python environments" 
	echo "6. Install some minor packages (i.e. xterm, ntp)"
	echo ; sleep 1

	# SUDO
	echo -e "\n[SETUP] Install Sudo tool: check for Sudo support"
	apt-get --yes --force-yes -f install
	apt-get --yes --force-yes --reinstall install sudo
	cp -f $HOMEDEV/XDAQ/Admin/sudoers /etc/sudoers

	
	# USER ACCESS AND CONFIGURATION
	  # Easy access through xdaq-starter.sh tool
	  echo "[SETUP] Manage XDAQ access and configuration"
	  cp -f $HOMEDEV/XDAQ/Admin/.bashrc /root/.bashrc 
 	  cp -f $HOMEDEV/XDAQ/Admin/xdaq-starter.desktop $GNOME_SHARE_APPS
	  cp -f $HOMEDEV/XDAQ/Admin/xdaq-starter-logo.png $GNOME_SHARE_ICONS

	  # Easy Desktop Access
	  if [ ! -d $HOMEDEV/Desktop ]; then mkdir $HOMEDEV/Desktop ; fi
	  cp -f $HOMEDEV/XDAQ/Admin/xdaq-panel.desktop $GNOME_SHARE_APPS/panel.desktop
	  cp -f $HOMEDEV/XDAQ/Admin/xdaq-panel.desktop $HOMEDEV/Desktop/panel.desktop
	  cp -f $HOMEDEV/XDAQ/Admin/xdaq-gnome-terminal.desktop $GNOME_SHARE_APPS
	  ln -sf $HOMEDEV/XDAQ/Tools/xdaq-starter.sh $HOMEDEV

	  # customize xterm icon
	  cp -f $HOMEDEV/XDAQ/Admin/xdaq-starter-logo.png /usr/share/icons/hicolor/scalable/apps/xterm-color.svg
	  cp -f $HOMEDEV/XDAQ/Admin/xdaq-starter-logo.png /usr/share/icons/hicolor/48x48/apps/xterm-color.png

	  # Fix user configuration and browser access
	  if [[ "`which iceweasel`" == "" && "`which firefox`" ]]; then ln -s /usr/bin/firefox /usr/bin/iceweasel ; fi


	  SetSerialPort
 	  Setup_CuteCom

	  # SSH Connection
	  echo -e "\n[SETUP] Install SSH tool for remote management"
	  apt-get --yes --force-yes -f install
	  apt-get --yes --force-yes --reinstall install ssh

	  # Java and Python
	  Setup_Java
	  Setup_Python

	  # Minor Pakcages
	  apt-get --yes --force-yes --reinstall install xterm
	  apt-get --yes --force-yes --reinstall install cmake
	  apt-get --reinstall install ntp
	
else
	  echo "[Integrations] already installed."
fi
}


# VMware Tools
function Setup_VMwareTools()
{
	echo "This option will install standard VMware Tools"
	echo "Please manage VMware Tools as expected from VMware Player."
	echo
	echo "*** CHECK: VMware Player > Manage > VMware Tools... ***"

	# Mount VMware Tools
	echo -e "\n[SETUP] Install standard VMware Tools: check for VMware tools"
	mount /dev/cdrom /media/cdrom

	# Fix WMware Tools exception for Ubuntu OS
	if [ -d /media/$USERDEV ]; then ln -s "/media/$USERDEV/VMware Tools" /media/cdrom ; fi 

	# Setup VMware Tools
	if [ -f /media/cdrom/manifest.txt ];
	then
		cd /media/cdrom
		vmwaretools_package=`ls VMwareTools-*`
		tar xvzf $vmwaretools_package -C /tmp
		cd /tmp/vmware-tools-distrib/
		echo -e "\n" | ./vmware-install.pl
		VMReboot
	else
		echo "*** Installation Error."
		echo "Please check virtual cdrom from VMware Player > Manage > Install VMware Tools..." ; sleep 1
		echo -n "Continue installation without WMware Tools " ; sleep .3
		read -e -i Y -p "(Y/n)? "
		if [[ $REPLY =~ ^[Nn]$ ]];
		then
			return
		fi
	fi

	# Shared Folder
	echo -e "\n[SETUP] Customize Shared Folders"
	if test "$(ls -A /mnt/hgfs/)";
	then
		rm -rf $HOMEDEV/Temp
		ln -s /mnt/hgfs/Temp $HOMEDEV/Temp
		echo "Shared Folder available at $HOMEDEV/Temp"
	else
		echo "*** Installation Error."
		echo "Please check shared folder from VMware Player > Manage > Virtual Machine Settings..."
		echo "Run VMware tool script sudo vmware-config-tools.pl (follow default options) from terminal to fix unexpected behaviors."
		echo
	fi
}


# Git Tools
function Setup_GitTools()
{
if [ "$1" != "1" ];
then
  	apt-get --yes --force-yes -f install
  	apt-get --yes --force-yes --reinstall install git

	  if [ ! -z "`which gnome-session`" ];
  	then
  		apt-get --yes --force-yes --reinstall install giggle
  		ConfigGnomeMenu giggle
  	else
  		echo "*** Installation Error."
  		echo "Giggle need GNOME support. Please check GNOME and try again"
  	fi
else
  	echo "[Git] already installed."
fi
}


# JAVA
function Setup_Java()
{
if [ "$1" != "1" ];
then
	echo -n "[SETUP] Check for [Java] setup "

	# Update Java VM
	echo "Check Java environment"
	apt-get --yes --force-yes -f install
	apt-get --yes --force-yes --reinstall install openjdk-7-jre
	update-alternatives --set java /usr/lib/jvm/java-7-openjdk-i386/jre/bin/java
else
	echo "[Java] already installed."
fi
}


# Python
function Setup_Python()
{
if [ "$1" != "1" ];
then
	echo -n "[SETUP] Check for [Python] "

	echo "Install Python (included <pip> package manager)"
	apt-get --yes --force-yes -f install
	apt-get --yes --force-yes --reinstall install python2.7
	ln -sf /usr/bin/python2.7 /usr/bin/python
	apt-get --yes --force-yes --reinstall install python-pip
	pip install yolk

#	CheckMainEnvironments
else
	echo "[Python] already installed."
fi
}


# Arduino IDE
function Setup_ArduinoIDE()
{
if [ "$1" != "1" ];
then
  	Setup_Java

  	echo -e "\nInstall Arduino IDE (Package: $ARDUINOPACKAGE}"
  	package_root=`echo $ARDUINOPACKAGE|awk -F'-' '{print $1"-"$2}'`
  	cd /tmp
  	rm -rf $ARDUINOPACKAGE $package_root
  	wget http://arduino.cc/download.php?f=/$ARDUINOPACKAGE -O $ARDUINOPACKAGE
  	tar xvf $ARDUINOPACKAGE $package_root/revisions.txt
  	ARDUINOVER=`cat arduino-nightly/revisions.txt|head -n1|awk -F' ' '{print $2}'`
  	rm -rf /opt/arduino*
  	mkdir /opt/arduino-$ARDUINOVER
  	tar xvf $ARDUINOPACKAGE -C /opt/arduino-$ARDUINOVER --strip-components=1
  	if [ -d /opt/arduino-$ARDUINOVER ];
  	then
  		chown -R $USERDEV:$USERDEV /opt/arduino-$ARDUINOVER
  		rm -rf arduino-$ARDUINOVER-linux32.tar.xz
  		rm -rf /usr/local/bin/arduino
  		ln -fs /opt/arduino-$ARDUINOVER/arduino /usr/local/bin/arduino
  		cp -f $HOMEDEV/XDAQ/Admin/xdaq-arduino.desktop $GNOME_SHARE_APPS
  		cp -f $HOMEDEV/XDAQ/Admin/xdaq-arduino-logo.png $GNOME_SHARE_ICONS

  		# Check Arduino user folders
  		if [ ! -d $HOMEDEV/Arduino ];
  		then
    			mkdir $HOMEDEV/Arduino
  	  		mkdir $HOMEDEV/Arduino/libraries
  		  	mkdir $HOMEDEV/Arduino/hardware
  		fi
  	else
  		echo "*** Installation Error. Try again Arduino IDE setup process."
  	fi

else
  	echo "[Arduino IDE] already installed."
fi
}


# Eclipse Luna
function Setup_EclipseIDE()
{
if [ "$1" != "1" ];
then
	  Setup_Java

  	cd /tmp
  	wget http://ftp.heanet.ie/pub/eclipse/technology/epp/downloads/release/luna/SR2/eclipse-cpp-luna-SR2-linux-gtk.tar.gz -O eclipse-cpp-luna-SR2-linux-gtk.tar.gz
  	tar xvzf eclipse-cpp-luna-SR2-linux-gtk.tar.gz -C /opt/
  	if [ -d /opt/eclipse ];
  	then
  		chown -R $USERDEV:$USERDEV /opt/eclipse
  		rm -rf eclipse-cpp-luna-SR2-linux-gtk.tar.gz
  		rm -rf /usr/local/bin/eclipse
  		ln -s /opt/eclipse/eclipse /usr/local/bin/eclipse
  		cp -f $HOMEDEV/XDAQ/Admin/xdaq-eclipse.desktop $GNOME_SHARE_APPS
  		cp -f $HOMEDEV/XDAQ/Admin/xdaq-eclipse-icon.png $GNOME_SHARE_ICONS
		
  		# Check external plugin
  		echo
  		echo "Please read Debianinux Guide to setup Arduino Eclipse Plugin and"
  		echo "XDAQ Guide to setup PyDev Eclipse Plugin from Eclipse Marketplace."
  	else
  		echo "*** Installation Error. Try again setup process."
  	fi
else
  	echo "[Eclipse IDE] already installed."
fi
}




###             ###
### XDAQ Core   ###
###             ###

# Doxygen
function Setup_Doxygen()
{
if [ "$1" != "1" ];
then
	apt-get --yes --force-yes -f install
	apt-get --yes --force-yes --reinstall install doxygen
else
	echo "[Doxygen] already installed."
fi
}


# ArduinoUnit
function Setup_ArduinoUnit()
{
if [ "$1" != "1" ];
then
	if [ ! -z "$ARDUINO_SUPPORT" ];
	then
		echo "[SETUP] ArduinoUnit library require pre-installed Arduino IDE"
		return
	fi

	rm -rf $HOMEDEV/Arduino/libraries/arduinounit*
	cd /tmp
	rm -rf master*
	wget https://github.com/mmurdoch/arduinounit/archive/master.zip
	unzip master -d $HOMEDEV/Arduino/libraries
	chown -R $USERDEV:$USERDEV $HOMEDEV/Arduino/libraries/ArduinoUnit
else
	echo "[ArduinoUnit] already installed."
fi
}


# Plotly
function Setup_Plotly()
{
if [ "$1" != "1" ];
then
	if [ ! -z "$ARDUINO_SUPPORT" ];
	then
		echo "[SETUP] Plotly library require pre-installed Arduino IDE"
		return
	fi

	plotly_opt=/opt/plotly-arduino-api
	cd /tmp
	rm -rf plotly-master.zip arduino-api-master
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
else
	echo "[Plotly] already installed."
fi
}


# Fritzing
function Setup_Fritzing()
{
if [ "$1" != "1" ];
then
	cd /tmp
	rm -rf fritzing-$FRITZINGVER.linux.i386.tar.bz2
	wget http://fritzing.org/download/$FRITZINGVER/linux-32bit/fritzing-$FRITZINGVER.linux.i386.tar.bz2
	rm -rf /opt/fritzing*
	mkdir /opt/fritzing-$FRITZINGVER
	tar -xvjf fritzing-$FRITZINGVER.linux.i386.tar.bz2 -C /opt/fritzing-$FRITZINGVER/
	rm -rf /usr/local/bin/fritzing
	ln -fs /opt/fritzing-$FRITZINGVER/fritzing-$FRITZINGVER.linux.i386/Fritzing /usr/local/bin/fritzing
	chown -R $USERDEV:$USERDEV /opt/fritzing-$FRITZINGVER/
	cp -f $HOMEDEV/XDAQ/Admin/xdaq-fritzing.desktop $GNOME_SHARE_APPS
	cp -f $HOMEDEV/XDAQ/Admin/xdaq-fritzing-logo.png $GNOME_SHARE_ICONS
else
	echo "[Fritzing] already installed."
fi
}


# Processing
function Setup_Processing()
{
if [ "$1" != "1" ];
then
	cd /tmp
	wget http://download.processing.org/processing-2.2.1-linux32.tgz
	rm -rf /opt/processing-2.2.1
       	tar -xvzf processing-2.2.1-linux32.tgz -C /opt
       	ln -sf /opt/processing-2.2.1/processing /usr/local/bin/processing
	cp -f $HOMEDEV/XDAQ/Admin/xdaq-processing.desktop $GNOME_SHARE_APPS
	cp -f $HOMEDEV/XDAQ/Admin/xdaq-processing-logo.png $GNOME_SHARE_ICONS
else
	echo "[Processing] already installed."
fi
}


# openFrameworks
function Setup_openFrameworks()
{
if [ "$1" != "1" ];
then
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
else
	echo "[openFrameworks] already installed."
fi
}


# pyFirmata
function Setup_pyFirmata()
{
if [ "$1" != "1" ];
then
	if [ ! -z "$PYTHON_SUPPORT" ];
	then
		echo "[SETUP] pyFirmata library require pre-installed Python."
		echo "Please select <Integrations> to check expected Python environment,"
		return
	fi

	python_home=/usr/local/lib/python2.7/dist-packages
	rm -rf $python_home/pyfirmata
	bash -c 'pip install pyfirmata'
	pyFirmata_home=`ls $python_home|grep -i pyfirmata|grep egg`
	if [ ! -z $pyFirmata_home ];
	then 
		ln -sf $python_home/$pyFirmata_home $python_home/pyfirmata
	fi
else
	echo "[pyFirmata] already installed."
fi
}


# SQLite
function Setup_SQLite()
{
if [ "$1" != "1" ];
then
	apt-get --yes --force-yes -f install
	apt-get --yes --force-yes --reinstall install sqlite3
else
	echo "[SQLite] already installed."
fi
}


# XTable
function Setup_XTable()
{
if [ "$1" != "1" ];
then
	if [ ! -z "$ARDUINO_SUPPORT" ];
	then
		echo "[SETUP] XTable library require pre-installed Arduino IDE"
		return
	fi
	
	cp -R $HOMEDEV/XDAQ/Projects/XTable-Arduino $HOMEDEV/Arduino/libraries
	chown -R $USERDEV:$USERDEV $HOMEDEV/Arduino/libraries/XTable-Arduino
	if [ ! -d $HOMEDEV/Arduino/libraries/XEEPROM ];
        then 
		ln -fs $HOMEDEV/Arduino/libraries/XTable-Arduino/src/XEEPROM $HOMEDEV/Arduino/libraries/XEEPROM
	fi

	if [[ -e /opt/of_libs_openFrameworks && -d $HOMEDEV/XDAQ/Projects/XTable-Arduino/BlinkingLEDs/BlinkingLEDs_of ]];
	then 
		echo "Build openFrameworks BlinkingLEDs_of example"
		cd $HOMEDEV/XDAQ/Projects/XTable-Arduino/BlinkingLEDs/BlinkingLEDs_of
		make clean
		make
		cp -f bin/BlinkingLEDs_of $HOMEDEV/XDAQ/Examples/XTable/BlinkingLEDs_of/
	fi
else
	echo "[XTable] already installed."
fi
}


# XEEPROM
function Setup_XEEPROM()
{
if [ "$1" != "1" ];
then
	if [ ! -z "$ARDUINO_SUPPORT" ];
	then
		echo "[SETUP] XEEPROM library require pre-installed Arduino IDE"
		return
	fi

	rm -rf /opt/arduino-$ARDUINOVER/libraries/XEEPROM
	if [ -d $HOMEDEV/Arduino ]; then rm -rf $HOMEDEV/Arduino/libraries/XEEPROM ; fi
	cp -R $HOMEDEV/XDAQ/Projects/XTable-Arduino/XEEPROM /opt/arduino-$ARDUINOVER/libraries
	chown -R $USERDEV:$USERDEV /opt/arduino-$ARDUINOVER/libraries/XEEPROM
else
	echo "[XEEPROM] already installed."
fi
}


# SciPy
function Setup_SciPyStack()
{
if [ "$1" != "1" ];
then
	if [ ! -z "$PYTHON_SUPPORT" ];
	then
		echo "[SETUP] SciPy library require pre-installed Python."
		echo "Please select <Integrations> to check expected Python environment,"
		return
	fi

	apt-get --yes --force-yes -f install
	apt-get --yes --force-yes --reinstall install python-numpy
	if [[ -d /usr/share/pyshared/numpy && ! -d /usr/lib/python2.7/dist-packages/numpy ]];	
	then
		# for Debian Wheezy/Jessie compatibility
		ln -sf /usr/share/pyshared/numpy /usr/lib/python2.7/dist-packages/numpy
	fi

	apt-get --yes --force-yes --reinstall install python-scipy

	apt-get --yes --force-yes --reinstall install python-matplotlib
	if [[ -d /usr/share/pyshared/matplotlib && ! -d /usr/lib/python2.7/dist-packages/matplotlib ]];
	then
		# for Debian Wheezy/Jessie compatibility
		ln -sf /usr/share/pyshared/matplotlib /usr/lib/python2.7/dist-packages/matplotlib
	fi

	apt-get --yes --force-yes --reinstall install ipython
	ConfigGnomeMenu ipython

	apt-get --yes --force-yes --reinstall install ipython-notebook

	apt-get --yes --force-yes --reinstall install python-pandas
	if [[ -d /usr/share/pyshared/pandas && ! -d /usr/lib/python2.7/dist-packages/pandas ]];
	then
		# for Debian Wheezy/Jessie compatibility
		ln -sf /usr/share/pyshared/pandas /usr/lib/python2.7/dist-packages/pandas
	fi

	apt-get --yes --force-yes --reinstall install python-sympy
	apt-get --yes --force-yes --reinstall install python-nose
else
	echo "[SciPy Stack v1.0] already installed."
fi
}


# GNU Octave
function Setup_GNUOctave()
{
if [ "$1" != "1" ];
then
	apt-get --yes --force-yes -f install
	apt-get --yes --force-yes --reinstall install octave
	ConfigGnomeMenu www.octave.org-octave
else
	echo "[GNU Octave] already installed."
fi
}


# Gnuplot
function Setup_Gnuplot()
{
if [ "$1" != "1" ];
then
	cd /tmp
	package_name=gnuplot-$GNUPLOTVER
	wget http://sourceforge.net/projects/gnuplot/files/gnuplot/$GNUPLOTVER/$package_name.tar.gz/download -O $package_name.tar.gz
	rm -rf /opt/gnuplot*
       	tar -xvzf $package_name.tar.gz -C /opt
	chown -R $USERDEV:$USERDEV /opt/$package_name
	cd /opt/$package_name
	./configure
	make
	make install
	cp -f $HOMEDEV/XDAQ/Admin/xdaq-gnuplot.desktop $GNOME_SHARE_APPS
else
	echo "[Gnuplot] already installed."
fi
}


# GSL
function Setup_GSL()
{
if [ "$1" != "1" ];
then
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
else
	echo "[GSL] already installed."
fi
}


# Scilab
function Setup_Scilab()
{
if [ "$1" != "1" ];
then
	cd /tmp
	package_name=scilab-$SCILABVER
	wget http://www.scilab.org/download/$SCILABVER/$package_name.bin.linux-i686.tar.gz -O $package_name.tar.gz
	rm -rf /opt/scilab*
     	tar -xvzf $package_name.tar.gz -C /opt
	cd /opt/$package_name
	ln -sf /opt/$package_name/bin/scilab /usr/local/bin/scilab

	cp -f $HOMEDEV/XDAQ/Admin/xdaq-scilab.desktop $GNOME_SHARE_APPS
	cp -f $HOMEDEV/XDAQ/Admin/xdaq-scilab-logo.png $GNOME_SHARE_ICONS
else
	echo "[Scilab] already installed."
fi
}


# Qt
function Setup_Qt()
{
if [ "$1" != "1" ];
then
	apt-get --yes --force-yes -f install
	apt-get --yes --force-yes --reinstall install qt4-dev-tools
	ConfigGnomeMenu assistant-qt4
	ConfigGnomeMenu designer-qt4
	ConfigGnomeMenu linguist-qt4
else
	echo "[Qt] already installed."
fi
}

# Texmaker
function Setup_Texmaker()
{
if [ "$1" != "1" ];
then
	apt-get --yes --force-yes -f install
	apt-get --yes --force-yes --reinstall install texmaker 
	ConfigGnomeMenu texmaker
else
	echo "[Texmaker] already installed."
fi
}


# gVim
function Setup_gVim()
{
if [ "$1" != "1" ];
then
	apt-get --yes --force-yes -f install
	apt-get --yes --force-yes --reinstall install vim-gnome
	ConfigGnomeMenu gvim
else
	echo "[gVim] already installed."
fi
}


# Xfig
function Setup_Xfig()
{
if [ "$1" != "1" ];
then
	apt-get --yes --force-yes -f install
	apt-get --yes --force-yes --reinstall install xfig
	cp -f $HOMEDEV/XDAQ/Admin/xdaq-xfig.desktop $GNOME_SHARE_APPS
else
	echo "[Xfig] already installed."
fi
}


# GNU Units
function Setup_GNUUnits()
{
if [ "$1" != "1" ];
then
	apt-get --yes --force-yes -f install
	apt-get --yes --force-yes --reinstall install units
else
	echo "[GNU UNits] already installed."
fi
}


# PuTTY
function Setup_PuTTY()
{
if [ "$1" != "1" ];
then
	apt-get --yes --force-yes -f install
	apt-get --yes --force-yes --reinstall install putty

	# Fix PuTTY configuration
	ConfigGnomeMenu putty
	echo -e "\nFix serial port for PuTTY users"
	rm -rf $HOMEDEV/.putty
	mkdir $HOMEDEV/.putty
	mkdir $HOMEDEV/.putty/sessions
		
 	# Update SerialLine parameter
	cat $HOMEDEV/XDAQ/Admin/xdaq-putty-conf | grep -v SerialLine > $HOMEDEV/.putty/sessions/xdaq-putty-conf
	echo "SerialLine=$COM" >> $HOMEDEV/.putty/sessions/xdaq-putty-conf
else
	echo "[PuTTY] already installed."
fi
}


# EAGLE PCB Design
function Setup_EAGLE()
{
if [ "$1" != "1" ];
then
	rm -rf /usr/local/bin/eagle
	cd /tmp
	wget http://web.cadsoft.de/ftp/eagle/program/7.3/eagle-lin32-$EAGLEPCBVER.run
	chmod +x eagle-lin32-$EAGLEPCBVER.run
	ln -sf /opt/eagle-$EAGLEPCBVER/bin/eagle /usr/local/bin/eagle
	cp -f $HOMEDEV/XDAQ/Admin/xdaq-eagle.desktop $GNOME_SHARE_APPS
	cp -f $HOMEDEV/XDAQ/Admin/xdaq-eagle-logo.png $GNOME_SHARE_ICONS
	./eagle-lin32-$EAGLEPCBVER.run /opt
	chown -R $USERDEV:$USERDEV /opt/eagle-$EAGLEPCBVER
fi
}


# CuteCom
function Setup_CuteCom()
{
if [ "$1" != "1" ];
then
	apt-get --yes --force-yes -f install
	apt-get --yes --force-yes --reinstall install cutecom
	rm -rf $GNOME_SHARE_APPS/cutecom.desktop
	cp -f $HOMEDEV/XDAQ/Admin/xdaq-cutecom.desktop $GNOME_SHARE_APPS

	# Fix CuteCom configuration
	echo -e "\nFix serial port for CuteCom users"
	if [ -d $HOMEDEV/.config/CuteCom ]; then rm -rf $HOMEDEV/.config/CuteCom ; fi
	mkdir $HOMEDEV/.config/CuteCom
		
 	# Update SerialLine parameter
	cat $HOMEDEV/XDAQ/Admin/xdaq-cutecom-conf | grep -v 'CurrentDevice\|AllDevices' > $HOMEDEV/.config/CuteCom/CuteCom.conf
	echo "CurrentDevice=$COM" >> $HOMEDEV/.config/CuteCom/CuteCom.conf
	echo "AllDevices=/dev/ttyS0, /dev/ttyS1, /dev/ttyS2, $COM" >> $HOMEDEV/.config/CuteCom/CuteCom.conf
else
	echo "[Serial Receiver (CuteCom)] already installed."
fi
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
# DEMO SECTION
#

# Demo Products
function Setup_Demo()
{
 	echo "Y"|Setup_LibeliumWaspmote $1
	echo "Y"|Setup_SunbeddedSodaq $1
}


# Libelium - Waspmote
function Setup_LibeliumWaspmote()
{
if [ "$1" != "1" ];
then

	echo "This option will install a Libelium product."
	echo "The Waspmote Pro IDE v$LIB_WASPMOTEVER (Wireless sensor networks open source platform)"
	echo "WARNING: Hardware is from manufacturer (only open source code)"
	echo

	cd /tmp
	package_name=waspmote-pro-ide-v$LIB_WASPMOTEVER-linux32
	wget http://downloads.libelium.com/$package_name.zip -O $package_name.zip
	rm -rf $package_name
       	unzip $package_name.zip
	rm -rf /opt/waspmote*
	mv $package_name /opt
	ln -sf /opt/$package_name/waspmote /usr/local/bin/waspmote
	chown -R $USERDEV:$USERDEV /opt/$package_name
	cp -f $HOMEDEV/XDAQ/Admin/xdaq-libelium-waspmote.desktop $GNOME_SHARE_APPS
	cp -f $HOMEDEV/XDAQ/Admin/xdaq-libelium-logo.png $GNOME_SHARE_ICONS

	echo "Install Plug & Sense!"
	cp $HOMEDEV/XDAQ/Admin/xdaq-libelium-plug-sense.desktop $GNOME_SHARE_APPS
else
	echo "[Libelium Products] already installed."
fi
}


# Sunbedded - SODAQ - Mbili 1284P
function Setup_SunbeddedSodaq()
{
if [ "$1" != "1" ];
then
	if [ ! -z "$ARDUINO_SUPPORT" ];
	then
		echo "[SETUP] Sunbeded/SODAQ library require pre-installed Arduino IDE"
		return
	fi

	echo "This option will install a Sunbedded product."
	echo "SODAQ - SODAQ Mbili (Arduino 1284P) v$SUNBED_SODAQVER (Board ideal for low (solar) power applications)"
	echo "WARNING: Hardware is from manufacturer (only open source code)"
	echo

	cd /tmp

	package_name=Sodaq_bundle
	wget http://mbili.sodaq.net/wp-content/uploads/2015/04/$package_name.zip -O $package_name.zip
	rm -rf $package_name
  unzip -d $package_name $package_name.zip
		
	# Clean Arduino environment from older SODAQ libraries
	rm -rf $HOMEDEV/Arduino/libraries/Sodaq*
	rm -rf $HOMEDEV/Arduino/libraries/RTCTimer
	rm -rf $HOMEDEV/Arduino/libraries/GPRSbee
	rm -rf $HOMEDEV/Arduino/hardware/sodaq-HardwareMbili
	rm -rf $HOMEDEV/Arduino/hardware/sodaq-HardwareMoja

	# Install SODAQ Board reference and libraries
	cp -R hardware/* $HOMEDEV/Arduino/hardware
	cp -R libraries/* $HOMEDEV/Arduino/libraries

	chown -R $USERDEV:$USERDEV $HOMEDEV/Arduino/libraries
	chown -R $USERDEV:$USERDEV $HOMEDEV/Arduino/hardware

	cp -f $HOMEDEV/XDAQ/Admin/xdaq-sunbedded-sodaq-mbili.desktop $GNOME_SHARE_APPS
	cp -f $HOMEDEV/XDAQ/Admin/xdaq-sunbedded-logo.png $GNOME_SHARE_ICONS
else
	echo "[Sunbeded - SODAQ] already installed."
fi
}



#
# MAIN SECTION
#



#
# GLOBAL FLAGS
#

OSVERSION=$1
USERDEV=$2
HOMEDEV=/home/$USERDEV

if [ "$USERDEV" == "" ];
then
	echo "Please specify User Account where is installed XDAQ environment."
	echo "Default Arduino user account: <arduinodev>"
	echo "More info at www.embeddedrevolution.info"
	exit
fi

if [ ! -d $HOMEDEV ];
then
	echo "Please check the Account name."
	echo "The Account <$HOMEDEV> does not exist."
	echo "More info at www.embeddedrevolution.info"
	exit
fi 

if [ ! -d $HOMEDEV/XDAQ ];
then
	echo "Please install XDAQ environment."
	echo "More info at www.embeddedrevolution.info"
	exit
fi




#
# GLOBAL CONST
#
XDAQVER=`cat $HOMEDEV/XDAQ/revisions.txt |head -1|awk -F' ' '{print $2}'`

XDAQ_LOG_FILE=/var/log/xdaq-setup.log
XDAQ_REPORT_FILE=/var/log/xdaq-packages.log

ARDUINOPACKAGE=arduino-nightly-linux32.tar.xz
GNOME_SHARE_APPS=/usr/share/applications
GNOME_SHARE_ICONS=/usr/share/icons/gnome/256x256
CHECK_KEYBOARD_COMMAND="cat /etc/default/keyboard | awk -F'=' '/XKBLAYOUT/ {print \$2}'"

ARDUINOUNITVER=2.1.1
FRITZINGVER=0.9.2b
OFVER=0.8.4
GNUPLOTVER=5.0.1
GSLVER=1.16
SCILABVER=5.5.2
LIB_WASPMOTEVER=04
LIB_PLUGSENSEVER=02
SUNBED_SODAQVER=Rev.4
PLOTLYVER=1.0
NODEJSVER=0.12.2
EAGLEPCBVER=7.3.0


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
	
	echo -e "\e[4mXDAQ Core - Debianinux                                                       \e[0m"
	echo -e "${XDAQ_MENU[20]} ${XDAQ_MENU[22]} ${XDAQ_MENU[24]}"
	echo -e "${XDAQ_MENU[26]} ${XDAQ_MENU[28]} ${XDAQ_MENU[30]}"

	echo -e "\e[4mXDAQ Core                                                                    \e[0m"
	echo -e "${XDAQ_MENU[40]} ${XDAQ_MENU[42]} ${XDAQ_MENU[44]}"
	echo -e "${XDAQ_MENU[46]} ${XDAQ_MENU[48]} ${XDAQ_MENU[50]}"
	echo -e "${XDAQ_MENU[52]} ${XDAQ_MENU[54]} ${XDAQ_MENU[56]}"
	echo -e "${XDAQ_MENU[58]} ${XDAQ_MENU[60]} ${XDAQ_MENU[62]}"

	echo -e "\e[4mXDAQ Core - Libraries                                                        \e[0m"
	echo -e "${XDAQ_MENU[100]} ${XDAQ_MENU[102]} ${XDAQ_MENU[104]}"
	echo -e "${XDAQ_MENU[106]}"

	echo -e "\e[4mXDAQ Optional                                                                \e[0m"
	echo -e "${XDAQ_MENU[140]} ${XDAQ_MENU[142]} ${XDAQ_MENU[144]}"
	echo -e "${XDAQ_MENU[146]} ${XDAQ_MENU[148]} ${XDAQ_MENU[200]} "

	echo -e "\e[4mXDAQ Management Tools                                                        \e[0m"
	echo -e "${XDAQ_MENU[220]} ${XDAQ_MENU[222]} ${XDAQ_MENU[224]}"
	echo -e "${XDAQ_MENU[226]} ${XDAQ_MENU[228]} ${XDAQ_MENU[240]}"
	echo -e "${XDAQ_MENU[242]} ${XDAQ_MENU[244]} ${XDAQ_MENU[246]}"
	echo -e "${XDAQ_MENU[248]} ${XDAQ_MENU[250]} ${XDAQ_MENU[0]}"

	echo ; sleep .5
	read -p "Which setup operation? " nSetup
	echo

  # Run required setup
	setup_function=""
	case $nSetup in
   -1)  VMReboot ;;
		0)	exit ;;
		
		10) setup_function="Setup_OSUpdate 'REBOOT'" ;;
		11) setup_function="Setup_GNOME" ;;
		12)	setup_function="Setup_Integrations" ;;
		13)	setup_function="Setup_GitTools" ;;
		14) setup_function="Setup_ArduinoIDE" ;;
		15)	setup_function="Setup_EclipseIDE" ;;

		20)	setup_function="Setup_Doxygen" ;;
		21) setup_function="Setup_Texmaker" ;;
		22)	setup_function="Setup_Fritzing" ;;
		23)	setup_function="Setup_Processing" ;;
		24) setup_function="Setup_openFrameworks" ;;
		25) setup_function="Setup_SQLite" ;;
		26) setup_function="Setup_SciPyStack" ;; 
		27)	setup_function="Setup_GNUOctave" ;;
		28) setup_function="Setup_Gnuplot" ;;
		29) setup_function="Setup_GSL" ;;
		30) setup_function="Setup_Scilab" ;;
		31)	setup_function="Setup_Qt" ;;

		50)	setup_function="Setup_ArduinoUnit" ;;
		51) setup_function="Setup_XTable" ;;
		52)	setup_function="Setup_pyFirmata" ;;
		53)	setup_function="Setup_Plotly" ;;

		70)	setup_function="Setup_gVim" ;;
		71)	setup_function="Setup_Xfig" ;;
		72)	setup_function="Setup_GNUUnits" ;;
		73)	setup_function="Setup_PuTTY" ;;
		74)	setup_function="Setup_EAGLE" ;;
		
	 100) setup_function="Setup_Demo" ;;
		
	 110) setup_function="XDAQInstaller" ;;
	 111) setup_function="DebianinuxInstaller" ;;
	 112)	setup_function="XDAQLibrariesInstaller" ;;
	 113)	setup_function="XDAQOptionalInstaller" ;;
	 114)	setup_function="Setup_VMwareTools" ;;
	 120) ShowConfig ;;
	 121) CheckConfig ;;
	 122)	SetSerialPort ;;
	 123)	SetTimeZone ;;
	 124)	SetKeyboard ;;
	 125) ShowPanel ;;

		 *)	echo "Error: Invalid option..."	;;
	esac


	if [[ "$setup_function" != "" ]];
	then
		setup_option=`echo ${XDAQ_MENU[$(($nSetup*2))]}`
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
