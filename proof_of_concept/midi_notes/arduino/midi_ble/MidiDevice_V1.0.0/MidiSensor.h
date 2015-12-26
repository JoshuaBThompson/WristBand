/*
MidiSensor.h developed by jbthompson.eng@gmail.com
Date Created: 12/22/2015
*/

#ifndef MidiSensor_h
#define MidiSensor_h

#include "Arduino.h"
#include "ImuFilter.h"
#include "MotionFilter."
#include "MidiSensorModel.h"
#include "QueueList.h"


class MidiSensor
{
  public:
    //Methods
    MidiSensor(void);
    void init(void);
    void initModel(void);
    void reset(void);
    
    //attributes
    // create a queue of bool for FIFO of midi data
    QueueList <midi_event_t> midiEventQueue;
    sensor_model_t model;
    MotionFilter motionFilter; //wrapper around beat and rotation filter
    ImuFilter imuFilter; //gyro and accelerometer and magnetometer data
};

#endif // MidiSensor_h


