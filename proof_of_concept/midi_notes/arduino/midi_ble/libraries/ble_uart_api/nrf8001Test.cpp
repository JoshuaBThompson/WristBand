#include "services.h"
#include "nrf8001Test.h"
#include "lib_aci.h"
#include "aci_setup.h"
#include <stdbool.h>
#include <SPI.h>
#include <EEPROM.h>
#include <avr/sleep.h>
#include <avr/power.h>

#ifdef SERVICES_PIPE_TYPE_MAPPING_CONTENT
static services_pipe_type_mapping_t
services_pipe_type_mapping[NUMBER_OF_PIPES] = SERVICES_PIPE_TYPE_MAPPING_CONTENT;
#else
#define NUMBER_OF_PIPES 0
static services_pipe_type_mapping_t * services_pipe_type_mapping = NULL;
#endif

/* Store the setup for the nRF8001 in the flash of the AVR to save on RAM */
//hal_aci_data_t is data type for ACI command and events
//NB_SETUP_MESSAGES is number of setup messages defined in services.h
//SETUP_MESSAGES_CONTENT is array[NB_SETUP_MESSAGES] = {.....} in services.h
static const hal_aci_data_t setup_msgs[NB_SETUP_MESSAGES] PROGMEM = SETUP_MESSAGES_CONTENT;



uint8_t * nrf8001Test::getDeviceVersion(void){
  return (uint8_t*)&(aci_evt->params.cmd_rsp.params.get_device_version);
}

void nrf8001Test::setDeviceVersion(uint8_t pipe){
  //Store the version and configuration information of the nRF8001 in the Hardware Revision String Characteristic
  //ex: pipe = PIPE_DEVICE_INFORMATION_HARDWARE_REVISION_STRING_SET
        lib_aci_set_local_data(&aci_state, pipe,
        (uint8_t *)&(aci_evt->params.cmd_rsp.params.get_device_version), sizeof(aci_evt_cmd_rsp_params_get_device_version_t));
}


void nrf8001Test::configureDevice(){
    loadGattProfile();
    setupPins();
    init();
}

void nrf8001Test::init(){
    
    //init variables
    setup_required = false;
    timing_change_done = false;
    
    //We reset the nRF8001 here by toggling the RESET line connected to the nRF8001
    //If the RESET line is not available we call the ACI Radio Reset to soft reset the nRF8001
    //then we initialize the data structures required to setup the nRF8001
    //The second parameter is for turning debug printing on for the ACI Commands and Events so they be printed on the Serial
    lib_aci_init(&aci_state, false);
}

void nrf8001Test::setupPins(void){
    
    /*
     Tell the ACI library, the MCU to nRF8001 pin connections.
     The Active pin is optional and can be marked UNUSED
     */
    
    //for imuduino board
    
    aci_state.aci_pins.board_name = BOARD_DEFAULT;
    aci_state.aci_pins.reqn_pin   = 10;
    aci_state.aci_pins.rdyn_pin   = 7;
    aci_state.aci_pins.mosi_pin   = MOSI;
    aci_state.aci_pins.miso_pin   = MISO;
    aci_state.aci_pins.sck_pin    = SCK;
    
    aci_state.aci_pins.spi_clock_divider      = SPI_CLOCK_DIV8;//SPI_CLOCK_DIV8  = 2MHz SPI speed
    //SPI_CLOCK_DIV16 = 1MHz SPI speed
    
    aci_state.aci_pins.reset_pin              = 9;
    aci_state.aci_pins.active_pin             = UNUSED;
    aci_state.aci_pins.optional_chip_sel_pin  = UNUSED;
    
    aci_state.aci_pins.interface_is_interrupt = false; //Interrupts still not available in Chipkit
    aci_state.aci_pins.interrupt_number       = 1;
    
}

void nrf8001Test::loadGattProfile(void){
    if (NULL != services_pipe_type_mapping)
    {
        aci_state.aci_setup_info.services_pipe_type_mapping = &services_pipe_type_mapping[0];
    }
    else
    {
        aci_state.aci_setup_info.services_pipe_type_mapping = NULL;
    }
    aci_state.aci_setup_info.number_of_pipes    = NUMBER_OF_PIPES;
    aci_state.aci_setup_info.setup_msgs         = (hal_aci_data_t*)setup_msgs;
    aci_state.aci_setup_info.num_setup_msgs     = NB_SETUP_MESSAGES;
    
}

void nrf8001Test::setDeviceSetupRequired(void){
    /**
     When the device is in the setup mode
     */
    Serial.println(F("Evt Device Started: Setup"));
    setup_required = true;
}

void nrf8001Test::deviceSetup(void){
    if(setup_required)
    {
        if (SETUP_SUCCESS == do_aci_setup(&aci_state))
        {
            setup_required = false;
        }
    }
}

void nrf8001Test::handleDeviceStandby(void){
    Serial.println(F("Evt Device Started: Standby"));
    //Looking for an iPhone by sending radio advertisements
    //When an iPhone connects to us we will get an ACI_EVT_CONNECTED event from the nRF8001
    if (aci_evt->params.device_started.hw_error)
    {
        Serial.println("HW Error ");
        delay(20); //Handle the HW error event correctly.
    }
    else
    {
        startAdv();
    }
}

void nrf8001Test::reportCmdRspError(void){
  
        //ACI ReadDynamicData and ACI WriteDynamicData will have status codes of
        //TRANSACTION_CONTINUE and TRANSACTION_COMPLETE
        //all other ACI commands will have status code of ACI_STATUS_SCUCCESS for a successful command
        Serial.print(F("ACI Command "));
        Serial.println(aci_evt->params.cmd_rsp.cmd_opcode, HEX);
        Serial.print(F("Evt Cmd respone: Status "));
        Serial.println(aci_evt->params.cmd_rsp.cmd_status, HEX);
}


void nrf8001Test::requestDeviceVersion(void){
    status.connected = 1;
    
    Serial.println(F("Evt Connected"));
    timing_change_done              = false;
    aci_state.data_credit_available = aci_state.data_credit_total;
    
    /*
     Get the device version of the nRF8001 and store it in the Hardware Revision String
     */
    lib_aci_device_version();
}

void nrf8001Test::sayHello(uint8_t pipe){
  char hello[]="JT";
  //ex pipe = PIPE_UART_OVER_BTLE_UART_TX_TX
   sendData(pipe , (uint8_t *)&hello[0], strlen(hello));
   Serial.print(F("Sending :"));
   Serial.println(hello);
}

void nrf8001Test::changeTimingWithPipe(uint8_t pipe){
  //ex: pipe = PIPE_UART_OVER_BTLE_UART_TX_TX
  
  if (lib_aci_is_pipe_available(&aci_state, pipe) && (false == timing_change_done))
    {
        lib_aci_change_timing_GAP_PPCP(); // change the timing on the link as specified in the nRFgo studio -> nRF8001 conf. -> GAP.
        // Used to increase or decrease bandwidth
        timing_change_done = true;
        
    }
}


void nrf8001Test::setTiming(uint8_t pipe, uint8_t pipe_size){
    //ex: pipe = PIPE_UART_OVER_BTLE_UART_LINK_TIMING_CURRENT_SET 
    //    pipe_size = PIPE_UART_OVER_BTLE_UART_LINK_TIMING_CURRENT_SET_MAX_SIZE
    Serial.println(F("setting timing"));
    lib_aci_set_local_data(&aci_state,
                           pipe,
                           (uint8_t *)&(aci_evt->params.timing.conn_rf_interval), /* Byte aligned */
                           pipe_size);
}

void nrf8001Test::disconnectEvent(void){
    Serial.println(F("Evt Disconnected/Advertising timed out"));
    status.connected = 0;
    status.advertising = 0;
    startAdv();
}


void nrf8001Test::dataCreditEvent(void){
    aci_state.data_credit_available = aci_state.data_credit_available + aci_evt->params.data_credit.credit;
}

void nrf8001Test::pipeErrorEvent(void){
    status.error = 1;
    //See the appendix in the nRF8001 Product Specication for details on the error codes
    Serial.print(F("ACI Evt Pipe Error: Pipe #:"));
    Serial.print(aci_evt->params.pipe_error.pipe_number, DEC);
    Serial.print(F("  Pipe Error Code: 0x"));
    Serial.println(aci_evt->params.pipe_error.error_code, HEX);
    
    //Increment the credit available as the data packet was not sent.
    //The pipe error also represents the Attribute protocol Error Response sent from the peer and that should not be counted
    //for the credit.
    if (ACI_STATUS_ERROR_PEER_ATT_ERROR != aci_evt->params.pipe_error.error_code)
    {
        aci_state.data_credit_available++;
    }
}

void nrf8001Test::hwErrorEvent(void){
    status.error = 1;
    Serial.print(F("HW error: "));
    Serial.println(aci_evt->params.hw_error.line_num, DEC);
    
    for(uint8_t counter = 0; counter <= (aci_evt->len - 3); counter++)
    {
        Serial.write(aci_evt->params.hw_error.file_name[counter]); //uint8_t file_name[20];
    }
    Serial.println();
    lib_aci_connect(0/* in seconds, 0 means forever */, 0x0050 /* advertising interval 50ms*/);
    Serial.println(F("Advertising started. Tap Connect on the nRF UART app"));
}

bool nrf8001Test::getStatus(void){
  bool eventReady = lib_aci_event_get(&aci_state, &aci_data);
  if(eventReady){
    aci_evt = &aci_data.evt;
  }
  return eventReady;
}



void nrf8001Test::startAdv(void){
  
  lib_aci_connect(0/* in seconds : 0 means forever */, 0x0050 /* advertising interval 50ms*/);
  Serial.println(F("Advertising started : Tap Connect on the nRF UART app"));
  status.advertising = 1;
    
}

bool nrf8001Test::sendData(uint8_t pipe, uint8_t *buffer, uint8_t buffer_len)
{
    //ex: pipe =  PIPE_UART_OVER_BTLE_UART_TX_TX
    bool status = false;
    
    if (lib_aci_is_pipe_available(&aci_state, pipe) &&
        (aci_state.data_credit_available >= 1))
    {
        status = lib_aci_send_data(pipe, buffer, buffer_len);
        if (status)
        {
            aci_state.data_credit_available--;
        }
    }
    
    return status;
}

void nrf8001Test::receiveData(uint8_t pipe, aci_evt_t * aci_evt, uint8_t * uart_buffer, uint8_t * uart_buffer_len){
    //ex: pipe = PIPE_UART_OVER_BTLE_UART_RX_RX
    if ( pipe == aci_evt->params.data_received.rx_data.pipe_number)
    {
        
        Serial.print(F(" Data(Hex) : "));
        for(int i=0; i<aci_evt->len - 2; i++)
        {
            Serial.print((char)aci_evt->params.data_received.rx_data.aci_data[i]);
            uart_buffer[i] = aci_evt->params.data_received.rx_data.aci_data[i];
            Serial.print(F(" "));
        }
        *uart_buffer_len = aci_evt->len - 2;
        
    }
  
    
}

void nrf8001Test::disconnectDevice(void){
    
}

    
    
void nrf8001Test::handleEvents(void){
    
    // We enter the if statement only when there is a ACI event available to be processed
    setup_required = false;
    if (getStatus())
    {
        switch(aci_evt->evt_opcode)
        {
                /**
                 As soon as you reset the nRF8001 you will get an ACI Device Started Event
                 
                 */
            
            case ACI_EVT_DEVICE_STARTED:
            {
                Serial.println("Device started");
                aci_state.data_credit_total = aci_evt->params.device_started.credit_available;
                switch(aci_evt->params.device_started.device_mode)
                {
                    case ACI_DEVICE_SETUP:
                        Serial.println("Device setup required being set");
                        setDeviceSetupRequired();
                        break;
                        
                    case ACI_DEVICE_STANDBY:
                        Serial.println("Device standby");
                        handleDeviceStandby();
                       
                        break;
                    default:
                       Serial.println("Device mode unknown");
                       break;
                }
            }
                break; //ACI Device Started Event
                
            case ACI_EVT_CMD_RSP:
                Serial.println("Device cmd resp");
                //If an ACI command response event comes with an error -> stop
                  if (ACI_STATUS_SUCCESS != aci_evt->params.cmd_rsp.cmd_status)
                  { 
                    Serial.println("cmd resp error");
                    reportCmdRspError();
                  }
                  if (ACI_CMD_GET_DEVICE_VERSION == aci_evt->params.cmd_rsp.cmd_opcode)
                  {
                      Serial.println("set device version");
                      //setDeviceVersion(PIPE_DEVICE_INFORMATION_HARDWARE_REVISION_STRING_SET);
                  }
                  else if(ACI_CMD_CONNECT == aci_evt->params.cmd_rsp.cmd_opcode){
                      Serial.println("Connected cmd response received");
                  }
                  else if(ACI_CMD_SET_LOCAL_DATA == aci_evt->params.cmd_rsp.cmd_opcode){
                    Serial.println("Set local data cmd resp received");
                  }
                  else{
                    Serial.print(F("Unhandled cmd resp opcode "));
                    Serial.println(aci_evt->params.cmd_rsp.cmd_opcode, HEX);
                  }
                break;
                
            case ACI_EVT_CONNECTED:
                Serial.println("Device connected, request dev version");
                requestDeviceVersion();
                break;
                
            case ACI_EVT_PIPE_STATUS:
                Serial.println("change timing with pipe");
                //changeTimingWithPipe(PIPE_UART_OVER_BTLE_UART_TX_TX);
                break;
                
            case ACI_EVT_TIMING:
                Serial.println("set device timing");
                //setTiming(PIPE_UART_OVER_BTLE_UART_LINK_TIMING_CURRENT_SET, PIPE_UART_OVER_BTLE_UART_LINK_TIMING_CURRENT_SET_MAX_SIZE);
                break;
                
            case ACI_EVT_DISCONNECTED:
                Serial.println("Device disconnected");
                disconnectEvent();
                break;
                
            case ACI_EVT_DATA_RECEIVED:
                Serial.println("Device data received");
                //receiveData(PIPE_UART_OVER_BTLE_UART_RX_RX, aci_evt, uart_buffer, &uart_buffer_len);
                //Serial.println("Saying hello");
                
                //sayHello(PIPE_UART_OVER_BTLE_UART_TX_TX);
                break;
                
            case ACI_EVT_DATA_CREDIT:
                Serial.println("Device data credit event");
                dataCreditEvent();
                break;
                
            case ACI_EVT_PIPE_ERROR:
                Serial.println("Device pipe error event");
                pipeErrorEvent();
                break;
                
            case ACI_EVT_HW_ERROR:
                Serial.println("Device hw error event");
                hwErrorEvent();
                break;
                
        }
    }
    else
    {
        //Serial.println(F("No ACI Events available"));
        // No event in the ACI Event queue and if there is no event in the ACI command queue the arduino can go to sleep
        // Arduino can go to sleep now
        // Wakeup from sleep from the RDYN line
    }
    
    /* setup_required is set to true when the device starts up and enters setup mode.
     * It indicates that do_aci_setup() should be called. The flag should be cleared if
     * do_aci_setup() returns ACI_STATUS_TRANSACTION_COMPLETE.
     */
    
    if(setup_required)
    {
      Serial.println("Device setup ...");
      deviceSetup();
     }
    
}

void nrf8001Test::parseMIDItoAppleBle(uint8_t pipe, int noteType) {
  char time[2];
  char buf[20];
  byte outBuff[] = {0x90,65,127};
  byte timeBuff[2];
  byte messageBuff[5];
  unsigned long timer = 0;
  int lastPos;
  timer = millis();
  
  uint16_t blueMidiTime = 0;
  blueMidiTime = 32768 + (timer % 16383);
  //need 12bit time millis but not sure what to do when it rolls over passed 8 sec (max)
  timeBuff[0] = blueMidiTime >> 8; //0b1000 0000 (1st header 1 bit + no millis)
  timeBuff[1] = 0x80; //0b1000 0000 (2nd header 1 bit)
  

  // 0x80 0x80 Prefix Bytes for Apple Protocol    
  // buffer empty, write apple time prefix
  // TO DO: 
  // Implement correct Apple Time Coding
  // 2nd byte (0x80) is temp workaround
      if(noteType == 0){
        outBuff[0] = 0x80; //note off else it's note on
        outBuff[2] = 0; //velocity 
      }
      messageBuff[0] = timeBuff[0]; messageBuff[1] = timeBuff[1];
      messageBuff[2] = outBuff[0]; messageBuff[3] = outBuff[1];
      messageBuff[4] = outBuff[2];
      sendData(pipe, (uint8_t *)&messageBuff[0], 5);
      Serial.print("Sent: ");
      Serial.print(timeBuff[0],BIN);
      Serial.print(" "); Serial.println(timeBuff[1], BIN);
      
      Serial.print(outBuff[0],BIN); Serial.print(" ");
      Serial.print(outBuff[1],BIN); Serial.print(" ");
      Serial.println(outBuff[2],BIN);
      
      
      
}
    







