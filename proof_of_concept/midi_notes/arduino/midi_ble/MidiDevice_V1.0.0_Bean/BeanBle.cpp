#include "BeanBle.h"

/*
 * BeanBle Constructor
 */
BeanBle::BeanBle(void){
  
}

/*
 * Execute any init methods
 */
void BeanBle::init(){
    //enable midi bluetooth profile
    BeanMidi.enable();
    //init variables
    initStatus();
}

/*
 * Initialize the status structure used by the entire class
 */
void BeanBle::initStatus(void){
  status.connected = false;
  status.advertising = false;
  status.errorEvent = false;
  status.rxMaxLen = RX_MAX_LEN;
  status.rxBufferLen=0;
  status.rxEvent = false;
  status.dataAvailable = false;
  for(int i = 0; i<RX_MAX_LEN; i++){
    status.rxBuffer[i] = 0;
  }

}

/*
 * Set the connected attribute of this class...and do something else? maybe...
 */

void BeanBle::setConnected(void){
  status.connected = true;
}

/*
 * Disconnection event handler
 */
void BeanBle::disconnectEvent(void){
    status.connected = 0;
    status.advertising = 0;
    startAdv();
}


/*
 * Get status of the bluetooth low energy chip, is a message ready?
 */
bool BeanBle::getStatus(void){
  bool eventReady = false;
  //todo: is there a ready event for the bean ble chip?
  receiveUARTData(); //updates the rxEvent if received data on the bluetooth uart characteristic
  eventReady = status.rxEvent;
  if(eventReady){
  }
  Serial.println(lastScratch.length);
  return eventReady;
}


/*
 * Tell the ble device to start advertising...might not be necessary
 */
void BeanBle::startAdv(void){
  
    //todo: ? do we need to manually set the bean ble to advertise?
    status.advertising = true;    
}

/*
 * Send midi messages
 */

bool BeanBle::sendMidiMessage(uint8_t statusByte, uint8_t dataByte1, uint8_t dataByte2){
  int sent = BeanMidi.sendMessage(statusByte, dataByte1, dataByte2);
  return (bool)sent;
}
  

/*
 * Send up to 20 bytes of data
 */
bool BeanBle::sendUARTData(uint8_t * dataBuffer, uint8_t bufferLen)
{
    bool sendStatus = false;
    
    //todo: ?? send data with bean
    Serial.println("Sending data");
    
    return sendStatus;
}

/*
 * Get any incoming data from the ble device
 */
void BeanBle::receiveUARTData(void){ 
    //todo: get data from bean ble scratch characteristic 1 (for now just use 1)
    ScratchData rxScratch = Bean.readScratchData(UART_NUMBER);
    bool match = compareScratch(&rxScratch, &lastScratch);
    if(!match){
      status.rxEvent = true;
      lastScratch = rxScratch;
      clearRxBuffer();
      for(int i = 0; i<rxScratch.length; i++){
        status.rxBuffer[i] = rxScratch.data[i];
      }
    }
   else{
    status.rxEvent = false;
   }
}

/*
 * Compare prev and current bean uart data, to see if new data received
 */

 bool BeanBle::compareScratch(ScratchData *scratch1, ScratchData *scratch2) {
  // If they contain different numbers of bytes, they can't be equal,
  // so return false
  if (scratch1->length != scratch2->length) {
    return false;
  }

  // Compare each byte in order and return false if two bytes don't match
  for (int i = 0; i < scratch1->length; i++) {
    if (scratch1->data[i] != scratch2->data[i]) {
      return false;
    }
  }

  // If we've gotten this far, every byte in both ScratchData objects matches
  return true;
}

/*
 * Clear the receive buffer 
 */
void BeanBle::clearRxBuffer(){
  for(int i=0; i<status.rxBufferLen; i++){
    status.rxBuffer[i] = 0;
  }
}

/*
 * Disconnect the ble device
 */
void BeanBle::disconnectDevice(void){
    //todo: ?
}

/*
 * Get any ble rx, error or other events and handle them...
 */
void BeanBle::handleEvents(void){
    
    // We enter the if statement only when there an rxEvent from receiving data
    if (getStatus())
    {
      //todo: ?
      //for now getStatus just checks if data is available / received from the client, and updates the rxBuffer and rxEvent status
      //midiserver can read the rxEvent to see if new data is available on the rxBuffer
    }
    else
    {
        //todo: ?
        
    }
    
}

    










