/*
MidiSensor.cpp
Author: jbthompson.eng@gmail.com
Date Created: 12/22/2015
Desc: Main object that is responsible for filtering motion data to produce data relating to midi events
*/


#include <inttypes.h>
#include <stdint.h>

/*
 * Constructor
*/
MidiSensor::MidiSensor(void) {
    beatFilter = BeatFilter();
    rotationFilter = RotationFilter();
    imu = imuFilter();
    //reset variables
    reset();
}


/*
 * Reset MidiDevice attributes to defaults
*/
void MidiSensor::reset(void){
  //todo:
}

/*
 * Init MidiDevice by 
*/
void MidiSensor::init(void){
  //init objects
  beatFilter.init();
  rotationFilter.init();
  imu.init();  
}

/*
 * Initialize the sensor model struct
 */

void MidiSensor::initModel(void){
  //todo: 
  //init params

  //init events

  //init measurements
}

/*
 * Filter beat and motion data and update model state variables (not on, off, cc ...etc)
 */
void MidiSensor::updateState(void){
  model.currentTime = millis();
  if(mode.currentTime - mode.prevTime <= mode.intervalTime)
  {
      return;
  }
  else{
      mode.prevTime = mode.currentTime;
  }
  
  imu.updateState();
  beatFilter.updateState();
  rotationFilter.updateState();
    
  //update model
  model.noteOn.enabled = beatFilter.model.beatDetected;
  model.event.dataByte2 = imu.model.measurements[model.event.sensorNumber];
  
  
  if(model.noteOff.set && (model.currentTime - model.noteOff.prevTime >= model.noteOff.maxDelay){
      model.noteOff.enabled = true;
      model.noteOff.set = false;
  }
  else if (model.noteOn.enabled && model.noteOff.set){
      model.noteOff.enabled = true;
      model.noteOff.set = true;
      model.noteOff.prevTime = model.currentTime;
  }
  else if (model.noteOn.enabled){
      model.noteOff.set = true;
      model.noteOff.prevTime = model.currentTime;
  }
  else{
      model.noteOff.enabled = false;
  }
}




