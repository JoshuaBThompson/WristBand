/*
MidiServer.cpp
Author: jbthompson.eng@gmail.com
Date Created: 12/22/2015
Desc: Main object that is responsible for parsing motion data to generate midi messages and send them over bluetooth to a user iphone/mac
      Can also receives cmd over the uart ble service
*/


#include <inttypes.h>
#include <stdint.h>
#include "MidiServer.h"

/*
 * Constructor
 */
MidiServer::MidiServer(void):MidiController() {
}


/*
 * Check bluetooth communication rx buffer for cmds or error, handle events or cmds
 */
void MidiServer::handleBleEvents(void){

  //check ble event states, see if errors, messages received, timing request changes...etc
  //if received message, ble will put in rxBuffer
   ble.handleEvents();

   //check errors?
   if(ble.status.errorEvent){
   }
   //check messages if any and copy to cmd buffer
   if(ble.status.rxEvent){
      bool cmdAvailable = parseCmdFromRxBuffer(ble.status.rxBuffer, &rxCmd);
      if(cmdAvailable){
        RxCmdCallback(&rxCmd);
      }
   }

   //clear events?
   
}


void MidiServer::cpyBufferStartEnd(uint8_t * sourceBuffer, uint8_t * cmdBuffer, int startIndex, int endIndex){
  for(int i = startIndex; i<endIndex; i++){
    cmdBuffer[i] = sourceBuffer[i];
  }
}
/*
 * User can send cmd request through the rx characteristic instead of using individual characteristic changes (note change, mode change...etc)
 * Ex: to change note number 1 to 65: rx cmd would be: "!,0,1,65,!" where change note cmd has id 0 and params 1 and 65 to indicate note to change and it's value
 * Places params in cmd buffer
 */
bool MidiServer::parseCmdFromRxBuffer(uint8_t * sourceBuffer, rx_cmd_t * cmd){
  bool cmdReady = false;
  cpyBufferStartEnd(sourceBuffer, cmd->cmdBuffer, 0, CMD_BUFF_MAX_LEN);
  //todo: parse here
  char firstHeader = (char)cmd->cmdBuffer[FIRST_RX_CMD_HEADER_INDEX];
  char lastHeader = (char)cmd->cmdBuffer[LAST_RX_CMD_HEADER_INDEX];
  bool validCmdHeader = (firstHeader == "!");
  bool validCmdHeader &= (lastHeader == "!");
  if(!validCmdHeader){
    cmd->valid = false;
    cmdReady = false;
    return cmdReady;
  }
  cmd->number = cmd->cmdBuffer[RX_CMD_NUMBER_INDEX];
  rx_cmd_types_t cmdDataType = (rx_cmd_types_t)cmd->cmdBuffer[CMD_TYPE_INDEX];
  switch(cmdDataType){
    case BYTE_TYPE:
      cmd->cmdType = BYTE_TYPE;
      cmd->args.byteValue = (byte)cmd->cmdBuffer[RX_CMD_ARGS_START_INDEX];
      cmd->valid = true;
      break;
    case INT_TYPE:
      cmd->cmdType = INT_TYPE;
      cmd->args.intValue = (int)((cmd->cmdBuffer[RX_CMD_ARGS_START_INDEX]<<8) + cmd->cmdBuffer[RX_CMD_ARGS_START_INDEX+1]);
      cmd->valid = true;
      break;
    case FLOAT_TYPE:
      cmd->cmdType = FLOAT_TYPE;
      cmd->args.floatValue = (float)((cmd->cmdBuffer[RX_CMD_ARGS_START_INDEX]<<24) + (cmd->cmdBuffer[RX_CMD_ARGS_START_INDEX+1]<<16) + (cmd->cmdBuffer[RX_CMD_ARGS_START_INDEX+2]<<8) + cmd->cmdBuffer[RX_CMD_ARGS_START_INDEX+3]);
      cmd->valid = true;
      break;
    case BUFF_TYPE:
      cmd->cmdType = BUFF_TYPE;
      cmd->args.buffValue = cmd->cmdBuffer[RX_CMD_ARGS_START_INDEX];
      cpyBufferStartEnd(cmd->cmdBuffer, cmd->args.buffValue, RX_CMD_ARGS_START_INDEX, RX_CMD_ARGS_END_INDEX);
      cmd->valid = true;
      break;
    default:
      cmd->valid = false;
      break;
  }
  return cmdReady;
}

/*
 * cmd callback 
 */
void MidiServer::RxCmdCallback(rx_cmd_t * cmd){
  bool valid = cmd.valid;
  uint8_t number = cmd.number;

  //call cmd
  
  //reset valid
  cmd.valid = false;
  
}

/*
 * Update values from the accelerometer / gyro, note #, rotation angle, channel #, mode, button output (cc...etc)
 */
void MidiServer::updateState(void){
  midiSensor.updateState();
}

/*
 * If note valid sends midi note, if button pressed send midi message (varies), send sensor data?
 */
void MidiServer::sendState(void){
  
}








