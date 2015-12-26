/*
IMUFilter.cpp
Author: jbthompson.eng@gmail.com
Date Created: 12/22/2015
Desc: Main object that is responsible for parsing imu accel and gyro data 
*/


#include <inttypes.h>
#include <stdint.h>
#include "IMUFilter.h"

/*
 * Constructor
*/
IMUFilter::IMUFilter(void) {

    imu = IMUduino();
    //reset variables
    reset();
}


/*
 * Reset MidiDevice attributes to defaults
*/
void IMUFilter::reset(void){
  //todo:
}

/*
 * Init MidiDevice by 
*/
void IMUFilter::init(void){
  //init objects
  imu.init();  
}

/*
 * Initialize the sensor model struct
 */

void IMUFilter::initModel(void){
  //todo: 
  //init params

  //init events

  //init measurements
}

/*
 * Filter accel and gyro data into model structure
 */
void IMUFilter::updateState(void){
  //todo: ?
}




