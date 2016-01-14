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
#define ARG_BUFF_MAX_LEN  8

//rx cmd parsing
#define FIRST_RX_CMD_HEADER_INDEX 0
#define RX_CMD_NUMBER_INDEX 1
#define CMD_TYPE_INDEX  2
#define RX_CMD_ARGS_START_INDEX 3
#define FIRST_RX_CMD_HEADER '!'
#define LAST_RX_CMD_HEADER '!'
#define RX_CMD_DELIM  ','


typedef union {
  byte byteValue;
  int     intValue;
  float   floatValue;
  uint8_t buffValue[ARG_BUFF_MAX_LEN];
} rx_cmd_args_t;

typedef enum {BYTE_TYPE, INT_TYPE, FLOAT_TYPE, BUFF_TYPE} rx_cmd_types_t;

typedef struct {
  uint8_t cmdBuffer[CMD_BUFF_MAX_LEN];
  uint8_t number;
  rx_cmd_types_t dataType;
  rx_cmd_args_t args;
  bool valid;
} rx_cmd_t;


//-------------Server Class------------------------------

class MidiServer: public MidiController
{
  public: 
    //Methods
    MidiServer(void);
    void handleBleEvents(void);
    void updateState(void); 
    void sendState(void); 
    bool parseCmdFromRxBuffer(uint8_t * sourceBuffer, rx_cmd_t * cmd);
    void RxCmdCallback(rx_cmd_t * cmd);
    void cpyBufferStartEnd(uint8_t * sourceBuffer, uint8_t * cmdBuffer, int startIndex, int endIndex);
    
    //Variables
    Nrf8001 ble;  //nrf8001 bluetooth low energy module
    rx_cmd_t rxCmd;
};

#endif // MidiServer_h

