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
  
  if(eventReady){
    //todo: ?
  }
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
 * Send up to 20 bytes of data
 */
bool BeanBle::sendData(uint8_t * dataBuffer, uint8_t bufferLen)
{
    bool sendStatus = false;
    
    //todo: ?? send data with bean
    Serial.println("Sending data");
    
    return sendStatus;
}

/*
 * Get any incoming data from the ble device
 */
void BeanBle::receiveData(void){
    //ex: pipe = PIPE_UART_OVER_BTLE_UART_RX_RX
    clearRxBuffer(); 
    //todo: get data from bean ble
  
    status.rxEvent = true;
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
    
    // We enter the if statement only when there is a ACI event available to be processed
    if (getStatus())
    {
      //todo: ?
    }
    else
    {
        //todo: ?
        
    }
    
}

    










