/********************************************************************************
 *   BlinkingLEDs - Application for XTable Class                                *
 *   Copyright (C) 2015 by AF                                                   *
 *                                                                              *
 *   This file is part of XDAQ v1.0 Project                                     *
 *   (see more on www.embeddedrevolution.info).                                 *
 *                                                                              *
 *   BlinkingLEDs is free software: you can redistribute it and/or modify it    *
 *   under the terms of the GNU General Public License as published             *
 *   by the Free Software Foundation, either version 3 of the License, or       *
 *   (at your option) any later version.                                        *
 *                                                                              *
 *   BlinkingLEDs is distributed in the hope that it will be useful,            *
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of             *
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the              *
 *   GNU General Public License for more details.                               *
 *                                                                              *
 *   You should have received a copy of the GNU General Public                  *
 *   License along with BlinkingLEDs. If not, see <http://www.gnu.org/licenses/>. *
 ********************************************************************************/

/**
 *  @file    BlinkingLEDs.cpp (or BlinkingLEDs.ino)
 *  @author  AF
 *  @date    25/1/2015
 *  @version 1.0
 *
 *	@brief Application for XTable CRUD table embedded class
 *
 *  @section DESCRIPTION
 *
 *  This test application implements XTable functionality as useful complement of
 *  XTable class design (XDAQ environment based).
 *
 *  This Arduino test application could be integrated with BlinkingLEDs_of openFrameworks
 *  test application. See more in the XDAQ Guide.
 *
 *  XTable embedded class, support short set of informations, typically for
 *  configuration purpose, with CRUD API approach (Create, Read, Update and Delete).
 *  It manages generic structured items through an efficient storage using a
 *  circular buffer in EEPROM and volatile SRAM.
 */


#include <Firmata.h>
#include "XTable.h"

#define PRINT(m) Serial.print(m);
#define DEBUG(value) Serial.print(#value); Serial.print("="); Serial.println(value)

byte previousPORT[TOTAL_PORTS];

/// parameter to manage remote serial terminal mode
unsigned long current_time;
unsigned long cmd_time;
bool firmata_mode;

/// global variables
int switch_button;
bool switch_event;
int nChoice;
unsigned int id;
int nMenu;
bool refreshLEDs;

/// EEPROM parameters and flags to switch between <a> and <b> configuration
int size_buffer = 18;
int start_address_a = 3;
int start_address;
int addr_conf;
int addr_conf_a;
int addr_conf_b;


/// Example of structure related to Blinking Project
/// Collection of blinking LEDs
struct T_LED
{
	unsigned char pin;
	bool blinking;
	unsigned long delay_ms;
} LED;

XTable<T_LED> blinking_LEDs;


void digitalWriteCallback(byte port, int value)
{
  byte i;
  byte currentPinValue, previousPinValue;

  if (port < TOTAL_PORTS && value != previousPORT[port]) {
  for (i = 0; i < 8; i++) {
        currentPinValue = (byte) value & (1 << i);
        previousPinValue = previousPORT[port] & (1 << i);
        if  (currentPinValue != previousPinValue)
            digitalWrite(i + (port * 8), currentPinValue);
    }
    previousPORT[port] = value;
  }
}

void stringCallback(char *myString)
{
  /// Receive from Firmata communication the character 's' (means <S>witch)
  /// Switch configuration as required from remote host
  switch_event = (*myString==115);
}


/// XTable implementation
bool CheckArduinoUnoPinId(int pin)
{
	return ((blinking_LEDs.Select()->pin >1) && (blinking_LEDs.Select()->pin < 15));
}

bool CreateDefaultConf()
{
	unsigned int id;

	blinking_LEDs.Clean();

	for(id=2; id<5+2; id++)
	{
		LED.pin = id;
		if (start_address == start_address_a)
		{ 
			LED.blinking = false;
			LED.delay_ms = 500;
		}
		else
		{ 
			LED.blinking = true;
			LED.delay_ms = 100;
		}

		blinking_LEDs.Insert(LED);
	}

	/// Add virtual LED
	LED.pin = 14;
	LED.blinking = true;
	LED.delay_ms = 700;
	blinking_LEDs.Insert(LED);

	for(id=5+1; id>1; id--)
	{
		LED.pin = id;
		LED.blinking = true;
		LED.delay_ms = 100;
		blinking_LEDs.Insert(LED);
	}

	/// Add virtual LED
	LED.pin = 14;
	LED.blinking = true;
	LED.delay_ms = 700;
	blinking_LEDs.Insert(LED);

	return (blinking_LEDs.Counter()>0);
}

void SetOutputConf()
{
	blinking_LEDs.Top();
	do
	{
		if (CheckArduinoUnoPinId(blinking_LEDs.Select()->pin))
			pinMode(blinking_LEDs.Select()->pin, OUTPUT);
	} while (blinking_LEDs.Next());

    	/// Local button to switch between configurations
	pinMode(7, INPUT);

    	/// Remote control equivalent to push local button
    	pinMode(8, OUTPUT);
}

bool GetConfiguration()
{
	if (blinking_LEDs.InitStorage(start_address, size_buffer))
	{

		if (!firmata_mode) PRINT("Configuration loaded successfully\r\n\n");

		if (blinking_LEDs.LoadStorage())
		{
			if (!blinking_LEDs.Counter())
			{
				if (!firmata_mode) PRINT("Initialize default configuration\r\n");
				if (!CreateDefaultConf())
				{
					PRINT("General SRAM memory error\r\n");
					delay(100);
					return false;
				}
				blinking_LEDs.SaveStorage();
			}
			return true;
		}
	}

	PRINT("General EEPROM error !!!\r\n");
	delay(100);
	return false;
}

void ShowConfiguration()
{
	unsigned int id;

	PRINT("\r\nConfiguation format: LED(pin, blinking status, delay msec)\r\n");
	PRINT("(Here <Pin 14> is virtual for delay scope)\r\n");
	PRINT("\r\nCurrent configuration: <");
	if (start_address == start_address_a) PRINT("a>\r\n")
    	else PRINT("b>\r\n");

	blinking_LEDs.Top();
	do
	{
		id = blinking_LEDs.GetId();
		LED = *blinking_LEDs.Select();
		PRINT("("); PRINT(id);
		PRINT(") - Update LED (");
		PRINT(LED.pin); PRINT(", ");
		PRINT(LED.blinking ? "true" : "false"); PRINT(", ");
		PRINT(LED.delay_ms); PRINT(")\r\n");
	} while (blinking_LEDs.Next());

    	PRINT("\r\n");
}


void setup()
{
	/// Start serial console mode
	Serial.begin(115200);
	delay(100);

	PRINT("\r\n\n\n*** Start BlinkingLEDs sketch ***\r\nFirmata protocol will starts within 5 sec.\r\n\n");

	if (!blinking_LEDs.InitBuffer(30))
	{
		PRINT("Error: cannot allocate required memory\r\n");
		delay(100);
		exit(0);
	}

	/// Check current configuration and create default setting
	start_address = -1;
	if (blinking_LEDs.eeprom.read(0)==blinking_LEDs.BMK)
	{
		start_address = (blinking_LEDs.eeprom.read(1) << 8) + blinking_LEDs.eeprom.read(2);
	    if (start_address > blinking_LEDs.eeprom.Limit()) start_address = -1;
	}

	if (start_address < 0)
	{
		blinking_LEDs.eeprom.write(0,blinking_LEDs.BMK);
		blinking_LEDs.eeprom.write(1,0);
		blinking_LEDs.eeprom.write(2,start_address_a);
		start_address = start_address_a;
	}

	if (!GetConfiguration())
	{
		PRINT("Error: cannot get required memory\r\n");
		delay(100);
		exit(0);
	}

	/// Set pin included on LED configuration
	SetOutputConf();

	/// Start running current default configuration <a>
	refreshLEDs = false;

	/// Global flags
	nMenu 	= 0;
	switch_event = false;
	switch_button 	= LOW;
	nChoice	= 101;				/// Stand for 'e' Exit from Console Mode

	/// Firmata initialization and global parameters

	Firmata.setFirmwareVersion(2,3);
	Firmata.attach(STRING_DATA, stringCallback);
	Firmata.attach(DIGITAL_MESSAGE, digitalWriteCallback);
	firmata_mode = false;
	cmd_time = 5000;
	current_time = millis();

	PRINT("Press <m> to show all available options\r\n\n");
}

void loop()
{
    if (!firmata_mode)
    {
    	/// Wait commmands from terminal or skip Console Mode after 5 sec.
		while ((Serial.available()==0) && (millis()-current_time<cmd_time));

		if (millis()-current_time<cmd_time)
		{
			if (nChoice==101) PRINT("*** Start Console Mode ***\r\n\n");
			nChoice = Serial.read();
			PRINT(">");
			PRINT((char)nChoice);
			PRINT("\r\n");
			Serial.flush();
		}

        	/// "m" Menu
		if (nChoice==109)
		{
			PRINT("\r\nMain Menu\r\n");
            		PRINT("(m) - Show this menu\r\n");
			PRINT("(d) - Set default configuration\r\n");
			PRINT("(s) - Save current configuration\r\n");
			PRINT("(a) - Load configuration <a>\r\n");
			PRINT("(b) - Load configuration <b>\r\n");
			PRINT("(c) - Change current configuration\r\n");
			PRINT("(w) - Show current configuration\r\n");
			PRINT("(r) - Run current configuration\r\n");
            		PRINT("(e) - Exit\r\n\n");
			PRINT("*** Which option?\r\n");
			nChoice = -1;
		}

        	/// "d" Default configuration
		if (nChoice==100)
		{
			PRINT("Set default configuration\r\n");
			CreateDefaultConf();
			nChoice = -1;
		}

		/// "r" Run configuration
		if (nChoice==114)
		{
			PRINT("Run current configuration\r\n");
			refreshLEDs = true;
			nChoice = -1;
		}

		/// "s" Save configuration
		if (nChoice==115)
		{
			blinking_LEDs.SaveStorage();
			PRINT("Configuration saved successfully.\r\n\n");
			nChoice = -1;
		}

		/// "c" Change configuration
		if (nChoice==99)
		{
			ShowConfiguration();
			PRINT("\r\nWhich configuration to change? ");
			nChoice=-1; while (nChoice == -1)
			if (Serial.available() > 0) nChoice = Serial.parseInt();

			/// Check request within existing configurations
			blinking_LEDs.Top();
			do
			{
				if (blinking_LEDs.GetId()==nChoice) { nMenu = 1; break; }
			} while (blinking_LEDs.Next());

			if (nMenu==1)
			{
				id = blinking_LEDs.GetId();
				LED = *blinking_LEDs.Select();
				PRINT("Update LED (");
				PRINT(blinking_LEDs.Select()->pin); PRINT(", ");
				PRINT(blinking_LEDs.Select()->blinking ? "true" : "false"); PRINT(", ");
				PRINT(blinking_LEDs.Select()->delay_ms); PRINT(")\r\n");

				PRINT("Pin (2-13, 14 for virtual LED)? ");
				nChoice=-1; while (nChoice == -1)
				if (Serial.available() > 0) nChoice = Serial.parseInt();
				if ((nChoice>1) && (nChoice<15)) LED.pin = nChoice;
				else PRINT("(Invalid Pin) ");
				PRINT(LED.pin);

				PRINT("\r\nBlinking (0/1)? ");
				nChoice=-1; while (nChoice == -1)
				if (Serial.available() > 0) nChoice = Serial.parseInt();
				LED.blinking = (nChoice > 0 ? 1 : 0);
				PRINT(LED.blinking);

				PRINT("\r\nWhich delay (sec)? ");
				nChoice=-1; while (nChoice == -1)
				if (Serial.available() > 0) nChoice = Serial.parseInt();
				LED.delay_ms = nChoice;
				PRINT(LED.delay_ms)

				blinking_LEDs.Update(LED);
				PRINT("\r\nConfiguration updated successfully.\r\n\n");
				nMenu = 0;
			}

			nChoice = -1;
		}

		/// "w" Show configuration
		if (nChoice==119)
		{
			ShowConfiguration();
			nChoice = -1;
		}

		/// "e" Exit from console mode
		if (nChoice==101)
		{
		  PRINT("*** Leave Console Mode. Start Firmata Mode. ***\r\n\n\n");
		  Serial.end();
		  Firmata.begin(115200);
		  firmata_mode = true;
		  refreshLEDs = true;
		  nChoice = -1;
		}
		else current_time = millis();
    }


	/// Play current configuration
	blinking_LEDs.Top();
	do
	{
		if  (digitalRead(7) > switch_button)
		{
			switch_button = HIGH;
			switch_event = true;
		}

        if (switch_event)
        	if (start_address == start_address_a) nChoice=98;
        	else nChoice=97;

        /// "a" || "b"
        if ((nChoice==97) || (nChoice==98))
        {
        	switch_button = LOW;
        	switch_event = false;

        	if (!firmata_mode) PRINT("Load configuration ");

        	if (nChoice==97)
        	{
        		if (!firmata_mode) PRINT("<a>\r\n");
				start_address = start_address_a;
				blinking_LEDs.eeprom.write(0,0);
				blinking_LEDs.eeprom.write(1,start_address_a);
        	}
        	else
        	{
        		if (!firmata_mode) PRINT("<b>\r\n");
        		start_address = blinking_LEDs.NextFreeAddressStorage();
				blinking_LEDs.eeprom.write(1, start_address >> 8);
				blinking_LEDs.eeprom.write(2, start_address & 0x00FF);
        	}

        	if (!GetConfiguration()) exit(0);
        	nChoice = -1;
        }

        if (refreshLEDs)
        if (CheckArduinoUnoPinId(blinking_LEDs.Select()->pin))
        {
			 /// Start blinking: turn on current LED
			 digitalWrite(blinking_LEDs.Select()->pin, HIGH);

			 /// Update current LED status within Firmata
			 if (firmata_mode) Firmata.sendDigitalPort(0, readPort(0, 0xff));

			 /// Delay specified time (millisec unit)
			 delay(blinking_LEDs.Select()->delay_ms);

			 /// Check blinking requirement: turn off current LED
			 if (blinking_LEDs.Select()->blinking)
			 {
				digitalWrite(blinking_LEDs.Select()->pin, LOW);

				/// Update current LED status within Firmata
			    if (firmata_mode) Firmata.sendDigitalPort(0, readPort(0, 0xff));
			 }
		}
		else refreshLEDs = false;

		/// Push current changes remotely
        if  (firmata_mode) while (Firmata.available()) Firmata.processInput();

    } while (blinking_LEDs.Next() && (refreshLEDs));

	if (refreshLEDs) nChoice=109;
	refreshLEDs = firmata_mode;
}
