/*
MidiServer.h developed by jbthompson.eng@gmail.com
Date Created: 12/22/2015
*/

#ifndef MidiServer_h
#define MidiServer_h

#include "Arduino.h"
#include "MidiController.h"
#include "BeanBle.h"

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
} rx_cmd_args_t;

typedef enum {BYTE_TYPE, INT_TYPE, FLOAT_TYPE} rx_cmd_types_t;

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
    void handleMidiEvents(void);
    void handleEvents(void);
    void updateState(void); 
    void sendState(void); 
    bool parseCmdFromRxBuffer(uint8_t * sourceBuffer);
    void rxCmdCallback(rx_cmd_t * cmd);
    void cpyBufferStartEnd(uint8_t * sourceBuffer, uint8_t * cmdBuffer, int startIndex, int endIndex);
    void getCmdArgs(rx_cmd_t * cmd);
    uint8_t * getCmdParamsFromBuff(uint8_t * buff, int maxLen, uint8_t delim, int param);
    void sendFullMidiEvent(midi_event_t event);
    void sendRunningMidiEvent(midi_event_t event);
    void initBle(void);
    
    //Variables
    int testCount;
    midi_event_t midiEvent;
    midi_event_t prevMidiEvent;
    BeanBle * ble;  //lightblue bean bluetooth api
    rx_cmd_t rxCmd;
};

#endif // MidiServer_h


