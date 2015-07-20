/**
 *  @file    xeeprom_read
 *  @author  AF
 *  @date    24/3/2015
 *  @version 1.0
 *
 *  @brief This is a short update of default EEPROM example provided 
 * 	   with standard Arduino project
 *
 *  @section DESCRIPTION
 *
 *  This application is meant as example. It useful as test tool
 *  to monitor EEPROM status. It reads each byte available between
 *  specified range (see <start_address> and <end_address>) and show
 *  EEPROM contents on the screen. 
 * 
 *  This example is part of XDAQ v1.0 Project.
 *  This code is in the public domain as well as XDAQ.
 * 
 *  See more at www.embeddedrevolution.info
 *
 */

#include <XEEPROM.h>
extern XEEPROM<byte> EEPROM;

/// start reading from the first specified address (start_address) of the EEPROM
int start_address;
int end_address;
int address;
byte value;

void setup()
{
  /// Setup address range to monitor
  start_address = 0;
  end_address = 500;
  address = start_address;

  /// initialize serial and wait for port to open:
  Serial.begin(115200);
  while (!Serial) {
    ; /// wait for serial port to connect. Needed for Leonardo only
  }
}

void loop()
{
  /// wrap around specified range between <start_address> and <end_address>
  if ((address==start_address) || (address==end_address))
  {
	  address = start_address;
	  Serial.print("\n\nEEPROM contents in the address range: ");
	  Serial.print(start_address);
	  Serial.print(" - ");
	  Serial.println(end_address);
  }

  /// read a byte from the current address of the EEPROM
  value = EEPROM.read(address);

  if (!(address % 20))
  {
	  Serial.println();
	  Serial.print("[");
          if (address<10) Serial.print("00");
          else if (address<100) Serial.print("0");
	  Serial.print(address);
	  Serial.print("]: ");
  }

  if (value<10) Serial.print("00"); 
  else if (value<100) Serial.print("0");
  Serial.print(value, DEC);
  Serial.print(" ");

  /// advance to the next address of the EEPROM
  address = address + 1;

  delay(300);
}
