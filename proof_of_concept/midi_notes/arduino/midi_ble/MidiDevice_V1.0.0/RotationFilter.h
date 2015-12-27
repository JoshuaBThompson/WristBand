/*
RotationFilter.h developed by jbthompson.eng@gmail.com
Date Created: 12/22/2015
*/

#ifndef RotationFilter_h
#define RotationFilter_h


#include "Arduino.h"
#include "IMUFilter.h"

/******RotationFilter data model struct
 * Contains struct of axis type, angle in deg and radians
**********/

typdef enum {X, Y, Z} rotation_axis_t;

typedef struct {
  rotation_axis_t axis;
  int angle_deg;
  int angle_rad;
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


