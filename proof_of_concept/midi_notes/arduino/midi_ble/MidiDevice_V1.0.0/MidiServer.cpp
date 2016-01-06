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
  initCallbacks();
}


void MidiServer::initCallbacks(void){
  //todo?
  callbackPtrList[0] = changeNoteNumber;
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
      bool cmdAvailable = parseCmdFromRxBuffer(ble.status.rxBuffer, status.cmd);
      if(cmdAvailable){
        cmdCallback(status.cmd);
      }
   }

   //clear events?
   
}

/*
 * User can send cmd request through the rx characteristic instead of using individual characteristic changes (note change, mode change...etc)
 * Ex: to change note number 1 to 65: rx cmd would be: "!,0,1,65,!" where change note cmd has id 0 and params 1 and 65 to indicate note to change and it's value
 * Places params in cmd buffer
 */
bool MidiServer::parseCmdFromRxBuffer(uint8_t * sourceBuffer, uint8_t * cmdBuffer){
  bool cmdReady = false;
  //todo: parse here
  return cmdReady;
}

/*
 * cmd callback 
 */
void MidiServer::cmdCallback(uint8_t * cmdBuffer){
  int cmdID = cmdBuffer[0];
  if(cmdID < CALLBACK_COUNT){
    //todo: make ptr callback work!
    callbackPtrList[cmdID](cmdBuffer); //run cmd callback
  }
}

/*
 * Update values from the accelerometer / gyro, note #, rotation angle, channel #, mode, button output (cc...etc)
 */
void MidiServer::updateState(void){
  
}

/*
 * If note valid sends midi note, if button pressed send midi message (varies), send sensor data?
 */
void MidiServer::sendState(void){
  
}

//--------------Callbacks--------------------------------

void changeNoteNumber(uint8_t * cmdBuffer){
  //todo?
}






