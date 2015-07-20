/**
 *  @file    HelloWorld.cpp
 *  @author  AF
 *  @date    2/6/2014
 *  @version 1.1
 *
 *  @brief Provide an example of standard Arduino project in Wiring language under Eclipse IDE
 *
 *  @section DESCRIPTION
 *
 *  This application is meant as example. It is a useful test tool
 *  for standart output through virtual standard serial RS232C as
 *  part of Debianinux context.
 *
 */

#include "HelloWorld.h"

/**
 *   @brief  Setup function called once at startup of the sketch
 *   @param  no input parameters
 *   @return void
 */
void setup()
{
	Serial.begin(115200);
}

/*
 *   @brief  Loop function called in an endless loop
 *   @param  no input parameters
 *   @return void
 */
void loop()
{
	/// Send an output message through standard serial virtual port
	Serial.println("Hello World !!!");

	/// Delay one second
	delay(1000);
}
