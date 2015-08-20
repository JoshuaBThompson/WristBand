
#include "nrf8001Test.h"
#include "services.h"
#include <lib_aci.h>
#include <SPI.h>
#include <EEPROM.h>
#include <aci_setup.h>



//init nrf8001Test object
nrf8001Test nrf8001_test = nrf8001Test();

/* Define how assert should function in the BLE library */
void __ble_assert(const char *file, uint16_t line)
{
  Serial.print("ERROR ");
  Serial.print(file);
  Serial.print(": ");
  Serial.print(line);
  Serial.print("\n");
  while(1);
}

void setup(void)
{
  Serial.begin(115200);
  //Wait until the serial port is available (useful only for the Leonardo)
  //As the Leonardo board is not reseted every time you open the Serial Monitor
  #if defined (__AVR_ATmega32U4__)
    while(!Serial)
    {}
    delay(5000);  //5 seconds delay for enabling to see the start up comments on the serial board
  #elif defined(__PIC32MX__)
    delay(1000);
  #endif

  Serial.println(F("Arduino setup"));
  Serial.println(F("Set line ending to newline to send data from the serial monitor"));
  nrf8001_test.configureDevice();
 
  Serial.println(F("Set up done"));
}




bool stringComplete = false;  // whether the string is complete
uint8_t stringIndex = 0;      //Initialize the index to store incoming chars

void loop() {
  nrf8001_test.handleEvents();
  // print the string when a newline arrives:
  if (Serial.available() && nrf8001_test.status.connected==1) 
  {
    char note = Serial.read();
    int note_num = note - '0';
    Serial.print(F("Sending midi "));
    Serial.println(note);
    if(note_num <= 1){
      nrf8001_test.parseMIDItoAppleBle(PIPE_MIDI_MIDI_IO_TX, note_num);
    }
    else{
      Serial.println("note > 1, no send");
    }
    
  }
 
}

//functions





