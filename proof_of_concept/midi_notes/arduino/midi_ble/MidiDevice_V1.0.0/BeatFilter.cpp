/*
BeatFilter.cpp developed by jbthompson.eng@gmail.com
Date Created: 12/22/2015
*/


#include <inttypes.h>
#include <stdint.h>
#include "BeatFilter.h"


BeatFilter::BeatFilter(IMUFilter * imuFilterPtr) {
  // todo:?
  imuFilter = imuFilterPtr;
}


/*
 * UpdateState of beatFilter using updated imuData and updating beat calculation
 */

void BeatFilter::updateState(void){
  updateAxisValues();
  int x = model.axisValues[model.axis];
  isBeat(x);
}

/*
 * Inititalize filter variables
 */
void BeatFilter::init(void){
  reset(); 
}

/*
* setX1: set the class variable x0 representing the previous data point, usually set to x1 after difference calculation
*/
void BeatFilter::setX0(long int x){
    model.x0 = x;
}

/*
* setX1: set the class variable x1 representing the most recent data point
*/
void BeatFilter::setX1(long int x){
    model.x1 = x;
}


/*
* isBeat: See if a beat motion is generated with new data point
*/
bool BeatFilter::isBeat(long int x){  
    
    //-------Get x0, x1 and difference between them
    setX1(x);
    model.diff = model.x1 - model.x0; //get difference between current and prev samples to see if acceleration is rising or falling
    setX0(model.x1); //update x0 for next sample
    
    
    //-------Get rising, falling and sample count
    model.rising = model.rising || (model.diff >= model.minDiff); //rising if rising previously or current rising detected
    
    if(model.rising){
      model.samples++; //only increment samples if rising / falling
      model.falling = model.diff <= model.minFalling;
      
      if(model.falling){
        model.samples++;
      }
    }
     
    
    //--------Get running sum
    //If not rising then set to 0
    model.xSum = (model.xSum + model.diff) * model.rising;
    
    //--------Get beat
    if(model.diff <= model.catchFalling && !model.beat && !model.rising){
      //catch a large falling data point that might have been missed
      //If the fall is large enough then this is probably a beat motion
      model.beat = true;
    }
    else{
      //normal beat should be interpreted when total xsum is close to initial x0 recorded when first rise detected
      //rising and falling must both be set to indicate a complete beat
      model.beat = (model.xSum <= model.minSum) && model.rising && model.falling;
    }
    
    //-------Check for reset condition
    if(model.beat || (model.samples >= model.maxSamples)){
        //reset all if beat is valid or max samples detected
        model.xSum = 0; 
        model.samples = 0;
        model.rising = 0;
        model.falling = 0;
    }
    
    return model.beat;
}


/*
* reset: Initiliaze / reset variables
*/
void BeatFilter::reset() {
    model.falling = false;
    model.rising = false;
    model.beat = false;
    model.x1 = model.x0 = model.xSum = model.diff = 0;
    model.samples = 0;
    model.axis = X;

    //init params to default values
    model.minDiff = MinDiff;
    model.minSum = MinSum;
    model.minFalling = MinFalling;
    model.catchFalling = CatchFalling;
    model.maxSamples = MaxSamples;
    model.motionSource = ACCEL_MOTION_SOURCE;
}

void BeatFilter::updateMotionSource(char motion_number){
  model.motionSource = motion_number;

  //todo: any params depend on the source?
  switch(model.motionSource){
    case ACCEL_MOTION_SOURCE:
    break;

    case GYRO_MOTION_SOURCE:
    break;

    case MAG_MOTION_SOURCE:
      //probably will never use this setting
    break;

    default:
      //should never get to default, but just in case...
    break;
  }
  
}

/*
 * Fill in axis values from imu based on the ref axis
 */

void BeatFilter:updateAxisValues(void){
  model.motionSource = motion_number;

  switch(model.motionSource){
    case ACCEL_MOTION_SOURCE:
      model.axisValues[0] = imuFilter->model.accel.x;
      model.axisValues[1] = imuFilter->model.accel.y;
      model.axisValues[2] = imuFilter->model.accel.z;
      
    break;

    case GYRO_MOTION_SOURCE:
      model.axisValues[0] = imuFilter->model.gyro.x;
      model.axisValues[1] = imuFilter->model.gyro.y;
      model.axisValues[2] = imuFilter->model.gyro.z;
    break;

    case MAG_MOTION_SOURCE:
      //probably will never use this setting
      model.axisValues[0] = imuFilter->model.mag.x;
      model.axisValues[1] = imuFilter->model.mag.y;
      model.axisValues[2] = imuFilter->model.mag.z;
    break;

    default:
      //should never get to default, but just in case...
    break;
  }
}





