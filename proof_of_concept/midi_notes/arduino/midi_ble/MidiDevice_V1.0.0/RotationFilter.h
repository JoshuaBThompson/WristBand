/*
RotationFilter.h developed by jbthompson.eng@gmail.com
Date Created: 12/22/2015
*/

#ifndef RotationFilter_h
#define RotationFilter_h


#include "Arduino.h"
#include "IMUFilter.h"

#define AXIS_COUNT  3 //x, y and z (maybe)
#define MAX_AVERAGE_COUNT 10 //max samples to average the rotation angle (may only use a portion of these, which will lead to quicker but less accurate rotation calc)
#define ACCEL_SCALE_Y (int)16675
#define ACCEL_SCALE_X (int)16675 //need to test and get better value for X
#define ACCEL_SCALE_Z (int)17809
#define YOFFSET (float)-450.0
#define ZOFFSET (float)-450.0
#define XOFFSET (float)-450.0
#define X_AXIS_TYPE 0
#define Y_AXIS_TYPE 1
#define Z_AXIS_TYPE 2
/******RotationFilter data model struct
 * Contains struct of axis type, angle in deg and radians
**********/

typedef struct {
  rotation_axis_t axis;
  int angleDeg;
  int angleRad;
  char aboutAxis;
  int averageAxis1Buff[MAX_averageCount];
  int averageAxis2Buff[MAX_averageCount];
  int accelAxis1Val, accelAxis2Val, accelRefAxisVal; //imu values
  int accelScaleAxis1, accelScaleAxis2;
  float runningAverageAxis1, runningAverageAxis2;
  float axis1Offset, axis2Offset;
  int averageCount; //running count
  int maxAverageCount; //user can use to override MAX_averageCount
  
} rotation_filter_model_t;



/* RotationModel class
 *  
*/

class RotationFilter
{
  public:
    
    //Methods
    RotationFilter(IMUFilter *);
    void reset(void);
    void init(void);
    void updateState(void);

    //Variables
    rotation_filter_model_t model;
    IMUFilter * imuFilter;
    
};




#endif // RotationFilter_h


