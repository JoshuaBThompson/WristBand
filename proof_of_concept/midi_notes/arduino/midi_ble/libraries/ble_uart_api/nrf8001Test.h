#if ARDUINO >= 100
#include "Arduino.h"
#else
#include "WProgram.h"
#endif
#include "lib_aci.h"
#include "aci_setup.h"
#include "uart_over_ble.h"

#ifndef _nrf8001Test_H_
#define _nrf8001Test_H_


/*
 Used to test the UART TX characteristic notification
 */
static uint8_t         uart_buffer[20];
static uint8_t         uart_buffer_len = 0;
static uint8_t         dummychar = 0;
static uart_over_ble_t uart_over_ble;

//aci data and event structures
// aci_struct that will contain
// total initial credits
// current credit
// current state of the aci (setup/standby/active/sleep)
// open remote pipe pending
// close remote pipe pending
// Current pipe available bitmap
// Current pipe closed bitmap
// Current connection interval, slave latency and link supervision timeout
// Current State of the the GATT client (Service Discovery)
// Status of the bond (R) Peer address
static struct aci_state_t aci_state;

//used in getStatus for all event opcodes
static aci_evt_t * aci_evt;

/*
 Temporary buffers for sending ACI commands
 */
static hal_aci_evt_t  aci_data;
//static hal_aci_data_t aci_cmd;







class nrf8001Test {
public:
    //public methods
    uint8_t * getDeviceVersion(void);

    void setDeviceVersion(uint8_t pipe);
    
    void configureDevice(void);
    
    void init(void);
    
    void setupPins(void);
    
    void loadGattProfile(void);
    
    void setDeviceSetupRequired(void);
    
    void deviceSetup(void);
    
    void handleDeviceStandby(void);
    
    void reportCmdRspError(void);
    
    void requestDeviceVersion(void);
    
    void sayHello(uint8_t pipe);
    
    void changeTimingWithPipe(uint8_t pipe);
        
    void setTiming(uint8_t pipe, uint8_t pipe_size);
    
    void disconnectEvent(void);
        
    void dataCreditEvent(void);
    
    void pipeErrorEvent(void);
    
    void hwErrorEvent(void);
    
    bool getStatus(void);
    
    void startAdv(void);
    
    bool sendData(uint8_t pipe, uint8_t *buffer, uint8_t buffer_len);
    
    void receiveData(uint8_t pipe, aci_evt_t * aci_evt, uint8_t * uart_buffer, uint8_t * uart_buffer_len);
    
    void disconnectDevice(void);
        
    void handleEvents(void);
    
    void parseMIDItoAppleBle(uint8_t pipe, int noteType);

    
    
    //pulic members
    int test;
    bool setup_required = false;
    bool timing_change_done  = false;
    struct status_s {
        int connected;
        int advertising;
        int error;
        int data_available;
    } status;
};

#endif

