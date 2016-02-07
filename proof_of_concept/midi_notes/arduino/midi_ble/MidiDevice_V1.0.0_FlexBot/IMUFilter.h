/*
IMUFilter.h developed by jbthompson.eng@gmail.com
Date Created: 12/22/2015
*/

#ifndef IMUFilter_h
#define IMUFilter_h

#include "Arduino.h"
#include "IMUduino_AG.h"

//----Constants
#define SENSOR_VALUES_COUNT 6 //accel x,y,z | gyro x,y,z
#define GYRO_DEG_SEC_OFFSET_X 5 //raw gyro offset
#define GYRO_DEG_SEC_OFFSET_Y 5
#define GYRO_DEG_SEC_OFFSET_Z 5
#define GYRO_CALIB_COUNT 5 //40 * 20 ms = 800 ms
#define GYRO_CALIB_DELAY  20 //ms

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
  bool enabled;
} axis_sensor_data_t;

typedef struct {
  float x;
  float y;
  float z;
} imu_angles_deg_t;

typedef struct {
  float x;
  float y;
  float z;
} imu_offsets_t;

typedef struct {
  imu_enum_t rawData;
  axis_sensor_data_t accel;
  axis_sensor_data_t gyro;
  imu_angles_deg_t angles;
  imu_angles_deg_t anglesAtan2;
  imu_offsets_t gyroOffsets;
  unsigned long prevTime;
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
    void getImu(void);
    void getAccel(void);
    void getGyro(void);
    void getAngles(unsigned long timeDiff);
    float correctAbsAngle(float angle);
    float AbsAngleToAtan2(float angle);
    
    //attributes
    imu_filter_model_t model;
    IMUduino_AG imu; 
};

#endif // IMUFilter_h




