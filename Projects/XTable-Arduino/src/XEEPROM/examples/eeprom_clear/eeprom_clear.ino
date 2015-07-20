/**
 *  @file    eeprom_clear.ino
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
 *  Sets all of the bytes of the EEPROM to 0.
 * 
 *  It show how fix standard EEPROM Arduino approach to use 
 *  generalized XEEPROM.
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

void setup()
{
  // write a 0 to all 512 bytes of the EEPROM
  for (int i = 0; i < 512; i++)
    EEPROM.write(i, 0);

  // turn the LED on when we're done
  digitalWrite(13, HIGH);
}

void loop()
{
}
