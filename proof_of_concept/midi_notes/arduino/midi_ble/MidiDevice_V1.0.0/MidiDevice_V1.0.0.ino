#include <SPI.h>
#include <EEPROM.h>
#include <Wire.h>
#include <I2Cdev.h>
#include <lib_aci.h>
#include <aci_setup.h>
#include "MidiServer.h"

MidiServer midiServer = MidiServer();
String myStr;
uint8_t UmyStr[10];
bool cmdAvailable;

/* Define how assert should function in the BLE library */
void __ble_assert(const char *file, uint16_t line)
{
  delay(5000);
  Serial.print("ERROR ");
  Serial.print(file);
  Serial.print(": ");
  Serial.print(line);
  Serial.print("\n");
  while(1);
}

void setup(void)
{
  Serial.begin(9600);
  
  //Wait until the serial port is available (useful only for the Leonardo)
  //As the Leonardo board is not reseted every time you open the Serial Monitor
  #if defined (__AVR_ATmega32U4__)
    delay(2000);
    //while(!Serial)
    //{}
    delay(2000);  //5 seconds delay for enabling to see the start up comments on the serial board
  #elif defined(__PIC32MX__)
    delay(1000);
  #endif
  midiServer.init();
  
}


//------------------Main Loop---------------------------------
void loop() {
  midiServer.handleEvents();
}


//------------------Functions---------------------------------
void handleSerialEvents(void){

      if(Serial.available() > 0){
    
        myStr = Serial.readString();
        //Serial.println("Got str");
        //Serial.print(myStr);
        //Serial.println("");
        for(int i = 0; i<10; i++){
          UmyStr[i] = (uint8_t)myStr[i];
        }
        cmdAvailable = midiServer.parseCmdFromRxBuffer(UmyStr);
        /*
        Serial.print("number ");
        Serial.println(midiServer.rxCmd.number);
        Serial.print("data type ");
        switch(midiServer.rxCmd.dataType){
          case BYTE_TYPE:
            Serial.print("byte");
            Serial.println((char)midiServer.rxCmd.args.byteValue);
            break;
          case INT_TYPE:
            Serial.print("int");
            Serial.println(midiServer.rxCmd.args.intValue);
            break;
          case FLOAT_TYPE:
            Serial.print("float");
            Serial.println(midiServer.rxCmd.args.floatValue);
            break;
          default:
            Serial.println("none");
            break;
        }
        */
    
        if(cmdAvailable){
           midiServer.rxCmdCallback(&midiServer.rxCmd);
        }
    }//end if serial available
}


