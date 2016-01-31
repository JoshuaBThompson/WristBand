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
  updateRotationAngle();
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


void RotationFilter::updateRotationAngle(void){
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
    
  if(abs(model.runningAverageAxis1) <= model.accelScaleAxis1 && abs(model.runningAverageAxis2) <= model.accelScaleAxis2){
       model.angleRad = atan2(model.runningAverageAxis1, model.runningAverageAxis2);
       model.angleDeg = model.angleRad*180.0/PI;
  }

  updateAngleDegGyro();
  updateRotationNumber();
  updateIMUAngleWithAccelAngle();
 
}

/*
 * Update angleDegGyro
 */

void RotationFilter::updateAngleDegGyro(void){
  //only run if gyro enabled on imu
  if(!imuFilter->model.gyro.enabled){return;}
  switch(model.axis){
      case X:
        model.angleDegGyro = imuFilter->model.anglesAtan2.x;
        
      break;
  
      case Y:
        model.angleDegGyro = imuFilter->model.anglesAtan2.y;
      break;
  
      case Z:
        model.angleDegGyro = imuFilter->model.anglesAtan2.y;
      break;
  
      default:
        model.angleDegGyro = imuFilter->model.anglesAtan2.x;
      break;
  }
}

/*
 * update rotation number based on angle of rotation
 */

void RotationFilter::updateRotationNumber(void){
  if(imuFilter->model.gyro.enabled){
    model.rotationNumber = (model.angleDegGyro >= ROTATION_ANGLE_THRESHOLD) ? FIRST_ROTATION:SECOND_ROTATION;
  }
  else{
    model.rotationNumber = (model.angleDeg >= ROTATION_ANGLE_THRESHOLD) ? FIRST_ROTATION:SECOND_ROTATION;
  }
}

/*
 * Set the imu abs angle value to the calculated accel value, should be done every 20 - 30 sec
 */

void RotationFilter::updateIMUAngleWithAccelAngle(void){
  //only run if gyro enabled on imu
  if(!imuFilter->model.gyro.enabled){return;}
  
  rateGyroTimeDiff = millis() - prevRateGyroTimeDiff;
  if(rateGyroTimeDiff >= MAX_GYRO_TIME_DIFF){
     prevRateGyroTimeDiff = millis();
     //todo: update angles.x with correct angleDeg transformation (since using atan2)
     switch(model.axis){
      case X:
        imuFilter->model.angles.x = model.angleDeg;
        
      break;
  
      case Y:
        imuFilter->model.angles.y = model.angleDeg;
      break;
  
      case Z:
        imuFilter->model.angles.z = model.angleDeg;
      break;
  
      default:
        imuFilter->model.angles.x = model.angleDeg;
      break;
  }
     
  }
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



