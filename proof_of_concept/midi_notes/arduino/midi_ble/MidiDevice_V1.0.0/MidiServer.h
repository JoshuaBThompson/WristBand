/*
MidiServer.h developed by jbthompson.eng@gmail.com
Date Created: 12/22/2015
*/

#ifndef MidiServer_h
#define MidiServer_h

#include "Arduino.h"
#include "MidiController.h"
#include "services.h"
#include "nrf8001.h"

class MidiServer: MidiController
{
  public: 
    //Methods
    MidiDevice(void);
    void handleBleEvents(void);
    void updateState(void); 
    void sendState(void); 
    
    //Variables
    Nrf8001Ble ble;  //nrf8001 bluetooth low energy module
};

#endif // MidiServer_h
