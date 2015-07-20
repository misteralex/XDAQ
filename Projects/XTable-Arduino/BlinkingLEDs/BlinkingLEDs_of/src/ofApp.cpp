/************************************************************************************
 * BlinkingLEDs_of - Firmata example of openFrameworks application                  *
 * Copyright (C) 2015 by AF                                                         *
 *                                                                                  *
 * This file is part of XDAQ Support                                                *
 *                                                                                  *
 *   BlinkingLEDs is free software: you can redistribute it and/or modify it        *
 *   under the terms of the GNU General Public License as published                 *
 *   by the Free Software Foundation, either version 3 of the License, or           *
 *   (at your option) any later version.                                            *
 *                                                                                  *
 *   BlinkingLEDs is distributed in the hope that it will be useful,                *
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of                 *
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the                  *
 *   GNU General Public License for more details.                                   *
 *                                                                                  *
 *   You should have received a copy of the GNU General Public                      *
 *   License along with BlinkingLEDs. If not, see <http://www.gnu.org/licenses/>.   *
 ************************************************************************************/

/**
 *  @file    ofApp.cpp
 *  @author  AF
 *  @date    26/2/2015
 *  @version 1.0
 *
 *  @brief  Client side of BlinkingLEDs oF application as useful complement of
 *          XTable class design
 *
 *  @section DESCRIPTION
 *
 *  This application is part of BlinkingLEDs application as complement of
 *  XTable class. It works as PC application connected over standard serial
 *  interface with a standard Arduino board provided of related firmware.
 *  Please see more about XTable C++ class on GitHub.
 */

#include "ofApp.h"

/// Status buffer of all LEDs
bool LED[7];

//--------------------------------------------------------------
void ofApp::setup(){

	ofSetVerticalSync(true);
	ofSetFrameRate(60);

	ofBackground(255,0,130);

    buttonState = "digital pin:";
    potValue = "analog pin:";

	bgImage.loadImage("background.png");
	font.loadFont("franklinGothic.otf", 20);
    smallFont.loadFont("franklinGothic.otf", 14);

    // replace the string below with the serial port for your Arduino board
	ard.connect("/dev/ttyACM0", 115200);

	// listen for EInitialized notification. this indicates that
	// the arduino is ready to receive commands and it is safe to
	ofAddListener(ard.EInitialized, this, &ofApp::setupArduino);

	/// Reset status of all LEDs
	for (int i=2; i<7; i++) LED[i] = 0;
}

//--------------------------------------------------------------
void ofApp::update(){
	updateArduino();
}

//--------------------------------------------------------------
void ofApp::setupArduino(const int & version) {

	// remove listener because we don't need it anymore
	ofRemoveListener(ard.EInitialized, this, &ofApp::setupArduino);

    // it is now safe to send commands to the Arduino
    bSetupArduino = true;

    // print firmware name and version to the console
    ofLogNotice() << ard.getFirmwareName();
    ofLogNotice() << "firmata v" << ard.getMajorFirmwareVersion() << "." << ard.getMinorFirmwareVersion();

    /// set pins D2 and A5 to digital input
    ard.sendDigitalPinMode(2, ARD_INPUT);
    ard.sendDigitalPinMode(3, ARD_INPUT);
    ard.sendDigitalPinMode(4, ARD_INPUT);
    ard.sendDigitalPinMode(5, ARD_INPUT);
    ard.sendDigitalPinMode(6, ARD_INPUT);
    ard.sendDigitalPinMode(13, ARD_OUTPUT);

    // Listen for changes on the digital and analog pins
    ofAddListener(ard.EDigitalPinChanged, this, &ofApp::digitalPinChanged);
}

//--------------------------------------------------------------
void ofApp::updateArduino(){

	// update the arduino, get any data or messages.
    // the call to ard.update() is required
	ard.update();
}


//--------------------------------------------------------------
// digital pin event handler, called whenever a digital pin value has changed
void ofApp::digitalPinChanged(const int & pinNum) {
    // do something with the digital input. here we're simply going to print the pin number and
    // value to the screen each time it changes
    buttonState = "digital pin: " + ofToString(pinNum) + " = " + ofToString(ard.getDigital(pinNum));
    LED[pinNum] = ard.getDigital(pinNum);
}


//--------------------------------------------------------------
void ofApp::draw()
{
    int x0 = 310;
	bgImage.draw(0,0);

    ofEnableAlphaBlending();
    ofSetColor(230, 230, 230, 127);
    ofRect(160, 60, 460, 115);
    ofSetColor(230, 230, 230, 127);
    ofDisableAlphaBlending();

    ofSetColor(0, 0, 64);
    smallFont.drawString("BlinkingLEDs (XTable Test Application)", 250, 20);
    smallFont.drawString("BlinkingLEDs: test project for XTable embedded class", 190, 570);
    smallFont.drawString("www.embeddedrevolution.info", 290, 590);

	if (!bSetupArduino){
		font.drawString("Arduino not ready...\n", 290, 150);
	}
	else
	{
        smallFont.drawString("Digital Pin", x0-140,90);
        smallFont.drawString("Channel", x0-140,160);
        for (int i=0; i<5; i++)
        {
            smallFont.drawString(ofToString(i+2),x0+i*70-3,90);
            smallFont.drawString(ofToString(i), x0+i*70-3,160);
        }

        if (LED[2]) ofSetColor(255,0,0);
        else ofSetColor(160, 15, 15);
        ofCircle(x0,120,15);

        if (LED[3]) ofSetColor(255,0,0);
        else ofSetColor(160, 15, 15);
        ofCircle(x0+70,120,15);

        if (LED[4]) ofSetColor(255,0,0);
        else ofSetColor(160, 15, 15);
        ofCircle(x0+140,120,15);

        if (LED[5]) ofSetColor(255,0,0);
        else ofSetColor(160, 15, 15);
        ofCircle(x0+210,120,15);

        if (LED[6]) ofSetColor(255,0,0);
        else ofSetColor(160, 15, 15);
        ofCircle(x0+280,120,15);

        font.drawString("Click on background to switch configuration\n", 125, 230);
	}

    ofSetColor(240, 240, 240);
}

//--------------------------------------------------------------
void ofApp::keyPressed  (int key){
}

//--------------------------------------------------------------
void ofApp::keyReleased(int key){

}

//--------------------------------------------------------------
void ofApp::mouseMoved(int x, int y ){

}

//--------------------------------------------------------------
void ofApp::mouseDragged(int x, int y, int button){

}

//--------------------------------------------------------------
void ofApp::mousePressed(int x, int y, int button){
    // Switch between available configurations when the application window is clicked
    // and turn on the onboard LED
	ard.sendDigital(13, ARD_HIGH);
	ard.sendString("s");
}

//--------------------------------------------------------------
void ofApp::mouseReleased(int x, int y, int button){
    // turn off the onboard LED
	ard.sendDigital(13, ARD_LOW);
}

//--------------------------------------------------------------
void ofApp::windowResized(int w, int h){

}

//--------------------------------------------------------------
void ofApp::gotMessage(ofMessage msg){

}

//--------------------------------------------------------------
void ofApp::dragEvent(ofDragInfo dragInfo){

}
