/*
RotationFilter.cpp

*/


#include <inttypes.h>
#include <stdint.h>
#include "RotationFilter.h"


RotationFilter::RotationFilter(IMUFilter * filterPtr, bool isChild) {

  // todo:?
  imuFilter = filterPtr;
  child = isChild; //if true, then parent class will update imu data, else this class should update imu data when calling updateState
}

/*
 * Inititalize filter variables
 */
void RotationFilter::init(void){
   reset();
   initRunningAverage();
   prevTime = millis();
}

/*
* reset: Initiliaze / reset variables
*/
void RotationFilter::reset() {
  model.averageCount = 0;
  model.maxAverageCount = MAX_AVERAGE_COUNT;
  model.accelAxis1Val = 0;
  model.accelAxis2Val = 0;
  model.accelRefAxisVal = 0;
  model.runningAverageAxis1 = 0;
  model.runningAverageAxis2 = 0;
  model.rotationNumber = 0;
  model.firstRotation = FIRST_ROTATION;
  model.secondRotation = SECOND_ROTATION;
  setAboutAxis(X); //updates aboutAxis and other params that depend on it
  for(int i = 0; i < MAX_AVERAGE_COUNT; i++){
    model.averageAxis1Buff[i] = 0;
    model.averageAxis2Buff[i] = 0;
  }
  
}

/*
 * Update rotation angle and accel axis data from imu
 */

void RotationFilter::updateState(void){
  if(!child){imuFilter->updateState();} //update imu data if there is no motionFilter parent calling updateState of imuFilter
  updateAxisValues();
  updateRotationAngleNew();
}

void RotationFilter::setAboutAxis(char axisNumber){
  axis_t axis = (axis_t)axisNumber;
  switch(axisNumber){
    case X:
      model.axis = axis;
      model.axis1Offset = YOFFSET;
      model.axis2Offset = ZOFFSET;
      model.accelScaleAxis1 = ACCEL_SCALE_Y;
      model.accelScaleAxis2 = ACCEL_SCALE_Z;
    break;

    case Y:
      model.axis = axis;
      model.axis1Offset = XOFFSET;
      model.axis2Offset = ZOFFSET;
      model.accelScaleAxis1 = ACCEL_SCALE_X;
      model.accelScaleAxis2 = ACCEL_SCALE_Z;
    break;

    case Z:
      //probably will never use this setting
      model.axis = axis;
      model.axis1Offset = XOFFSET;
      model.axis2Offset = YOFFSET;
      model.accelScaleAxis1 = ACCEL_SCALE_X;
      model.accelScaleAxis2 = ACCEL_SCALE_Y;
    break;

    default:
      //should never get to default, but just in case...
      model.axis1Offset = YOFFSET;
      model.axis2Offset = ZOFFSET;
      model.accelScaleAxis1 = ACCEL_SCALE_Y;
      model.accelScaleAxis2 = ACCEL_SCALE_Z;
    break;
  }
  
}

/*
 * Fill in axis values from imu based on the ref axis
 */

void RotationFilter::updateAxisValues(void){
  switch(model.axis){
    case X:
      model.accelAxis1Val = imuFilter->model.accel.y;
      model.accelAxis2Val = imuFilter->model.accel.z;
      model.accelRefAxisVal = imuFilter->model.accel.x;
      
    break;

    case Y:
      model.accelAxis1Val = imuFilter->model.accel.x;
      model.accelAxis2Val = imuFilter->model.accel.z;
      model.accelRefAxisVal = imuFilter->model.accel.y;
    break;

    case Z:
      //probably will never use this setting
      model.accelAxis1Val = imuFilter->model.accel.x;
      model.accelAxis2Val = imuFilter->model.accel.y;
      model.accelRefAxisVal = imuFilter->model.accel.z;
    break;

    default:
      //should never get to default, but just in case...
      model.accelAxis1Val = imuFilter->model.accel.y;
      model.accelAxis2Val = imuFilter->model.accel.z;
      model.accelRefAxisVal = imuFilter->model.accel.x;
    break;
  }
}

/*
 * Update rotation angle from imu data
 */

void RotationFilter::updateRotationAngle(void){
  if(model.averageCount < model.maxAverageCount){
                model.averageAxis1Buff[model.averageCount] = model.accelAxis1Val;
                model.averageAxis2Buff[model.averageCount] = model.accelAxis2Val;
                model.averageCount += 1;
            }

  else if (model.averageCount == model.maxAverageCount){
      model.runningAverageAxis1 = 0;
      model.runningAverageAxis2 = 0;
      for( char i=0; i < model.maxAverageCount; i++){
          model.runningAverageAxis1 += (float)model.averageAxis1Buff[i]/(float)model.maxAverageCount;
          model.runningAverageAxis2 += (float)model.averageAxis2Buff[i]/(float)model.maxAverageCount;
      }
      model.runningAverageAxis1 = model.runningAverageAxis1 - model.axis1Offset;
      model.runningAverageAxis2 = model.runningAverageAxis2 - model.axis2Offset;
      model.averageCount = 0;
  }
    
  if((model.runningAverageAxis1 >= -1*model.accelScaleAxis1) && (model.runningAverageAxis1 <= 1*model.accelScaleAxis1)){
      if((model.runningAverageAxis2 >= -1*model.accelScaleAxis2) && (model.runningAverageAxis2 <= 1*model.accelScaleAxis2)){
          model.angleRad = atan2(model.runningAverageAxis1, model.runningAverageAxis2);
          model.angleDeg = model.angleRad*180.0/PI;
          model.rotationNumber = (model.angleDeg >= ROTATION_ANGLE_THRESHOLD) ? FIRST_ROTATION:SECOND_ROTATION;
      }
  }
  
}

void RotationFilter::updateRotationAngleNew(void){
  timeDiff = millis() - prevTime;
  prevTime = millis();
  if(model.averageCount < model.maxAverageCount){
                model.runningAverageAxis1 -= ((float)model.averageAxis1Buff[model.averageCount]-model.axis1Offset)/(float)model.maxAverageCount;
                model.runningAverageAxis2 -= ((float)model.averageAxis2Buff[model.averageCount]-model.axis2Offset)/(float)model.maxAverageCount;
                
                model.averageAxis1Buff[model.averageCount] = model.accelAxis1Val;
                model.averageAxis2Buff[model.averageCount] = model.accelAxis2Val;
                
                model.runningAverageAxis1 += ((float)model.averageAxis1Buff[model.averageCount]-model.axis1Offset)/(float)model.maxAverageCount;
                model.runningAverageAxis2 += ((float)model.averageAxis2Buff[model.averageCount]-model.axis2Offset)/(float)model.maxAverageCount;
                model.averageCount++;
                if(model.averageCount >= model.maxAverageCount){model.averageCount=0;} //reset
  }
    
  if((model.runningAverageAxis1 >= -1*model.accelScaleAxis1) && (model.runningAverageAxis1 <= 1*model.accelScaleAxis1)){
      if((model.runningAverageAxis2 >= -1*model.accelScaleAxis2) && (model.runningAverageAxis2 <= 1*model.accelScaleAxis2)){
          model.angleRad = atan2(model.runningAverageAxis1, model.runningAverageAxis2);
          model.angleDeg = model.angleRad*180.0/PI;
      }
  }
  else{
     float degSec = (float)(imuFilter->model.gyro.x  - imuFilter->imu.gyro_off_x) / 16.4f; //x deg / sec gyro rate
     model.angleDeg +=degSec*(float)(timeDiff/1000.0);//deg/sec * time
    

  }

  model.rotationNumber = (model.angleDeg >= ROTATION_ANGLE_THRESHOLD) ? FIRST_ROTATION:SECOND_ROTATION;
 
}

/*
 * Intialize average buffer and running averages with single accelerometer values initially before main loop starts using updateState method
 */
void RotationFilter::initRunningAverage(void){
  delay(30);
  imuFilter->updateState();
  updateAxisValues();//get accel x,y and z values and put in proper order in model

  //fill in all average buffers with same accel value initially
  for(int i = 0; i<model.maxAverageCount; i++){
    model.averageAxis1Buff[i] = model.accelAxis1Val;
    model.averageAxis2Buff[i] = model.accelAxis2Val;

    model.runningAverageAxis1 += ((float)model.accelAxis1Val-model.axis1Offset)/(float)model.maxAverageCount;
    model.runningAverageAxis2 += ((float)model.accelAxis2Val-model.axis2Offset)/(float)model.maxAverageCount;
  }

}


