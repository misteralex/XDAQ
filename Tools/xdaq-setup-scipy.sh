#!/bin/bash

#########################################################################
# xdaq-setup-scipy.sh                                                   #
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
XDAQ_CATEGORY=CORE
XDAQ_PACKAGE=SciPy_Stack
XDAQ_SUPPORT=PYTHON


# XDAQ package manager functions (Setup/Status/Support)
function Setup()
{
  apt-get --yes --force-yes -f install
  apt-get --yes --force-yes --reinstall install python-numpy
  #if [[ -d /usr/share/pyshared/numpy && ! -d /usr/lib/python2.7/dist-packages/numpy ]]; 
  #then
  #  # for Debian Wheezy/Jessie compatibility
  #  ln -sf /usr/share/pyshared/numpy /usr/lib/python2.7/dist-packages/numpy
  #fi

  apt-get --yes --force-yes --reinstall install python-scipy

  apt-get --yes --force-yes --reinstall install python-matplotlib
  #if [[ -d /usr/share/pyshared/matplotlib && ! -d /usr/lib/python2.7/dist-packages/matplotlib ]];
  #then
  #  # for Debian Wheezy/Jessie compatibility
  #  ln -sf /usr/share/pyshared/matplotlib /usr/lib/python2.7/dist-packages/matplotlib
  #fi

  apt-get --yes --force-yes --reinstall install ipython
  ConfigGnomeMenu ipython

  apt-get --yes --force-yes --reinstall install ipython-notebook

  apt-get --yes --force-yes --reinstall install python-pandas
  #if [[ -d /usr/share/pyshared/pandas && ! -d /usr/lib/python2.7/dist-packages/pandas ]];
  #then
  #  # for Debian Wheezy/Jessie compatibility
  #  ln -sf /usr/share/pyshared/pandas /usr/lib/python2.7/dist-packages/pandas
  #fi

  apt-get --yes --force-yes --reinstall install python-sympy
  apt-get --yes --force-yes --reinstall install python-nose
}

function Status()
{
    GetPackageVersion "[SciPy] numpy"       "/usr/lib/python2.7/dist-packages/numpy"      "dpkg -l|grep python-numpy|awk -F' ' '{print \$3}'" "$XDAQ_SUPPORT"
    GetPackageVersion "[SciPy] scipy"       "/usr/lib/python2.7/dist-packages/scipy"      "dpkg -l|grep python-scipy|awk -F' ' '{print \$3}'|awk -F'+' '{print \$1}'" "$XDAQ_SUPPORT"
    GetPackageVersion "[SciPy] matplotlib"  "/usr/lib/python2.7/dist-packages/matplotlib" "dpkg -l |grep python-matplotlib| grep i386 | awk -F' ' '{print \$3}'" "$XDAQ_SUPPORT"
    GetPackageVersion "[SciPy] ipython"     "ipython"                                     "exec ipython --version 2>&1" "$XDAQ_SUPPORT"
    GetPackageVersion "[SciPy] notebook"    "/usr/share/ipython/notebook"                 "dpkg -l|grep ipython-notebook-common|awk -F' ' '{print \$3}'|awk -F'+' '{print \$1}'" "$XDAQ_SUPPORT"
    GetPackageVersion "[SciPy] pandas"      "/usr/lib/python2.7/dist-packages/pandas"     "dpkg -l|grep python-pandas|grep i386|awk -F' ' '{print \$3}'" "$XDAQ_SUPPORT"
    GetPackageVersion "[SciPy] sympy"       "/usr/lib/python2.7/dist-packages/sympy"      "dpkg -l|grep python-sympy|awk -F' ' '{print \$3}'" "$XDAQ_SUPPORT"
    GetPackageVersion "[SciPy] nose"        "/usr/lib/python2.7/dist-packages/nose"       "dpkg -l|grep python-nose|awk -F' ' '{print \$3}'" "$XDAQ_SUPPORT"
}

source ./xdaq-setup-main.sh
