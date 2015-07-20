/**
 *  @file    eeprom_read.ino
 *  @author  AF
 *  @date    24/3/2015
 *  @version 1.0
 *
 *  @brief This is a short update of default EEPROM example provided 
 * 	   with standard Arduino project
 *
 *  @section DESCRIPTION
 *
 *  This application is meant as example. 
 *
 *  Reads the value of each byte of the EEPROM and prints it
 *  to the computer.
 * 
 *  It show how fix standard EEPROM Arduino approach to use 
 *  generalized XEEPROM class.
 *  
 *  In place of standard declaration:
 *  #include <EEPROM.h>
 * 
 *  Use:
 *  #include <XEEPROM.h>
 *  extern XEEPROM<byte> EEPROM;
 *
 * 
 *  This example is part of XDAQ v1.0 Project.
 *  This code is in the public domain.
 * 
 *  See more at www.embeddedrevolution.info
 *
 */

#include <XEEPROM.h>		/// In place of <EEPROM.h>
extern XEEPROM<byte> EEPROM;


// start reading from the first byte (address 0) of the EEPROM
int address = 0;
byte value;

void setup()
{
  // initialize serial and wait for port to open:
  Serial.begin(115200);
  while (!Serial) {
    ; // wait for serial port to connect. Needed for Leonardo only
  }
}

void loop()
{
  // read a byte from the current address of the EEPROM
  value = EEPROM.read(address);

  Serial.print(address);
  Serial.print("\t");
  Serial.print(value, DEC);
  Serial.println();

  // advance to the next address of the EEPROM
  address = address + 1;

  // there are only 512 bytes of EEPROM, from 0 to 511, so if we're
  // on address 512, wrap around to address 0
  if (address == 512)
    address = 0;

  delay(500);
}
