/*
IMUFilter.h developed by jbthompson.eng@gmail.com
Date Created: 12/22/2015
*/

#ifndef IMUFilter_h
#define IMUFilter_h

#include "Arduino.h"
#include "IMUduino.h"


/*********ImuFilter model Struct
 * Defines structure of ImuFilter model data
 * accel, gyro and magnetometer values
***********/

//-------------Define measurements struct
typedef struct {
  int accel_x;
  int accel_y;
  int accel_z;
  int gyro_x;
  int gyro_y;
  int gyro_z;
  int mag_x;
  int mag_y;
  int mag_z;
  int s1;
  int s2; 
} imu_measurements_t;

typedef union {
  imu_measurements_t data;
  int data_array;
} imu_enum_t;

typdef struct {
  imu_enum_t raw_data;
} imu_filter_model_t;

/*
 * IMUFilter class
 */

class IMUFilter
{
  public:
    //Methods
    IMUFilter(void);
    void init(void);
    void initModel(void);
    void reset(void);
    void updateState(void);
    
    //attributes
    imu_filter_model_t model;
    IMUduino imu; 
};

#endif // IMUFilter_h


