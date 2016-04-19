
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

//Constants
#define NOTE_ON_STATUS      0x90
#define NOTE_OFF_STATUS     0x80
#define CH1_CCMODE_STATUS   0xB0


//init nrf8001 object
nrf8001 nrf8001_midi = nrf8001();
IMUduino my3IMU = IMUduino();
FilterMotion filterX = FilterMotion();


int raw_values[11];
int accelX, accelY, accelZ;
char note = 0, prev_note = 0, velocity = 127, ccNote = 0;
bool noteX = false;
unsigned long time_elapsed = 0, start_time = 0, prev_note_time = 0;


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
    delay(2000);
    //while(!Serial)
    //{}
    delay(5000);  //5 seconds delay for enabling to see the start up comments on the serial board
  #elif defined(__PIC32MX__)
    delay(1000);
  #endif
  
  //Initialize 
  my3IMU.init(true);
  nrf8001_midi.configureDevice();
  my3IMU.getRawValues(raw_values);
  accelX = raw_values[0];
  //need to start the note filter with an initial value
  filterX.setX0(accelX);
    
  //Initialize time variables
  start_time = millis(); //get current time since program started say...5500 ms for example
  prev_note_time = millis(); //get current time since program started
}


void loop() {
  
  nrf8001_midi.handleEvents();
         
         //data from sensors should be collected at least ~ every 35 milli seconds
         if(millis() - start_time > 35){
              
              my3IMU.getRawValues(raw_values);
              accelX = raw_values[0];
              //accelY = raw_values[1]; //not used now
              accelZ = raw_values[2];

              //continuous controll note value 0 - 127
              ccNote = getCCNote(accelZ);
              
              //get note if motion valid
              noteX = filterX.isNote(accelX);
              
              if(noteX && nrf8001_midi.directionsOn[0]){
            
                    note = nrf8001_midi.directionsOn[0]; //get note value from user over bluetooth using iphone app
                    
                    //make sure to send a note off midi from the previous note generated
                   if(prev_note > 0){
                      sendNoteOff(prev_note);
                      prev_note = 0;
                      
                   }
    
                    //send midi on note 
                   sendNoteOn(note);
                   
                   prev_note = note;
                   prev_note_time = millis();
                   
                   sendCCNote(ccNote);    
              }
              
          //get new start time 
          start_time = millis();  
         }
         
         if(millis() - prev_note_time > 100){
             //send note off of prev note made
            if(prev_note > 0 ){
              sendNoteOff(prev_note);
              prev_note = 0;
            }
            prev_note_time  = millis();
         }
                 
}

//functions

void sendNoteOff(char noteVal){
  if(nrf8001_midi.status.connected==1){
    nrf8001_midi.sendFullMIDI(PIPE_MIDI_MIDI_IO_TX, NOTE_OFF_STATUS, noteVal, 0); //accel note off
  }
}

void sendNoteOn(char noteVal){
  if(nrf8001_midi.status.connected==1){             
     nrf8001_midi.sendFullMIDI(PIPE_MIDI_MIDI_IO_TX, NOTE_ON_STATUS, noteVal, velocity); //accel note
  }
}

void sendCCNote(char ccVal){
  if(nrf8001_midi.status.connected==1){
       nrf8001_midi.sendFullMIDI(PIPE_MIDI_MIDI_IO_TX, CH1_CCMODE_STATUS, nrf8001_midi.ccDataByte0, ccVal); //cc
  }
}

char getCCNote(int accelValue){
  //for z axis typical +/- max values are 18000 and -18000
  float ccFloat = accelValue;
  char ccChar = 0;
  float Max = 18000.00;
  float scale = Max*2; 
  ccFloat = (Max - ccFloat) / scale;
  
  ccFloat = ccFloat * 127;
  if(ccFloat > 127){ccFloat = 127;}
  else if (ccFloat < 0){ccFloat = 0;}
  ccChar = char(ccFloat);
  
  
  return ccChar;
  
}


