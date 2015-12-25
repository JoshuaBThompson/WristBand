/*
MidiDevice.cpp
Author: jbthompson.eng@gmail.com
Date Created: 12/22/2015
Desc: Main object that is responsible for parsing motion data to generate midi messages and send them over bluetooth to a user iphone/mac
      Can also receives cmd over the uart ble service
*/


#include <inttypes.h>
#include <stdint.h>
#include "MidiDevice.h"

/*
 * Constructor
 */
MidiDevice::MidiDevice(void):MidiDeviceCmds() {

}


/*
 * Check bluetooth communication rx buffer for cmds or error, handle events or cmds
 */
void MidiDevice::handleBleEvents(void){

  //check ble event states, see if errors, messages received, timing request changes...etc
  //if received message, ble will put in rxBuffer
   ble.handleEvents();

   //check errors?
   if(ble.errorEvent){
   }
   //check messages if any and copy to cmd buffer
   if(ble.rxEvent){
      bool cmdAvailable = parseCmdFromRxBuffer(ble.rxBuffer, cmd);
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
void MidiDevice::updateState(void){
  
}

/*
 * If note valid sends midi note, if button pressed send midi message (varies), send sensor data?
 */
void MidiDevice.sendState(void){
  
}





