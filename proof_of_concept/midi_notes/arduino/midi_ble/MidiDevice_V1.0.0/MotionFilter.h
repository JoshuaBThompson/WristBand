/*
MotionFilter.h developed by jbthompson.eng@gmail.com
Date Created: 12/22/2015
*/

#ifndef MotionFilter_h
#define MotionFilter_h

#include "Arduino.h"
#include "IMUFilter.h"
#include "BeatFilter.h"
#include "RotationFilter.h"

typedef struct {
  bool beat;
  int angleDeg;
  float angleRad;
} motion_filter_model_t;

class MotionFilter
{
  public:
    //Methods
    MotionFilter(void);
    void init(void);
    void reset(void);
    void updateState(void);
    
    //attributes
    motion_filter_model_t model;
    IMUFilter imuFilter;
    BeatFilter beatFilter; //generates data used to deterime if beat motion happened
    RotationFilter rotationFilter; //calculates rotation about an axis of device using gravity x, y and z values for accelerometer 
};

#endif // MotionFilter_h


