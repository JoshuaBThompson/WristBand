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
  motionFilter = MotionFilter();
  imu = IMUduino();
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
  motionFilter.init();
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

