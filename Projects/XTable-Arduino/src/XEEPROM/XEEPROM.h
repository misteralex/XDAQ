/****************************************************************************
 * XEEPROM.h - Class for Arduino sketches				                            *
 * Copyright (C) 2015 by AF                                                 *
 *                                                                          *
 * This file is part of XDAQ v1.0 Project                                   *
 *                                                                          *
 *   XEEPROM is free software: you can redistribute it and/or modify it     *
 *   under the terms of the GNU General Public License as published         *
 *   by the Free Software Foundation, either version 3 of the License, or   *
 *   (at your option) any later version.                                    *
 *                                                                          *
 *   XEEPROM is distributed in the hope that it will be useful,             *
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of         *
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the          *
 *   GNU General Public License for more details.                           *
 *                                                                          *
 *   You should have received a copy of the GNU General Public              *
 *   License along with XEEPROM. 					                                  *
 *   If not, see <http://www.gnu.org/licenses/>. 			                      *
 ****************************************************************************/

/**
 *  @file    XEEPROM.h
 *  @author  AF
 *  @date    25/1/2015
 *  @version 1.0
 *
 *	@brief It extends memory management of generic structure than simple single byte
 *
 *  @section DESCRIPTION
 *
 *  This class is an updated version of standard EEPROM Arduino library.
 *  It extends EEPROM management to variable as combination of several data items
 *  or generic structure as defined in the template.
 *
 *  
 *  This component is part of XDAQ v1.0 Project.
 *  This code is in the public domain as well as XDAQ.
 * 
 *  See more at www.embeddedrevolution.info
 */


#ifndef XEEPROM_h
#define XEEPROM_h

#include <inttypes.h>
#include <avr/eeprom.h>


template <class X> class XEEPROM
{
  public:
    /// Standard function to read single byte from EEPROM
    uint8_t read(int);

    /// Standard function to write single byte from EEPROM
    void write(int, uint8_t);

    /// Extended function to read structure from EEPROM
    X* Read(int address);

    /// Extended function to write structure from EEPROM
    void Write(int address, X value);

    /// Function to clean specified piece of EEPROM
    void Fill(int address, unsigned int size, uint8_t value);

    /// Function to manage EEPROM size limit
    int Limit();

  private:
    X *X_value = new(X);
};


template <class X> uint8_t XEEPROM<X>::read(int address)
{
	return eeprom_read_byte((unsigned char *) address);
}

template <class X> void XEEPROM<X>::write(int address, uint8_t value)
{
	eeprom_write_byte((unsigned char *) address, value);
}

template <class X> X* XEEPROM<X>::Read(int address)
{
    uint8_t b[sizeof(*X_value)];
    for (int j=0; j<sizeof(*X_value); j++)
 	b[j] = eeprom_read_byte((unsigned char *) address+j);

    memcpy(X_value, b, sizeof(*X_value));
    return X_value;
}

template <class X> void XEEPROM<X>::Write(int address, X value)
{
    uint8_t b[sizeof(value)];

    memcpy(b, &value, sizeof(value));

    for (int j=0; j<sizeof(value); j++)
    	eeprom_write_byte((unsigned char *) address+j, b[j]);
}

template <class X> void XEEPROM<X>::Fill(int address, unsigned int size, uint8_t value)
{
    for (int j=0; j<size; j++)
        eeprom_write_byte((unsigned char *) address+j, value);
}

template <class X> int XEEPROM<X>::Limit()
{
    return E2END;
}

#endif
