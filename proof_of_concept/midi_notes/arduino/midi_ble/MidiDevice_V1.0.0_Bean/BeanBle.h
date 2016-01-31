#ifndef _BeanBle_H_
#define _BeanBle_H_

#define RX_MAX_LEN  20

#include "Arduino.h"

class BeanBle {
public:
    //public methods
    BeanBle(void);
    
    void init(void);

    void initStatus(void);
    
    void setConnected(void);
    
    void disconnectEvent(void);
    
    bool getStatus(void);
    
    void startAdv(void);
    
    bool sendData(uint8_t * dataBuffer, uint8_t bufferLen);
    
    void receiveData(void);
    
    void disconnectDevice(void);
        
    void handleEvents(void);
    
    void clearRxBuffer(void);

    
    //pulic members
    struct status_s {
        bool connected;
        bool advertising;
        bool errorEvent;
        uint8_t rxBuffer[RX_MAX_LEN];
        uint8_t rxMaxLen;
        uint8_t rxBufferLen;
        bool rxEvent;
        bool dataAvailable;
    } status;
};

#endif




