
#include "nrf8001.h"
#include "services.h"
#include <lib_aci.h>
#include <SPI.h>
#include <EEPROM.h>
#include <aci_setup.h>



//init nrf8001 object
nrf8001 nrf8001_midi = nrf8001();

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
  nrf8001_midi.configureDevice();
 
  Serial.println(F("Set up done"));
}


void loop() {
  nrf8001_midi.handleEvents();
  // print the string when a newline arrives:
  if (Serial.available() && nrf8001_midi.status.connected==1) 
  {
    char note = Serial.read();
    int note_num = note - '0';
    Serial.print(F("Sending midi "));
    Serial.println(note);
    if(note_num <= 1){
      nrf8001_midi.parseMIDItoAppleBle(PIPE_MIDI_MIDI_IO_TX, note_num);
    }
    else{
      Serial.println("note > 1, no send");
    }
    
  }
 
}

//functions





