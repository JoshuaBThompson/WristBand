/*
MidiServer.h developed by jbthompson.eng@gmail.com
Date Created: 12/22/2015
*/

#ifndef MidiServer_h
#define MidiServer_h

#include "Arduino.h"
#include "MidiController.h"
#include "services.h"
#include "NRF8001Ble.h"

class MidiServer: public MidiController
{
  public: 
    //Methods
    MidiServer(void);
    void handleBleEvents(void);
    void updateState(void); 
    void sendState(void); 
    
    //Variables
    Nrf8001 ble;  //nrf8001 bluetooth low energy module
};

#endif // MidiServer_h
