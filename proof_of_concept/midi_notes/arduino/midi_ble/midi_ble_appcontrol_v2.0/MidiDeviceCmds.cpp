/*
MidiDevice.cpp
Author: jbthompson.eng@gmail.com
Date Created: 12/22/2015
Desc: Main object that is responsible for parsing motion data to generate midi messages and send them over bluetooth to a user iphone/mac
      Can also receives cmd over the uart ble service
*/


#include <inttypes.h>
#include <stdint.h>
#include "MidiDeviceCmds.h"

/*
 * Constructor
*/
MidiDeviceCmds::MidiDeviceCmds(void) {
  cmd = (CmdStruct *)malloc(sizeof(cmd));
  midiDeviceState = (MidiDeviceStateStruct *)malloc(sizeof(midiDeviceState));
  motionFilter = MotionFilter();
  imu = IMUduino();
  ble = nrf8001();
  midiProtocol = MidiProtocol();

  //reset variables
  reset();
  
}


/*
 * Reset MidiDevice attributes to defaults
*/
void MidiDeviceCmds::reset(void){
  
}

/*
 * Init MidiDevice by 
*/
void MidiDeviceCmds::init(void){
  //init objects
  motionFilter.init();
  imu.init();
  ble.init();
  midiProtocol.init();
  //todo: init what?
  
}

/*
 * Parse cmd id and params for rx buffer and return true if valid cmd
*/
bool MidiDeviceCmds::parseCmdFromRxBuffer(const char * rxBuffer, cmdStruct * cmd){
  //expected cmd message: "cmdID:arg1,arg2...argN\n" where cmdID = 0 - number of cmd functions
  char msgDelim = rxBuffer[1]; 
  char msgEnd = rxBuffer[MAX_CMD_LEN];
  bool cmdAvailable = false;
  if(msgDelim == CMD_MSG_DELIM_CHAR && msgEnd == CMD_MSG_END_CHAR){
    cmdAvailable = true;
    cmd->cmdID = rxBuffer[0];
    strncpy(cmd->cmdParams, &rxBuffer[2], MAX_PARAMS_LEN];
  }

return cmdAvailable;
}

/*
 * Run cmd using cmd lookup table based on id
*/
void MidiDeviceCmds::cmdCallback(CmdStruct * cmd){
  switch(cmd->cmdID){
    case CHANGE_NOTE_CHANNEL_ID:
    changeNoteChannel(cmd->cmdParams[0]);
    break; 
    
    case CHANGE_NOTE_NUMBER_ID:
    changeNoteNumber(cmd->cmdParams[0]);
    break;
    
    case CHANGE_NOTE_MODE_ID:
    changeNoteMode(cmd->cmdParams[0]);
    break;
    
    case CHANGE_NOTE_VELOCITY_ID:
    changeNoteVelocity(cmd->cmdParams[0]);
    break;
    
    case CHANGE_MODE:
    changeNoteMode(cmd->cmdParams[0]);
    break;
    
    case CHANGE_CC_FUNCTION_ID:
    changeCCFunction(cmd->cmdParams[0]);
    break;
    
    case CHANGE_CC_SENSOR_ID:
    changeCCSensor(cmd->cmdParams[0]);
    break;
    
    case CHANGE_FILTER_AVERAGE_COUNT_ID:
    changeFilterAverageCount(cmd->cmdParams[0]);
    break;
    
    case CHANGE_FILTER_MAX_COUNT_ID:
    changeFilterMaxCount(cmd->cmdParams[0]);
    break;
    
    case CHANGE_FILTER_MAX_AMP_ID:
    changeFilterMaxAmp(cmd->cmdParams[0]);
    break;
    
    case CHANGE_BUTTON_FUNCTION_ID:
    changeButtonFunction(cmd->cmdParams[0]);
    break;
    
    default:
    break;
  }
}

void MidiDeviceCmds::changeNoteChannel(char channel){
  midiDeviceState->note.channel = channel;
}

void MidiDeviceCmds::changeNoteNumber(char number){
  midiDeviceState->note.number = number;
  
}

void MidiDeviceCmds::changeNoteMode(char modeNumber){
  midiDeviceState->note.mode = modeNumber;
}

void MidiDeviceCmds::changeNoteVelocity(char velocity){
  midiDeviceState->note.velocity = velocity;
}

void MidiDeviceCmds::changeMode(char modeNumber){
  midiDeviceState->mode.number = modeNumber;
}

void MidiDeviceCmds::changeCCFunction(char functionNumber){
  midiDeviceState->cc.number = functionNumber;
}

void MidiDeviceCmds::changeCCSensor(char sensorNumber){
  midiDeviceState->cc.sensor = sensorNumber;
}

void MidiDeviceCmds::changeFilterAverageCount(char averageCount){
  midiDeviceState->filter.averageCount = averageCount;
}

void MidiDeviceCmds::changeFilterMaxCount(char maxCount){
  midiDeviceState->filter.maxCount = maxCount;
}

void MidiDeviceCmds::changeFilterMaxAmp(char maxAmp){
  midiDeviceState->filter.maxAmp = maxAmp;
}

void MidiDeviceCmds::changeButtonFunction(char functionNumber){
  midiDeviceState->button.number = functionNumber;
}

