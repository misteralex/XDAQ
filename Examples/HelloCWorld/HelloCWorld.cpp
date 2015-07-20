/**
 *  @file    HelloCWorld.cpp
 *  @author  AF
 *  @date    2/6/2014
 *  @version 1.1
 *
 *  @brief Provide an example of standard Arduino project in C language under Eclipse IDE
 *
 *  @section DESCRIPTION
 *
 *  This application is meant as example. It is a useful test tool
 *  for standart output through virtual standard serial RS232C as
 *  part of Debianinux context.
 *
 */

#include "HelloCWorld.h"

/**
 *   @brief  Main process
 *   @param  no input parameters
 *   @return no output
 */
int main()
{
        int counter;

        init();

        /// Init serial communications and wait for port to open:
        Serial.begin(115200);

        /// Wait for serial port to connect (this is an optional condition board related)
        while (!Serial);
        delay(50);

        Serial.println("Hello World");
        delay(1000);

        counter = 0;
        for (;;) {
                Serial.print(counter++);
                Serial.println(": Welcome to Arduino C++ Linux World");
                delay(1000);
        }
        return 0;
}
