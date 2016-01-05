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
      bool cmdAvailable = parseCmdFromRxBuffer(ble.status.rxBuffer, cmd);
      if(cmdAvailable){
        cmdCallback(cmd);
      }
   }

   //clear events
   ble.clearEvents();
   
}


/*
 * Update values from the accelerometer / gyro, note #, rotation angle, channel #, mode, button output (cc...etc)
 */
void MidiServer::updateState(void){
  
}

/*
 * If note valid sends midi note, if button pressed send midi message (varies), send sensor data?
 */
void MidiServer.sendState(void){
  
}





