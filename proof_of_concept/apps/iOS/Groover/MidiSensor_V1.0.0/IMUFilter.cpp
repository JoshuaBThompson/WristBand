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
IMUFilter::IMUFilter(void){
    
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
    
}


/*
 * Filter raw accel data into model structure
 */
void IMUFilter::updateState(int x,int y,int z){
    model.rawData.dataArray[0] = x; //fill imu raw data array with accel
    model.rawData.dataArray[1] = y;
    model.rawData.dataArray[2] = z;
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


