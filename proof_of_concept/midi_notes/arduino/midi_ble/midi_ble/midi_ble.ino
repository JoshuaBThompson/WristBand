
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
FilterMotion filterY = FilterMotion();
FilterMotion filterZ = FilterMotion();

int raw_values[11];
int noteX = 0, noteY = 0, noteZ = 0, accelX = 0, accelY = 0, accelZ = 0;
char buf[6] = {0, 0, 0, 0, 0, 0};
char note_on = 0, note = 0, prev_note = 0;
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
  filterY.init();
  filterZ.init();
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
              accelY = raw_values[1];
              accelZ = raw_values[2];
              noteX = filterX.getNote(accelX);
              noteY = filterY.getNote(accelY);
              noteZ = filterZ.getNote(accelZ);
              if(noteX >= noteY && noteX >= noteZ && noteX > 0){
                note = 30;
              }
              else if(noteY >= noteX && noteY >= noteZ && noteY > 0){
                note = 45;
              }
              else if (noteZ >= noteX && noteZ >= noteY && noteZ > 0){
                 note = 65;
              }
              else{
                note = 0;
              }
              if(note > 0){
                
                
                if(prev_note > 0){
                  note_on = 0; //set note OFF
                  if(nrf8001_midi.status.connected==1){
                    nrf8001_midi.parseMIDItoAppleBle(PIPE_MIDI_MIDI_IO_TX, note_on, prev_note);
                    delay(12); //wait 12ms before sending on note
                  }
                }
                note_on = 1; //set note ON
                if(nrf8001_midi.status.connected==1){
                  nrf8001_midi.parseMIDItoAppleBle(PIPE_MIDI_MIDI_IO_TX, note_on, note);
                }
                prev_note = note;
              }
          //get new start time 
          start_time = millis();    
         }
         
}

//functions





