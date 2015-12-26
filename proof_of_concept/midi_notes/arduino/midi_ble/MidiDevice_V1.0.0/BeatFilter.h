/*
BeatFilter.h developed by jbthompson.eng@gmail.com
Date Created: 12/22/2015
*/

#ifndef BeatFilter_h
#define BeatFilter_h

#include "Arduino.h"

//Motion Types
#define ACCELMOTION 0
#define GYROMOTION 1


// -----------------filter constants for Acceleration beat analysis-----------------

//Constants for determining when motion constitutes a beat
#define MinDiff             5000
#define MinSum              5000
#define MinFalling         -7000
#define CatchFalling       -10000

//Max samples that can be used to generate a beat
#define MaxSamples     15


/*********MotionFilter Struct
 * Defines structure of beatFilter and rotationFilter objects
***********/

//beat filter params
typedef struct {
  //beat params and coefficients
  int minDiff;
  int minSum;
  int minFalling;
  int catchFalling;
  int maxSamples;

  //used to calc beat
  unsigned int samples;
  long int x1, x0, xsum, diff;
  bool rising, falling, beat;
  
} beat_filter_model_t;




class BeatFilter
{
  public:
    
    //Methods
    BeatFilter(void);
    void reset(void);
    void init(void);
    void setX0(long int x);
    void setX1(long int x);
    bool isBeat(long int x);

    //Attributes
    beat_filter_model_t model;
};

#endif // BeatFilter_h


