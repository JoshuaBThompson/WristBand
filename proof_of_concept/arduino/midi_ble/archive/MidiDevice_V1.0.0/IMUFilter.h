/*
IMUFilter.h developed by jbthompson.eng@gmail.com
Date Created: 12/22/2015
*/

#ifndef IMUFilter_h
#define IMUFilter_h

#include "Arduino.h"
#include "IMUduino.h"

//----Constants
#define SENSOR_VALUES_COUNT 11 //accel x,y,z | gyro x,y,z | mag x,y,z | altitude and temperature

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
  int pressure; //todo: double check this
  int temperature; //todo: double check this
} imu_measurements_t;

typedef union {
  imu_measurements_t data;
  int dataArray[SENSOR_VALUES_COUNT];
} imu_enum_t;


//generic data struct that can apply to accelerometer, rate gyro or magnetometer
typedef struct {
  int x;
  int y;
  int z;
} axis_sensor_data_t;

typedef struct {
  imu_enum_t rawData;
  axis_sensor_data_t accel;
  axis_sensor_data_t gyro;
  axis_sensor_data_t mag;
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
    void reset(void);
    void updateState(void);
    void calibrateImu(void);
    void calibrateAccel(void);
    void calibrateGyro(void);
    void calibrateMag(void);
    
    //attributes
    imu_filter_model_t model;
    IMUduino imu; 
};

#endif // IMUFilter_h



