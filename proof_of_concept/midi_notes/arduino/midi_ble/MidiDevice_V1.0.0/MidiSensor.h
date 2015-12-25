/*
MidiSensor.h developed by jbthompson.eng@gmail.com
Date Created: 12/22/2015
*/

#ifndef MidiSensor_h
#define MidiSensor_h

#include "Arduino.h"
#include "IMUduino.h"
#include "FilterMotion.h"
#include "MidiSensorModel.h"


class MidiSensor
{
  public:
    //Methods
    MidiSensor(void);
    void init(void);
    void initModel(void);
    void reset(void);
    
    //attributes
    sensor_model_t model;
    MotionFilter motionFilter; //filters imu data to determine if motion constitutes a beat / note
    IMUduino imu; //gyro and accelerometer and magnetometer (todo: get rid of magnetometer)
};

#endif // MidiSensor_h


