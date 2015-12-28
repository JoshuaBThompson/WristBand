/*
IMUDuino.cpp - Originally based on FreeIMU.cpp - A libre and easy to use orientation sensing library for Arduino
Copyright (C) 2011-2012 Fabio Varesano <fabio at varesano dot net>

Development of this code has been supported by the Department of Computer Science,
Universita' degli Studi di Torino, Italy within the Piemonte Project
http://www.piemonte.di.unito.it/


This program is free software: you can redistribute it and/or modify
it under the terms of the version 3 GNU General Public License as
published by the Free Software Foundation.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.

*/


#include <inttypes.h>
#include <stdint.h>
#include "RotationFilter.h"


RotationFilter::RotationFilter(IMUFilter * imuFilterPtr) {

  // todo:?
  imuFilter = imuFilterPtr;
}

/*
 * Inititalize filter variables
 */
void RotationFilter::init(void){
   reset();
}

/*
* reset: Initiliaze / reset variables
*/
void RotationFilter::reset() {
  
}

/*
 * Update rotation angle and accel axis data from imu
 */

void RotationFilter::updateState(void){
  updateAxisValues();
  updateRotationAngle();
}

/*
 * Fill in axis values from imu based on the ref axis
 */

void RotationFilter:updateAxisValues(void){
  switch(model.aboutAxis){
    case X:
      model.accelAxis1Val = imuFilter.model.accel.y;
      model.accelAxis2Val = imuFilter.model.accel.z;
      model.accelRefAxisVal = imuFilter.model.accel.x;
      
    break;

    case Y:
      model.accelAxis1Val = imuFilter.model.accel.x;
      model.accelAxis2Val = imuFilter.model.accel.z;
      model.accelRefAxisVal = imuFilter.model.accel.y;
    break;

    case Z:
      //probably will never use this setting
      model.accelAxis1Val = imuFilter.model.accel.x;
      model.accelAxis2Val = imuFilter.model.accel.y;
      model.accelRefAxisVal = imuFilter.model.accel.z;
    break;

    default:
      //should never get to default, but just in case...
      model.accelAxis1Val = imuFilter.model.accel.y;
      model.accelAxis2Val = imuFilter.model.accel.z;
      model.accelRefAxisVal = imuFilter.model.accel.x;
    break;
  }
}

/*
 * Update rotation angle from imu data
 */

void RotationFilter::updateRotationAngle(void){
  if(model.averageCount < model.maxAverageCount){
                model.averageAxis1Buff[averageCount] = model.accelAxis1Val;
                model.averageAxis2Buff[averageCount] = model.accelAxis2Val;
                model.averageCount += 1;
            }

  else if (model.averageCount == model.maxAverageCount){
      model.runningAverageAxis1 = 0;
      model.runningAverageAxis2 = 0;
      for( char i=0; i < model.maxAverageCount; i++){
          model.runningAverageAxis1 += (float)model.averageAxis1Buff[i]/(float)model.maxAverageCount;
          running_average_z += (float)model.averageAxis2Buff[i]/(float)model.maxAverageCount;
      }
      model.runningAverageAxis1 = model.runningAverageAxis1 - axis1Offset;
      model.runningAverageAxis2 = model.runningAverageAxis2 - axis2Offset;
      model.averageCount = 0;
  }
    
  if((model.runningAverageAxis1 >= -1*model.accelScaleAxis1) && (model.runningAverageAxis1 <= 1*model.accelScaleAxis1)){
      if((model.runningAverageAxis2 >= -1*model.accelScaleAxis2) && (model.runningAverageAxis2 <= 1*model.accelScaleAxis2)){
          model.angleRad = atan2(model.runningAverageAxis1, model.runningAverageAxis2);
          model.angleDeg = (int)(model.angleRad*180.0/PI);
      }
  }
  
}

