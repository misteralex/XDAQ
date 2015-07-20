/**
 *  @file    eeprom_write.ino
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
 *  Stores values read from analog input 0 into the EEPROM.
 *  These values will stay in the EEPROM when the board is
 *  turned off and may be retrieved later by another sketch.
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

// the current address in the EEPROM (i.e. which byte
// we're going to write to next)
int addr = 0;

void setup()
{
}

void loop()
{
  // need to divide by 4 because analog inputs range from
  // 0 to 1023 and each byte of the EEPROM can only hold a
  // value from 0 to 255.
  int val = analogRead(0) / 4;

  // write the value to the appropriate byte of the EEPROM.
  // these values will remain there when the board is
  // turned off.
  EEPROM.write(addr, val);

  // advance to the next address.  there are 512 bytes in
  // the EEPROM, so go back to 0 when we hit 512.
  addr = addr + 1;
  if (addr == 512)
    addr = 0;

  delay(100);
}
