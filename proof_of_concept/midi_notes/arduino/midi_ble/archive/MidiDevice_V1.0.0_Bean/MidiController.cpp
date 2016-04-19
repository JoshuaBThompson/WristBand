/*
MidiController.cpp
Author: jbthompson.eng@gmail.com
Date Created: 12/22/2015
Desc: Main object that is responsible for retrieving midi event data from the midi sensor object producing midi ble messages.
      Also responsible for updating the midi sensor operating parameters (note value, velocity, cc type and others)
*/


#include <inttypes.h>
#include <stdint.h>
#include "MidiController.h"

/*
 * Constructor
*/
MidiController::MidiController(void) {
  //reset variables
  reset();
  
}


/*
 * Reset MidiDevice attributes to defaults
*/
void MidiController::reset(void){
  
}

/*
 * Init MidiDevice by 
*/
void MidiController::init(void){
  //init objects
  midiSensor.init();
  Serial.println("init midi controller");
  //todo: init what?
  
}


void MidiController::changeNoteChannel(byte channel){
  //Serial.print("changetNoteChannel "); //Serial.println(channel);
  
  midiSensor.setNoteChannel(channel);
}

void MidiController::changeNote1Number(byte number){
  //Serial.print("changeNote1Number "); //Serial.println(number);
  midiSensor.setNote1Number(number);
  
}

void MidiController::changeNote2Number(byte number){
  //Serial.print("changeNote2Number "); //Serial.println(number);
  midiSensor.setNote2Number(number);
  
}

void MidiController::changeNoteVelocity(byte velocity){
  //Serial.print("changeNoteVelocity "); //Serial.println(velocity);
  midiSensor.setNoteVelocity(velocity);
}

void MidiController::changeNoteMode(char modeNumber){
  //Serial.print("changeNoteMode "); //Serial.println(modeNumber);
  midiSensor.setMidiNoteMode(modeNumber);
}


/*
 * Change generic midi event type (ex cc)
 */
void MidiController::changeEventType(byte eventType){
  //Serial.print("changeEventType "); //Serial.println(eventType);
  midiSensor.setEventType(eventType);
}

/*
 * Change sensor source of generic midi event output (ex accelerometer)
 */
void MidiController::changeEventSource(char sourceNumber){
  //Serial.print("changeEventSource "); //Serial.println(sourceNumber);
  midiSensor.setMidiEventSource(sourceNumber);
}

void MidiController::changeBeatFilterAverageCount(char averageCount){
  //Serial.print("changeBeatFilterAverageCount "); //Serial.println(averageCount);
}

void MidiController::changeBeatFilterMaxCount(char maxCount){
   //Serial.print("changeBeatFilterMaxCount "); //Serial.println(maxCount);
}

void MidiController::changeBeatFilterMaxAmp(char maxAmp){
  //Serial.print("changeBeatFilterMaxAmp "); //Serial.println(maxAmp);
}

void MidiController::changeButtonFunction(char functionNumber){
   //Serial.print("changeButtonFunction "); //Serial.println(functionNumber);
}



