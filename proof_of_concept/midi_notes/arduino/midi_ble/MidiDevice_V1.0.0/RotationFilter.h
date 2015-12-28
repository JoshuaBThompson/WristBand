/*
RotationFilter.h developed by jbthompson.eng@gmail.com
Date Created: 12/22/2015
*/

#ifndef RotationFilter_h
#define RotationFilter_h


#include "Arduino.h"
#include "IMUFilter.h"

#define AXIS_COUNT  3 //x, y and z (maybe)
#define MAX_AVERAGE_COUNT 12 //max samples to average the rotation angle (may only use a portion of these, which will lead to quicker but less accurate rotation calc)

/******RotationFilter data model struct
 * Contains struct of axis type, angle in deg and radians
**********/

typdef enum {X, Y, Z} rotation_axis_t;

typedef struct {
  rotation_axis_t axis;
  int angleDeg;
  int angleRad;
  rotation_axis_t aboutAxis;
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


