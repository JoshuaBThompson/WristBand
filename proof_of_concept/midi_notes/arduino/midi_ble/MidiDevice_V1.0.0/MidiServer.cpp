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
      bool cmdAvailable = parseCmdFromRxBuffer(ble.status.rxBuffer);
      if(cmdAvailable){
        RxCmdCallback(&rxCmd);
      }
   }

   //clear events?
   
}


void MidiServer::cpyBufferStartEnd(uint8_t * sourceBuffer, uint8_t * destBuffer, int startIndex, int endIndex){
  for(int i = startIndex; i<=endIndex; i++){
    destBuffer[i] = sourceBuffer[i];
  }
}
/*
 * User can send cmd request through the rx characteristic instead of using individual characteristic changes (note change, mode change...etc)
 * Ex: to change note number 1 to 65: rx cmd would be: "!,0,1,65,!" where change note cmd has id 0 and params 1 and 65 to indicate note to change and it's value
 * Places params in cmd buffer
 */
bool MidiServer::parseCmdFromRxBuffer(uint8_t * sourceBuffer){
  bool cmdReady = false;
  cpyBufferStartEnd(sourceBuffer, rxCmd.cmdBuffer, 0, CMD_BUFF_MAX_LEN);
  getCmdArgs(&rxCmd);
  if(rxCmd.valid){
    cmdReady = true;
  }

  return cmdReady;
}

/*
 * Get args from cmd buffer
 */
void MidiServer::getCmdArgs(rx_cmd_t * cmd){
  //'!,0,1,230.0,!' is a typical cmd: 0 is cmd num, 1 is cmd data type, 230.0 is arg value
  uint8_t c;
  uint8_t * firstHeaderPtr;
  uint8_t * cmdNumPtr;
  uint8_t * dataTypePtr;
  uint8_t * cmdArgPtr;
  uint8_t * lastHeaderPtr;
  
  firstHeaderPtr = getCmdParamsFromBuff(cmd->cmdBuffer,CMD_BUFF_MAX_LEN, RX_CMD_DELIM, 0);
  cmdNumPtr = getCmdParamsFromBuff(cmd->cmdBuffer,CMD_BUFF_MAX_LEN, RX_CMD_DELIM, 1);
  dataTypePtr = getCmdParamsFromBuff(cmd->cmdBuffer,CMD_BUFF_MAX_LEN, RX_CMD_DELIM, 2);
  cmdArgPtr = getCmdParamsFromBuff(cmd->cmdBuffer,CMD_BUFF_MAX_LEN, RX_CMD_DELIM, 3);
  lastHeaderPtr = getCmdParamsFromBuff(cmd->cmdBuffer,CMD_BUFF_MAX_LEN, RX_CMD_DELIM, 4);
  if(firstHeaderPtr && cmdNumPtr && dataTypePtr && cmdArgPtr && lastHeaderPtr){
    cmd->valid = true;
  }
  else{
    cmd->valid = false;
    return;
  }
 cmd->number = (uint8_t)cmdNumPtr[0] - 48;
 cmd->dataType = (rx_cmd_types_t)((uint8_t)dataTypePtr[0] - 48);
 switch(cmd->dataType){
  case BYTE_TYPE:
    cmd->args.byteValue = (byte)cmdArgPtr[0]; //only one char - for example: 'C' or '2'.... but not '56' since that is two characters '5' and '6'
    break;
  case INT_TYPE:
    cmd->args.intValue = atoi((char *)cmdArgPtr);
    break;
  case FLOAT_TYPE:
    cmd->args.floatValue = atof((char *)cmdArgPtr);
    break;
  default:
    break;
}

  
  
  
}

/*
 * parse out cmd params from buffer with deliminator
 */
uint8_t  * MidiServer::getCmdParamsFromBuff(uint8_t * buff, int maxLen, uint8_t delim, int param){
        uint8_t tempParamBuff[maxLen];
        int paramNum = 0;

        uint8_t * ptr;
        int len = 0;
        for(int i = 0; i<maxLen; i++){
         if(buff[i] == delim || buff[i] == '\0'){
         //got parameter, now point to it

        if(paramNum==param){
        tempParamBuff[len] = '\0'; //null char to end param buffer
        len++;
        ptr = (uint8_t *)malloc(len); //get memory for len size buffer and point to it
        for(int j=0; j<len; j++){ptr[j] = tempParamBuff[j];}
        return ptr;
        }
        paramNum++; //incrmenet to the next param number
        len = 0; //reset
        if(buff[i]=='\0'){
                ptr=NULL;
                return ptr;
        }
        }
        else
        {
        tempParamBuff[len] = buff[i];
        len++;
        }
 }
return ptr;
}



/*
 * cmd callback 
 */
void MidiServer::RxCmdCallback(rx_cmd_t * cmd){
  bool valid = cmd->valid;
  uint8_t number = cmd->number;

  //call cmd
  
  //reset valid
  cmd->valid = false;
  
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








