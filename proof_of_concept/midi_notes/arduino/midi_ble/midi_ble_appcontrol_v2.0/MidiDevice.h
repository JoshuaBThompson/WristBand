/*
MidiDevice.h developed by jbthompson.eng@gmail.com
Date Created: 12/22/2015
*/

#ifndef MidiDevice_h
#define MidiDevice_h

#include "Arduino.h"
#include "FilterMotion.h"
#include "IMUduino.h"
#include "nrf8001.h"
#include "CommProtocol.h"

class MidiDevice
{
  public:
    
    //Methods
    MidiDevice(void);
    
    //Variables
    MotionFilter motionFilter; //filters imu data to determine if motion constitutes a beat / note
    IMUduino imu; //gyro and accelerometer and magnetometer (todo: get rid of magnetometer)
    nrf8001 ble;  //nrf8001 bluetooth low energy module
    CommProtocol commProtocol; //contains methods to generate/parse communication protocol message
    
};


#endif // FilterMotion_h


