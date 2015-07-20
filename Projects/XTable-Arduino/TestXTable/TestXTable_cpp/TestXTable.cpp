/********************************************************************************
 *   TestXTable - Unit Test for XTable Class                                    *
 *   Copyright (C) 2015 by AF                                                   *
 *                                                                              *
 *   This file is part of XDAQ Virtual Appliance                                *
 *   (see more on www.embeddedrevolution.info).                                 *
 *                                                                              *
 *   TestXTable is free software: you can redistribute it and/or modify it      *
 *   under the terms of the GNU General Public License as published             *
 *   by the Free Software Foundation, either version 3 of the License, or       *
 *   (at your option) any later version.                                        *
 *                                                                              *
 *   TestXTable is distributed in the hope that it will be useful,              *
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of             *
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the              *
 *   GNU General Public License for more details.                               *
 *                                                                              *
 *   You should have received a copy of the GNU General Public                  *
 *   License along with TestXTable. If not, see <http:///www.gnu.org/licenses/> *
 ********************************************************************************/

/**
 *  @file    TestXTable.cpp (or TestXTable.ino)
 *  @author  AF
 *  @date    25/1/2015
 *  @version 1.0
 *
 *	@brief Unit Test application for XTable CRUD table embedded class
 *
 *  @section DESCRIPTION
 *
 *  This unit test provide full check of XTable class requirements.
 *  XTable embedded class, support short set of informations, typically for
 *  configuration purpose, with CRUD API approach (Create, Read, Update and Delete).
 *  It manages generic structured items through an efficient storage using a
 *  circular buffer in EEPROM and volatile SRAM.
 */

#include "XTable.h"
#include "ArduinoUnit.h"

#define PRINT(m) Serial.print(m);
#define DEBUG(value) Serial.print(#value); Serial.print("="); Serial.println(value)


#define CHECK_STORAGE_OPERATIONS 0

/// XTable item structure definition (this data tyepe is part of BlinkingLEDs Project)
struct T_LED
{
	unsigned char pin;
	bool blinking;
	unsigned long delay_ms;
} LED;

XTable<T_LED> blinking_LEDs;



#if CHECK_STORAGE_OPERATIONS==0

void InsertSample()
{
	unsigned char id;

	blinking_LEDs.Clean();

	for(id=0; id<10; id++)
	{
		LED.pin = id;
		assertTrue(blinking_LEDs.Insert(LED));
	}
}


test(Clean)
{
	blinking_LEDs.Clean();

	for (int i=0; i<10; i++)
		assertTrue(blinking_LEDs.Insert(LED));

	assertEqual(blinking_LEDs.Counter(),10);

	blinking_LEDs.Clean();

	assertEqual(blinking_LEDs.Counter(),0);
}

test(Insert)
{
	blinking_LEDs.Clean();

	assertTrue(blinking_LEDs.Insert(LED));
	assertEqual(blinking_LEDs.Counter(),1);
}

test(InsertCheckId)
{
	blinking_LEDs.Clean();

	assertTrue(blinking_LEDs.Insert(LED));
	blinking_LEDs.Top();
	assertEqual(blinking_LEDs.GetId(),0);
}

test(InsertId)
{
	blinking_LEDs.Clean();

	assertTrue(blinking_LEDs.Insert(LED));
	assertEqual(blinking_LEDs.GetId(),0);

	assertTrue(blinking_LEDs.Insert(LED,88));
	assertEqual(blinking_LEDs.GetId(),88);
}

test(InsertIdTenEntries)
{
	unsigned char id;

	blinking_LEDs.Clean();

	for(id=0; id<10; id++)
		assertTrue(blinking_LEDs.Insert(LED,id*10));

	blinking_LEDs.Top();

	for(id=0; id<10; id++)
	{
		assertEqual(blinking_LEDs.GetId(),id*10);
		blinking_LEDs.Next();
	}
}

test(Select)
{
	blinking_LEDs.Clean();

	LED.pin = 88;
	assertTrue(blinking_LEDs.Insert(LED));

	LED.pin = 0;
	LED = *blinking_LEDs.Select();
	assertEqual(LED.pin, 88);
}

test(SelectIdTenEntries)
{
	unsigned char id;

        blinking_LEDs.Clean();
        assertTrue(blinking_LEDs.Select(1)==NULL);

	InsertSample();
	for(id=9; id>0; id--)
	{
		LED = *blinking_LEDs.Select(id);
		assertEqual(LED.pin, id);
	}
}

test(Update)
{
	LED.pin = 1;

	blinking_LEDs.Clean();

	assertTrue(blinking_LEDs.Insert(LED));

	LED = *blinking_LEDs.Select();
	assertEqual(LED.pin, 1);

	LED.pin = 88;
	assertTrue(blinking_LEDs.Update(LED));

	LED.pin = 0;
	LED = *blinking_LEDs.Select();
	assertEqual(LED.pin, 88);
}

test(UpdateSpecificId)
{
	unsigned char id;

	InsertSample();

	for(id=9; id>0; id--)
	{
		LED = *blinking_LEDs.Select(id);
		assertEqual(LED.pin, id);
	}

	LED.pin = 88;
	blinking_LEDs.Select(5);
	assertTrue(blinking_LEDs.Update(LED));

	for(id=9; id>0; id--)
	{
		LED = *blinking_LEDs.Select(id);
		if (id==5)
		{
			assertEqual(LED.pin, 88);
		}
		else assertEqual(LED.pin, id);
	}
}

test(Delete)
{
	blinking_LEDs.Clean();
	assertTrue(blinking_LEDs.Select()==NULL);

	assertTrue(blinking_LEDs.Insert(LED));
	assertFalse(blinking_LEDs.Select()==NULL);

	assertTrue(blinking_LEDs.Delete());
	assertTrue(blinking_LEDs.Select()==NULL);
}

test(GetId)
{
	blinking_LEDs.Clean();

	assertTrue(blinking_LEDs.Insert(LED));
	assertTrue(blinking_LEDs.Insert(LED));
	assertTrue(blinking_LEDs.Insert(LED,88));
	assertTrue(blinking_LEDs.Insert(LED,8));
	assertTrue(blinking_LEDs.Insert(LED));

	blinking_LEDs.Insert(LED);
	blinking_LEDs.Insert(LED);
	blinking_LEDs.Insert(LED,88);
	blinking_LEDs.Insert(LED,8);
	blinking_LEDs.Insert(LED);

	blinking_LEDs.Top();
	assertEqual(blinking_LEDs.GetId(),0);

	blinking_LEDs.Next();
	assertEqual(blinking_LEDs.GetId(),1);

	blinking_LEDs.Next();
	assertEqual(blinking_LEDs.GetId(),8);

	blinking_LEDs.Next();
	assertEqual(blinking_LEDs.GetId(),88);

	blinking_LEDs.Next();
	assertEqual(blinking_LEDs.GetId(),89);
}

test(Status)
{
	blinking_LEDs.Clean();
	assertTrue(blinking_LEDs.Insert(LED));
	assertEqual(blinking_LEDs.Counter(),1);

	assertTrue(blinking_LEDs.Status(false));
	blinking_LEDs.BrowseAll(false);
	assertEqual(blinking_LEDs.Counter(),0);

	assertTrue(blinking_LEDs.Insert(LED));
	assertEqual(blinking_LEDs.Counter(),1);

	blinking_LEDs.BrowseAll(true);
	assertEqual(blinking_LEDs.Counter(),2);
}

test(StatusTenEntries)
{
	unsigned char id;

	InsertSample();

	blinking_LEDs.Top();
	for(id=0; id<10; id++)
	{
		LED = *blinking_LEDs.Select();
		assertEqual(LED.pin,id);
		blinking_LEDs.Next();
	}

	assertTrue(blinking_LEDs.Select(2)!=NULL);
	assertTrue(blinking_LEDs.Status(false));

	assertTrue(blinking_LEDs.Select(8)!=NULL);
	assertTrue(blinking_LEDs.Status(false));

	assertEqual(blinking_LEDs.Counter(),10);
	blinking_LEDs.BrowseAll(false);
	assertEqual(blinking_LEDs.Counter(),8);

	blinking_LEDs.Top();
	LED = *blinking_LEDs.Select();
	assertEqual(LED.pin,0);

	blinking_LEDs.Next();
	LED = *blinking_LEDs.Select();
	assertEqual(LED.pin,1);

	blinking_LEDs.Next();
	LED = *blinking_LEDs.Select();
	assertEqual(LED.pin,3);
}

test(BrowseAll)
{
	unsigned char id;

	blinking_LEDs.Clean();

	assertTrue(blinking_LEDs.Insert(LED,8));

	assertTrue(blinking_LEDs.Insert(LED,18));
	assertTrue(blinking_LEDs.Status(false));

	assertTrue(blinking_LEDs.Insert(LED,28));

	blinking_LEDs.BrowseAll(true);
	blinking_LEDs.Top();
	assertEqual(blinking_LEDs.GetId(),8);

	blinking_LEDs.Next();
	assertEqual(blinking_LEDs.GetId(),18);

	blinking_LEDs.Next();
	assertEqual(blinking_LEDs.GetId(),28);

	blinking_LEDs.BrowseAll(false);
	blinking_LEDs.Top();
	assertEqual(blinking_LEDs.GetId(),8);

	blinking_LEDs.Next();
	assertEqual(blinking_LEDs.GetId(),28);
}

test(Counter)
{
	unsigned char id;

	blinking_LEDs.Clean();
	assertEqual(blinking_LEDs.Counter(),0);

	InsertSample();

	assertEqual(blinking_LEDs.Counter(),10);
}

test(Top)
{
	unsigned char id;

	blinking_LEDs.Clean();

	assertFalse(blinking_LEDs.Top());

	for(id=0; id<10; id++)
		assertTrue(blinking_LEDs.Insert(LED));

	blinking_LEDs.Select(0);
	blinking_LEDs.Status(false);

	assertTrue(blinking_LEDs.Top());
	assertEqual(blinking_LEDs.GetId(), 0);

	blinking_LEDs.BrowseAll(false);
	assertTrue(blinking_LEDs.Top());
	assertEqual(blinking_LEDs.GetId(), 1);

	blinking_LEDs.Select(1);
	blinking_LEDs.Status(false);
	assertTrue(blinking_LEDs.Top());
	assertEqual(blinking_LEDs.GetId(), 2);

	assertTrue(blinking_LEDs.Top());
	for(id=0; id<10; id++)
	{
		blinking_LEDs.Status(false);
		blinking_LEDs.Next();
	}

	assertFalse(blinking_LEDs.Top());
}

test(Next)
{
	unsigned char id;

	InsertSample();

	assertTrue(blinking_LEDs.Top());
	id=0;
	do
	{
		assertEqual(blinking_LEDs.GetId(),id++);
	} while (blinking_LEDs.Next());

}

#else

test(InitStorage)
{
	blinking_LEDs.eeprom.Fill(0,100,0);

	assertFalse(blinking_LEDs.InitStorage(-8, 10));
	assertFalse(blinking_LEDs.InitStorage(0, 3000));

	assertTrue(blinking_LEDs.InitStorage(0, 30));
	assertEqual(blinking_LEDs.eeprom.read(0),blinking_LEDs.BMK);
	assertEqual(blinking_LEDs.eeprom.read(1),30);
	assertEqual(blinking_LEDs.eeprom.read(30+2),blinking_LEDs.EMK);
}

void SaveSampleStorage(int addr, int size)
{
	unsigned char id;
	int startAddress = addr;

	blinking_LEDs.Clean();

	for(id=size; id>0; id--)
	{
		LED.pin = id;
		assertTrue(blinking_LEDs.Insert(LED));
	}

	blinking_LEDs.eeprom.Fill(addr, 100, 0);
	assertTrue(blinking_LEDs.InitStorage(startAddress, 10));
	assertTrue(blinking_LEDs.SaveStorage());
}

test(SaveStorage)
{
	unsigned char id;

	/// Store LED.pin = 10 .. LED.pin = 1
	SaveSampleStorage(88, 10);

	LED = blinking_LEDs.eeprom.Read(blinking_LEDs.GetTopAddressStorage())->item;
	assertEqual(LED.pin, 10);
}

test(LoadStorage)
{
	unsigned char id;

	SaveSampleStorage(88, 10);

	blinking_LEDs.Clean();
	assertEqual(blinking_LEDs.Counter(), 0);

	assertTrue(blinking_LEDs.LoadStorage());
	assertEqual(blinking_LEDs.Counter(), 10);

	assertTrue(blinking_LEDs.Top());
	id=10;
	do
	{
		LED = *blinking_LEDs.Select();
		assertEqual(LED.pin, id--);
	} while (blinking_LEDs.Next());

	blinking_LEDs.eeprom.Fill(88, 100, 0);
	assertFalse(blinking_LEDs.LoadStorage());
}

test(GetTopAddressStorage)
{
	unsigned int id;

	/// Store 1 time data on buffer
	SaveSampleStorage(88, 10);

	/// Store 9 times data on buffer
	for (id=0; id<9; id++) assertTrue(blinking_LEDs.SaveStorage());

	/// Check ring shift of top address related to parameter buffer (true data)
	/// after 10 times storing data on buffer
	assertEqual(blinking_LEDs.GetTopAddressStorage(), 88 + 10 + 4);
}

test(NextFreeAddressStorage)
{
	unsigned int id;
	int newAddress;

	assertFalse(blinking_LEDs.InitStorage(0,1000));
	assertEqual(blinking_LEDs.NextFreeAddressStorage(),-1);

	SaveSampleStorage(88, 10);

	assertTrue(blinking_LEDs.LoadStorage());
	assertEqual(blinking_LEDs.Counter(), 10);

	newAddress = blinking_LEDs.NextFreeAddressStorage();

	/// 88 = start address of the storage
	/// 10 = max number of items expected within the storage
	/// 4 = (BMK + EMK) MarKers +
	///	   + Byte reserved to max number of items
	///	   + Byte reserved to current number of items stored
	assertEqual( newAddress, 88 + 10 + 4 + 10*sizeof(*blinking_LEDs.xitem) );

	LED.pin = 9;
	LED.blinking = 0;
	LED.delay_ms = 90;
	blinking_LEDs.xitem->item = LED;
	blinking_LEDs.xitem->item.blinking = false;
	blinking_LEDs.xitem->item.pin = 9;
	blinking_LEDs.eeprom.Write(newAddress, *blinking_LEDs.xitem);

	assertTrue(blinking_LEDs.Top());
	id=10;
	do
	{
		LED = *blinking_LEDs.Select();
		assertEqual(LED.pin, id--);
	} while (blinking_LEDs.Next());

	assertEqual( blinking_LEDs.eeprom.Read(newAddress)->item.delay_ms, 90);
}

#endif



int main(int argc, char *argv[]) {
	init();

	/// Init serial communications and wait for port to open:
	Serial.begin(115200);

	/// Wait for serial port to connect (this is an optional condition board related)
	while (!Serial);
	delay(50);

	/// Init default LED parameters
	LED.blinking = true;
	LED.delay_ms = 10;
	LED.pin = 1;

	Serial.println("Test XTable Arduino Class");
	Test::min_verbosity = TEST_VERBOSITY_NONE;

	/// Initialize buffer on sram to manage maximum expected items
	if (!blinking_LEDs.InitBuffer(30))
	{
		PRINT("Error: cannot allocate required memory");
		delay(100);
		exit(0);
	}

	Test::exclude("*");
	Test::include("Clean");
	Test::include("Insert");
	Test::include("InsertCheckId");
	Test::include("InsertId");
	Test::include("InsertIdTenEntries");
	Test::include("Select");
	Test::include("SelectIdTenEntries");
	Test::include("Update");
	Test::include("UpdateSpecificId");
	Test::include("Delete");
	Test::include("GetId");
	Test::include("Status");
	Test::include("StatusTenEntries");
	Test::include("BrowseAll");
	Test::include("Counter");
	Test::include("Top");
	Test::include("Next");
	Test::include("InitStorage");
	Test::include("SaveStorage");
	Test::include("LoadStorage");
	Test::include("GetTopAddressStorage");
	Test::include("NextFreeAddressStorage");

	while(1) Test::run();

	delay(200);
	exit(0);
}
