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
}

/*
 * Init MidiDevice by 
*/
void IMUFilter::init(void){
  //clear variables
  reset();
  //init objects
  imu.init(true);
  Serial.println("init imu"); 
  delay(100);
  int data[11];
  imu.getRawValues(data);
  Serial.println(data[0]);
  Serial.println(data[1]);
  delay(40);
  imu.getRawValues(data);
  Serial.println(data[0]);
  Serial.println(data[1]);
  delay(50);
  imu.getRawValues(data);
  Serial.println(data[0]);
  Serial.println(data[1]);
  delay(3000);
   
}


/*
 * Filter accel and gyro data into model structure
 */
void IMUFilter::updateState(void){
  int myArray[11];
  imu.getRawValues(model.rawData.dataArray); //fill imu raw data array with accel, gyro and magnetometer data from imu sensor
  calibrateImu(); //calibrate data and fill sensor specific struct
}


/*
 * Apply any calibration to the raw imu data
 */

void IMUFilter::calibrateImu(void){
  //todo: ? any calibration
  calibrateAccel();

  //not using magnetometer or gyro at the moment
  //calibrateGyro(); 
  //calibrateMag();
  
}

void IMUFilter::calibrateAccel(void){
  //todo: any calibration

  //fill in accel data struct
  model.accel.x = model.rawData.data.accel_x;
  model.accel.y = model.rawData.data.accel_y;
  model.accel.z = model.rawData.data.accel_z;
  
}

void IMUFilter::calibrateGyro(void){
  //todo: any calibration
  
  //fill in accel data struct
  model.gyro.x = model.rawData.data.gyro_x;
  model.gyro.y = model.rawData.data.gyro_y;
  model.gyro.z = model.rawData.data.gyro_z;
}

void IMUFilter::calibrateMag(void){
  //todo: any calibration
  
  //fill in accel data struct
  model.mag.x = model.rawData.data.mag_x;
  model.mag.y = model.rawData.data.mag_y;
  model.mag.z = model.rawData.data.mag_z;
}

