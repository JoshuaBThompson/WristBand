
#include "nrf8001.h"
#include "services.h"
#include "IMUduino.h"
#include "FilterMotion.h"
#include <lib_aci.h>
#include <SPI.h>
#include <EEPROM.h>
#include <Wire.h>
#include <I2Cdev.h>
#include <aci_setup.h>
#include "MPU60X0.h"
#include <MS561101BA.h>
#include <HMC58X3.h>



//init nrf8001 object
nrf8001 nrf8001_midi = nrf8001();
IMUduino my3IMU = IMUduino();
FilterMotion filterX = FilterMotion();
int raw_values[11];
int note = 0, accelX = 0, prev_note = 0;
char buf[6] = {0, 0, 0, 0, 0, 0};
int note_num = 0;
unsigned long time_elapsed = 0;
unsigned long start_time = 0;

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
  Serial.println(F("IMU and Filter setup"));
  my3IMU.init(true);
  filterX.init();
  Serial.println(F("Arduino setup"));
  Serial.println(F("Set line ending to newline to send data from the serial monitor"));
  nrf8001_midi.configureDevice();
 
  Serial.println(F("Set up done"));
  start_time = millis(); //get current time since program started say...5500 ms
}


void loop() {
  
  nrf8001_midi.handleEvents();
  // print the string when a newline arrives:
            //check if time elapsed since start time > 45 ms
         
         if(millis() - start_time > 40){
              my3IMU.getRawValues(raw_values);
              accelX = raw_values[0];
              note = filterX.getNote(accelX);
              buf[0] = note; buf[1] = note >> 8;
              if(note > 0){
                //note = 65;
                
                
                if(prev_note > 0){
                  //note off
                  note_num = 0;
                  if(nrf8001_midi.status.connected==1){
                    nrf8001_midi.parseMIDItoAppleBle(PIPE_MIDI_MIDI_IO_TX, note_num);
                    delay(5); //wait 5ms before sending on note
                  }
                }
                note_num = 1; //note 65
                if(nrf8001_midi.status.connected==1){
                  nrf8001_midi.parseMIDItoAppleBle(PIPE_MIDI_MIDI_IO_TX, note_num);
                }
                prev_note = note;
              }
          //get new start time 
          start_time = millis();    
         }
         
}

//functions





