#ifndef _BeanBle_H_
#define _BeanBle_H_

#define RX_MAX_LEN  20
#define UART_NUMBER 1 //bean has characteristics for uart i/o (1,2,3,4,5)

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
    
    bool sendUARTData(uint8_t * dataBuffer, uint8_t bufferLen);
    
    void receiveUARTData(void);

    bool compareScratch(ScratchData *scratch1, ScratchData *scratch2);

    bool sendMidiMessage(uint8_t statusByte, uint8_t dataByte1, uint8_t dataByte2);
    
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
    //just for lightblue bean
    ScratchData lastScratch;
};

#endif




