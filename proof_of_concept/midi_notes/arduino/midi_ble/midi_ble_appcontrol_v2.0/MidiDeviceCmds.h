/*
MidiDevice.h developed by jbthompson.eng@gmail.com
Date Created: 12/22/2015
*/

#ifndef MidiDeviceCmds_h
#define MidiDeviceCmds_h

#include "Arduino.h"
#include "nrf8001.h"
#include "services.h"
#include "IMUduino.h"
#include "FilterMotion.h"
#include "MidiProtocol.h"
#include "MidiDeviceState.h"

struct CmdStruct {
  char cmdID;
  char * cmdParams[8];
};

class MidiDeviceCmds
{
  public:
    
    //Methods
    MidiDeviceCmds(void);
    void init(void);
    void reset(void);
    bool parseCmdFromRxBuffer(const char * rxBuffer, cmdStruct * cmd);
    void cmdCallback(CmdStruct * cmd);
    void changeNoteChannel(char channel);
    void changeNoteNumber(char number);
    void changeNoteMode(char modeNumber);
    void changeNoteVelocity(char velocity);
    void changeMode(char channel);
    void changeCCFunction(char functionNumber);
    void changeCCSensor(char sensorNumber);
    void changeFilterAverageCount(char averageCount);
    void changeFilterMaxCount(char maxCount);
    void changeFilterMaxAmp(char maxAmp);
    void changeButtonFunction(char functionNumber);
    
    //attributes
    MidiDeviceStateStruct * midiDeviceState;
    CmdStruct * cmd;
    MotionFilter motionFilter; //filters imu data to determine if motion constitutes a beat / note
    IMUduino imu; //gyro and accelerometer and magnetometer (todo: get rid of magnetometer)
    nrf8001 ble;  //nrf8001 bluetooth low energy module
    MidiProtocol midiProtocol; //contains methods to generate/parse communication protocol message
};

#endif // MidiDeviceCmds_h


