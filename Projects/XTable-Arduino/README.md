# XTable-Arduino
XTable class is designed both for Arduino sketches and C++ projects but it aims to be used also for generic embedded C++ based boards. It supports short set of informations, typically for configuration purpose, with CRUD API approach (Create, Read, Update and Delete).

It implements a short table (database) oriented to generic structured items through an efficient storage using an circular buffer EEPROM and volatile SRAM for dynamic memory allocation. Circular buffer (O-Buffer) prevent wear out of the EEPROM. Since it is only guaranteed to endure 100k erase/write/cycles the O-Buffer increase until to twice the number of times that a configuration (collection of parameters) can be stored.

This embedded library is designed considering an Atmel Application Note (AVR101: High Endurance EEPROM Storage) to improve EEPROM management and currently is available on Arduino context to support the XDAQ virtual appliance for research purposes.

Please refer to the XDAQ Guide to know more details about it. The guide is available at www.embeddedrevolution.info Home Page.


## XTable Resources

1. XTable Arduino Library and examples (available at XTable-Arduino/src)
2. XEEPROM Arduino Library and examples (available at XTable-Arduino/src/XEEPROM)
3. TestXTable Project to test all expected functionality through ArduinoUnit test library (available at XTable-Arduino/TestXTable)
4. BlinkingLEDs Project a complete demo application using Firmata protocol (available at XTable-Arduino/BlinkingLEDs)
   This application is available both from console and GUI mode. The demo is available through standard serial port access (e.g. cutecom, putty) and through an openFrameworks demo application.


### From source
- Download the latest release
- Or clone it from Github using the command `git clone git@github.com:misteralex/XTable-Arduino
- Check the XDAQ Guide and this readme about usage options.

## Requirements
You need to have a Debian based environment (Wheezy, Jessie), Ubuntu or a virtual Debian based appliance like Debianinux

## Usage
The XDAQ Guide is a comprehensive document to use XDAQ project as you like. It is strongly adviced to use XDAQ Tools.

Refer to www.embeddedrevolution.info for more information.


## License
XDAQ, Debianinux as well as XTable/XEEPROM Arduino libraries and the related documentation are free software; you can redistribute them and/or modify them under the terms of the GNU General Public License as published by the Free Software Foundation.

## Contribution
Copyright AF 2015
