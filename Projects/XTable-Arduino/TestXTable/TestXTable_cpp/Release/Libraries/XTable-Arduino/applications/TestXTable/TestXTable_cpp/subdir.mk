################################################################################
# Automatically-generated file. Do not edit!
################################################################################

# Add inputs and outputs from these tool invocations to the build variables 
CPP_SRCS += \
/home/arduinodev/Arduino/libraries/XTable-Arduino/applications/TestXTable/TestXTable_cpp/TestXTable.cpp 

CPP_DEPS += \
./Libraries/XTable-Arduino/applications/TestXTable/TestXTable_cpp/TestXTable.cpp.d 

LINK_OBJ += \
./Libraries/XTable-Arduino/applications/TestXTable/TestXTable_cpp/TestXTable.cpp.o 


# Each subdirectory must supply rules for building sources it contributes
Libraries/XTable-Arduino/applications/TestXTable/TestXTable_cpp/TestXTable.cpp.o: /home/arduinodev/Arduino/libraries/XTable-Arduino/applications/TestXTable/TestXTable_cpp/TestXTable.cpp
	@echo 'Building file: $<'
	@echo 'Starting C++ compile'
	"/opt/arduino-1.6.5/hardware/tools/avr/bin/avr-g++" -c -g -Os -w -fno-exceptions -ffunction-sections -fdata-sections -fno-threadsafe-statics -MMD -mmcu=atmega328p -DF_CPU=16000000L -DARDUINO=nightly -DARDUINO_AVR_UNO -DARDUINO_ARCH_AVR     -I"/opt/arduino-1.6.5/hardware/arduino/avr/cores/arduino" -I"/opt/arduino-1.6.5/hardware/arduino/avr/variants/standard" -I"/home/arduinodev/Arduino/libraries/XTable-Arduino" -I"/home/arduinodev/Arduino/libraries/XTable-Arduino/src" -I"/home/arduinodev/Arduino/libraries/arduinounit-master" -I"/home/arduinodev/Arduino/libraries/arduinounit-master/src" -MMD -MP -MF"$(@:%.o=%.d)" -MT"$(@:%.o=%.d)" -D__IN_ECLIPSE__=1 -x c++ "$<"  -o  "$@"
	@echo 'Finished building: $<'
	@echo ' '


