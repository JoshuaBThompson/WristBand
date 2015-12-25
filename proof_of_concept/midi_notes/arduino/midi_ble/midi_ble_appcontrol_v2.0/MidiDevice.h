/*
MidiDevice.h developed by jbthompson.eng@gmail.com
Date Created: 12/22/2015
*/

#ifndef MidiDevice_h
#define MidiDevice_h

#include "Arduino.h"
#include "MidiProtocol.h"
#include "MidiDeviceCmds.h"

class MidiDevice: MidiDeviceCmds
{
  public: 
    //Methods
    MidiDevice(void);
    void handleBleEvents(void);
    void updateState(void); 
    void sendState(void); 
    
    //Variables
};

#endif // FilterMotion_h
