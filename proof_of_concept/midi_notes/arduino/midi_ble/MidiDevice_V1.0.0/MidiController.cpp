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
  midiSensor = MidiSensor();
  midiProtocol = MidiProtocol();
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
  midiProtocol.init();
  //todo: init what?
  
}


void MidiController::changeNoteChannel(char channel){
  midiSensor.params.note.channel = channel;
}

void MidiController::changeNoteNumber(char number){
  midiSensor.params.note.number = number;
  
}

void MidiController::changeNoteMode(char modeNumber){
  midiSensor.params.note.mode = modeNumber;
}

void MidiController::changeNoteVelocity(char velocity){
  midiSensor.params.note.velocity = velocity;
}

void MidiController::changeMode(char modeNumber){
  midiSensor.params.mode.number = modeNumber;
}

void MidiController::changeCCFunction(char functionNumber){
  midiSensor.params.cc.number = functionNumber;
}

void MidiController::changeCCSensor(char sensorNumber){
  midiSensor.params.cc.sensor = sensorNumber;
}

void MidiController::changeFilterAverageCount(char averageCount){
  midiSensor.params.filter.averageCount = averageCount;
}

void MidiController::changeFilterMaxCount(char maxCount){
  midiSensor.params.filter.maxCount = maxCount;
}

void MidiController::changeFilterMaxAmp(char maxAmp){
  midiSensor.params.filter.maxAmp = maxAmp;
}

void MidiController::changeButtonFunction(char functionNumber){
  midiSensor.params.button.number = functionNumber;
}

