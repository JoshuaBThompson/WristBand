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
  //todo: init what?
  
}


void MidiController::changeNoteChannel(byte channel){
  midiSensor.setNoteChannel(channel);
}

void MidiController::changeNote1Number(byte number){
  midiSensor.setNote1Number(number);
  
}

void MidiController::changeNote2Number(byte number){
  midiSensor.setNote2Number(number);
  
}

void MidiController::changeNoteVelocity(byte velocity){
  midiSensor.setNoteVelocity(velocity);
}

void MidiController::changeNoteMode(char modeNumber){
  midiSensor.setMidiNoteMode(modeNumber);
}


/*
 * Change generic midi event type (ex cc)
 */
void MidiController::changeEventType(byte eventType){
  midiSensor.setEventType(eventType);
}

/*
 * Change sensor source of generic midi event output (ex accelerometer)
 */
void MidiController::changeEventSource(char sourceNumber){
  midiSensor.setMidiEventSource(sourceNumber);
}

void MidiController::changeBeatFilterAverageCount(char averageCount){
}

void MidiController::changeBeatFilterMaxCount(char maxCount){
}

void MidiController::changeBeatFilterMaxAmp(char maxAmp){
}

void MidiController::changeButtonFunction(char functionNumber){
}


