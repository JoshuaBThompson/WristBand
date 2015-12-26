/*
RotationFilter.h developed by jbthompson.eng@gmail.com
Date Created: 12/22/2015
*/

#ifndef RotationFilter_h
#define RotationFilter_h


#include "Arduino.h"

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
    RotationFilter(void);
    void reset(void);
    void init(void);

    //Variables
    rotation_filter_model_t model;
    
};




#endif // RotationFilter_h


