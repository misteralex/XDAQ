#!/bin/bash

#########################################################################
# xdaq-setup-vmware.sh                                                  #
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
XDAQ_CATEGORY=DEBIAN
XDAQ_PACKAGE=VMWARE
XDAQ_SUPPORT=DESKTOP


# XDAQ package manager functions (Setup/Status)
function Setup()
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

function Status()
{
    GetPackageVersion "VMWare Tools" "vmware-toolbox-cmd" "vmware-toolbox-cmd -v" "$XDAQ_SUPPORT"
}

source ./xdaq-setup-main.sh
