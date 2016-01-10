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

#define CMD_BUFF_MAX_LEN  20
#define CALLBACK_COUNT  1

typedef struct {
  uint8_t cmd[CMD_BUFF_MAX_LEN];
} status_t;

typedef void (*callbackPtr_t)(uint8_t *); //function ptr with char * argument and void return type
//--------------Callbacks--------------------------------

void changeNoteNumber(uint8_t * cmdBuffer);


//-------------Server Class------------------------------

class MidiServer: public MidiController
{
  public: 
    //Methods
    MidiServer(void);
    void handleBleEvents(void);
    void updateState(void); 
    void sendState(void); 
    bool parseCmdFromRxBuffer(uint8_t * sourceBuffer, uint8_t * cmdBuffer);
    void cmdCallback(uint8_t * cmdBuffer);
    void initCallbacks(void);
    //callbacks
    
    //Variables
    Nrf8001 ble;  //nrf8001 bluetooth low energy module
    status_t status;
    callbackPtr_t callbackPtrList[CALLBACK_COUNT]; //list of function pointers
    callbackPtr_t testPtr;
};

#endif // MidiServer_h

