/*
MotionFilter.h developed by jbthompson.eng@gmail.com
Date Created: 12/22/2015
*/



#include <inttypes.h>
#include <stdint.h>
#include "MotionFilter.h"


MotionFilter::MotionFilter(void):beatFilter(&imuFilter, true), rotationFilter(&imuFilter, true) {
  reset(); // reset all model variables to defaults
}

/*
 * Initialize beat and rotation filter and model
 */

void MotionFilter::init(void){
  imuFilter.init();
  beatFilter.init();
  rotationFilter.init();
}

/*
* reset: Initiliaze / reset variables
*/
void MotionFilter::reset() {
    beatFilter.reset();
    rotationFilter.reset();
}

/*
 * Update beatFilter and rotationFilter and model state
 */

void MotionFilter::updateState(void){
  imuFilter.updateState(); //get accel, gyro and mag x,y,z values and calibrate
  beatFilter.updateState();
  //rotationFilter.updateState();
  //update model
  model.beat = beatFilter.model.beat;
  model.angleRad = rotationFilter.model.angleRad;
  model.angleDeg = rotationFilter.model.angleDeg;
  model.angleDegGyro = rotationFilter.model.angleDegGyro;
}







