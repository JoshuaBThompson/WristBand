/*
BeanIMU.cpp
Author: jbthompson.eng@gmail.com
Date Created: 12/22/2015
Desc: Main object that is responsible for parsing imu accel and gyro data 
*/


#include <inttypes.h>
#include <stdint.h>
#include "BeanIMU.h"

/*
 * Constructor
*/
BeanIMU::BeanIMU(void){
  //todo: ?

}


/*
 * Init IMU 
*/
void BeanIMU::init(void){
  //todo: ? 
}


/*
 * Get raw imu values...
 */

void BeanIMU::getRawValues(int * rawValues){
  //get accel
  
    // Get the current acceleration with range of ±2g, and a conversion of 3.91×10-3 g/unit (255 / g). 
    AccelerationReading acceleration = Bean.getAcceleration();
    rawValues[0] = acceleration.xAxis; rawValues[1] = acceleration.yAxis; rawValues[2] = acceleration.zAxis;
    
  //get gyro?

  //get mag?
}

 
