/*
RotationFilter.h developed by jbthompson.eng@gmail.com
Date Created: 12/22/2015
*/

#ifndef RotationFilter_h
#define RotationFilter_h


#include "Arduino.h"
#include "IMUFilter.h"
#include "Common.h"

#define AXIS_COUNT  3 //x, y and z (maybe)
#define MAX_AVERAGE_COUNT 5 //max samples to average the rotation angle (may only use a portion of these, which will lead to quicker but less accurate rotation calc)
#define ACCEL_SCALE_Y (int)16675
#define ACCEL_SCALE_X (int)16675 //need to test and get better value for X
#define ACCEL_SCALE_Z (int)17809
#define YOFFSET (float) 0//-450.0
#define ZOFFSET (float) 0//-450.0
#define XOFFSET (float) 0//-450.0

#define ROTATION_ANGLE_THRESHOLD 0 //deg
#define FIRST_ROTATION  0
#define SECOND_ROTATION 1

//axis_t imported from Common.h
//typedef enum {X, Y, Z} axis_t;
/******RotationFilter data model struct
 * Contains struct of axis type, angle in deg and radians
**********/

typedef struct {
  axis_t axis;
  int angleDeg;
  float angleRad;
  int averageAxis1Buff[MAX_AVERAGE_COUNT];
  int averageAxis2Buff[MAX_AVERAGE_COUNT];
  int accelAxis1Val, accelAxis2Val, accelRefAxisVal; //imu values
  int accelScaleAxis1, accelScaleAxis2;
  float runningAverageAxis1, runningAverageAxis2;
  float axis1Offset, axis2Offset;
  int averageCount; //running count
  int maxAverageCount; //user can use to override MAX_averageCount
  int rotationNumber; //either 0 or 1 depending on the measured angle in deg
  int firstRotation;
  int secondRotation;
  
} rotation_filter_model_t;



/* RotationModel class
 *  
*/

class RotationFilter
{
  public:
    
    //Methods
    RotationFilter(IMUFilter * filterPtr, bool isChild);
    void reset(void);
    void init(void);
    void updateState(void);
    void updateAxisValues(void);
    void setAboutAxis(char axisNumber);
    void updateRotationAngle(void);
    void updateRotationAngleNew(void);
    void initRunningAverage(void);

    //Variables
    rotation_filter_model_t model;
    IMUFilter * imuFilter;
    bool child; //determine if rotationFilter class will update imu data or if parent class will
    
};




#endif // RotationFilter_h


