/*
MotionFilter.h developed by jbthompson.eng@gmail.com
Date Created: 12/22/2015
*/



#include <inttypes.h>
#include <stdint.h>
#include "MotionFilter.h"


MotionFilter::MotionFilter(void) {
  imuFilter = IMUFilter();
  beatFilter = BeatFilter(&imuFilter);
  rotationFilter = RotationFilter(&imuFilter);
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
  beatFilter.updateState();
  rotationFilter.updateState();
  
  //todo: update model?
}





