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
IMUFilter::IMUFilter(void): imu() {

}


/*
 * Reset MidiDevice attributes to defaults
*/
void IMUFilter::reset(void){
  //todo: clear all 
  for(int i = 0; i< SENSOR_VALUES_COUNT; i++){
    model.rawData.dataArray[i] = 0;
  }
  
  model.accel.x = model.accel.y = model.accel.z = 0;
  model.gyro.x = model.gyro.y = model.gyro.z = 0;
  model.mag.x = model.mag.y = model.mag.z = 0;
  model.prevTime = 0;
  model.angles.x = 0;
  model.anglesAtan2.x = 0;
  model.gyroOffsets.x = GYRO_DEG_SEC_OFFSET_X;
  model.gyroOffsets.y = GYRO_DEG_SEC_OFFSET_Y;
  model.gyroOffsets.z = GYRO_DEG_SEC_OFFSET_Z;
  
}

/*
 * Init MidiDevice by 
*/
void IMUFilter::init(void){
  //clear variables
  reset();
  //init objects
  imu.init(true);
  model.prevTime = millis();
  Serial.println("calibrating imuFilter");
  calibrateImu(); //get offsets
   
}


/*
 * Filter accel and gyro data into model structure
 */
void IMUFilter::updateState(void){
  getImu(); //calibrate data and fill sensor specific struct
  getAngles(millis() - model.prevTime);
  model.prevTime = millis();
}


/*
 * Get imu data
 */

void IMUFilter::getImu(void){
  imu.getRawValues(model.rawData.dataArray); //fill imu raw data array with accel, gyro and magnetometer data from imu sensor
  getAccel();
  getGyro();
  getMag();
}

/*
 * Apply any calibration to the raw imu data
 */

void IMUFilter::calibrateImu(void){
  //todo: ? any calibration
  calibrateAccel();
  //not using magnetometer or gyro at the moment
  calibrateGyro(); 
  calibrateMag();
  
}

/*
 * Calibrate accelerometer sensor data
 */
void IMUFilter::calibrateAccel(void){
  
}

/*
 * Calibrate gyro rate sensor data
 */
void IMUFilter::calibrateGyro(void){
  float degSecX, degSecY, degSecZ; 
  //todo: y and z values?

  for(int i = 0; i<GYRO_CALIB_COUNT; i++){
    getImu();
    degSecX +=(float)(model.gyro.x);
    degSecY +=(float)(model.gyro.y);
    degSecZ +=(float)(model.gyro.z);
    
    delay(20);
  }
  model.gyroOffsets.x = degSecX/GYRO_CALIB_COUNT;
  model.gyroOffsets.y = degSecY/GYRO_CALIB_COUNT;
  model.gyroOffsets.z = degSecZ/GYRO_CALIB_COUNT;
  Serial.print("x offset "); Serial.println(model.gyroOffsets.x);
}

/*
 * Calibrate magnetometer sensor data
 */
void IMUFilter::calibrateMag(void){
  
}


void IMUFilter::getAccel(void){
  //todo: any calibration

  //fill in accel data struct
  model.accel.x = model.rawData.data.accel_x;
  model.accel.y = model.rawData.data.accel_y;
  model.accel.z = model.rawData.data.accel_z;
  
}

void IMUFilter::getGyro(void){
  //todo: any calibration
  
  //fill in accel data struct
  model.gyro.x = model.rawData.data.gyro_x;
  model.gyro.y = model.rawData.data.gyro_y;
  model.gyro.z = model.rawData.data.gyro_z;
}

void IMUFilter::getMag(void){
  //todo: any calibration
  
  //fill in accel data struct
  model.mag.x = model.rawData.data.mag_x;
  model.mag.y = model.rawData.data.mag_y;
  model.mag.z = model.rawData.data.mag_z;
}

void IMUFilter::getAngles(unsigned long timeDiff){
  //x axis
  float degSecX = ((float)(model.gyro.x - model.gyroOffsets.x) / 16.4f); //x deg / sec gyro rate
  model.angles.x += (degSecX*(float)timeDiff/1000.0);//deg/sec * time
  model.angles.x = correctAbsAngle(model.angles.x);
  model.anglesAtan2.x = AbsAngleToAtan2(model.angles.x);

  //y axis
  float degSecY = ((float)(model.gyro.y - model.gyroOffsets.y) / 16.4f); //x deg / sec gyro rate
  model.angles.y += (degSecY*(float)timeDiff/1000.0);//deg/sec * time
  model.angles.y = correctAbsAngle(model.angles.y);
  model.anglesAtan2.y = AbsAngleToAtan2(model.angles.y);

  //z axis
  float degSecZ = ((float)(model.gyro.z - model.gyroOffsets.z) / 16.4f); //x deg / sec gyro rate
  model.angles.z += (degSecZ*(float)timeDiff/1000.0);//deg/sec * time
  model.angles.z = correctAbsAngle(model.angles.z);
  model.anglesAtan2.z = AbsAngleToAtan2(model.angles.z);
}


/*
 * Correct for angle surpassing 360 deg or -360 deg
 */
float IMUFilter::correctAbsAngle(float angle){
  if(angle >= 360.0){angle = angle - 360.0;}
  else if(angle <= -360.0){angle = angle + 360.0;}
  return angle;
}

/*
 * Convert absolute angle (0-360 deg) to Atan2 angle (0-180 deg or 0 - 179.99 deg)
 */

float IMUFilter::AbsAngleToAtan2(float angle){
  float Atan2Angle = 0;

  if(angle > 180){Atan2Angle = angle - 360.0;}
  else if(angle <= -180){Atan2Angle = 360.0 + angle;}
  else{
    Atan2Angle = angle;
  }
  
  return Atan2Angle;
}




