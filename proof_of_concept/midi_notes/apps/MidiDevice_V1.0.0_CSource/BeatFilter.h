/*
 BeatFilter.h developed by jbthompson.eng@gmail.com
 Date Created: 12/22/2015
 */

#ifndef BeatFilter_h
#define BeatFilter_h

#include "IMUFilter.h"
#include "Common.h"

//Motion Types - include from Common.h
//typedef enum {ACCEL, GYRO, MAG} sources_t;
//typedef enum {X, Y, Z} axis_t;

#define AXIS_COUNT  3


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
    
    //variables that are updated often
    sources_t source;
    axis_t axis; //X, Y or Z
    int axisValues[AXIS_COUNT];
    unsigned int samples;
    long int x1, x0, xSum, diff;
    bool rising, falling, beat;
    
} beat_filter_model_t;




class BeatFilter
{
public:
    
    //Methods
    BeatFilter(IMUFilter * filterPtr, bool isChild);
    void reset(void);
    void init(void);
    void initSamples(void);
    void setX0(long int x);
    void setX1(long int x);
    bool isBeat(long int x);
    void updateState(void);
    void updateAxisValues(void);
    void setMotionSource(char motionNumber);
    void setAxisSource(char axisNumber);
    
    //Attributes
    IMUFilter * imuFilter;
    beat_filter_model_t model;
    bool child; //determine if beatFilter class will update imu data or if parent class will
};

#endif // BeatFilter_h



