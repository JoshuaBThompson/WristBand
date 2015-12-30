/*
MotionFilter.h developed by jbthompson.eng@gmail.com
Date Created: 12/22/2015
*/



#include <inttypes.h>
#include <stdint.h>
#include "MotionFilter.h"


MotionFilter::MotionFilter(void) {
  bool parent = true;
  imuFilter = IMUFilter();
  beatFilter = BeatFilter(&imuFilter, parent); //sets beatFilter child attribute to true, so that it expects motion filter class to update imu filter model
  rotationFilter = RotationFilter(&imuFilter, parent); //sets rotationFilter child attribute to true...etc
}

/*
 * Initialize beat and rotation filter and model
 */

void MotionFilter::init(void){
  beatFilter.init();
  rotationFilter.init();
}

/*
* reset: Initiliaze / reset variables
*/
void MotionFilter::reset() {
    beatFilter.reset();
    rotationFilter.reset():
}

/*
 * Update beatFilter and rotationFilter and model state
 */

void MotionFilter::updateState(void){
  imuFilter.updateState(); //get accel, gyro and mag x,y,z values and calibrate
  beatFilter.updateState();
  rotationFilter.updateState();
  //update model
  model.beat = beatFilter.beat;
  model.angleRad = rotationFilter.model.angleRad;
  model.angleDeg = rotationFilter.model.angleDeg;
}





