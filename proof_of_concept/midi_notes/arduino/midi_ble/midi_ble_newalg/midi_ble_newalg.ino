
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




int raw_values[11];
int noteX = 0, noteY = 0, noteZ = 0, accelX = 0, accelY = 0, accelZ = 0, filter_note = 0;
char note_on = 0, note = 0, prev_note = 0, velocity = 127, ccNote = 0;
unsigned long time_elapsed = 0;
unsigned long start_time = 0, prev_note_time = 0;

//testing new algorithm
long int x1 = 0, x0 = 0, maxSamples = 15, minDiff = 5000, minSum = 5000, samples=0, minFalling = -7000, catchFalling = -10000;
bool rising, falling;
long int xSum = 0, diff = 0;

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
  //Serial.println(F("IMU and Filter setup"));
  my3IMU.init(true);


  
  //Serial.println(F("Arduino setup"));
  //Serial.println(F("Set line ending to newline to send data from the serial monitor"));
  nrf8001_midi.configureDevice();
 
  //Serial.println(F("Set up done"));
  start_time = millis(); //get current time since program started say...5500 ms for example
  prev_note_time = millis(); //get current time since program started
  my3IMU.getRawValues(raw_values);
  accelX = raw_values[0];
  x0 = accelX;
  
  
}


void loop() {
  
  nrf8001_midi.handleEvents();
  //check if time elapsed since start time > 100 ms
         
         //data from sensors should be collected ~ every 35 milli seconds
         if(millis() - start_time > 35){
              
              my3IMU.getRawValues(raw_values);

              
              accelX = raw_values[0];
              accelY = raw_values[1];
              accelZ = raw_values[2];

              //continuous controll note value 0 - 127
              ccNote = getCCNote(accelZ);
              
              //get new value
              x1 = accelX;
              
              //1) diff = xi+1 - xi
              diff = x1 - x0;
              x0 = x1; //update x0 for next sample
              
              //2) is rising
              rising = rising || (diff >= minDiff);
              
              if(rising){
                samples++;
                falling = diff <= minFalling;
                
                if(falling){
                  samples++;
                }
              }
     
              
              //3) get xsum
              xSum = (xSum + diff) * rising;
              
              //4) get note
              if(diff <= catchFalling && !noteX && !rising){
                noteX = minDiff;
              }
              else{
                noteX = ((xSum <= minSum) && rising && falling)*minDiff;
              }
              if(noteX || (samples >= maxSamples)){
                  //reset all
                  
                  xSum = 0; 
                  samples = 0;
                  rising = 0;
                  falling = 0;
                  
              }
              
              
              
              if(noteX > 0 && nrf8001_midi.directionsOn[0]){
            
                note = nrf8001_midi.directionsOn[0]; //get note value from user over bluetooth using iphone app
                
                //make sure to send a note off midi from the previous note generated
                if(prev_note > 0){
                  sendNoteOff(prev_note);
                  prev_note = 0;
                  
                }

              
                //send midi on note 
                if(nrf8001_midi.status.connected==1){
                  
                  nrf8001_midi.sendFullMIDI(PIPE_MIDI_MIDI_IO_TX, 0x90, note, velocity); //accel note
                }
               
               prev_note = note;
               prev_note_time = millis();
               
               if(nrf8001_midi.status.connected==1){
                 nrf8001_midi.sendFullMIDI(PIPE_MIDI_MIDI_IO_TX, 0xB0, nrf8001_midi.ccDataByte0, ccNote); //cc
               }    
           
              }
          //get new start time 
          start_time = millis();  
         }
         
         if(millis() - prev_note_time > 100){
             //send note off of prev note made
            if(prev_note > 0 ){
              Serial.println("100 ms note off ");
              sendNoteOff(prev_note);
              prev_note = 0;
            }
            prev_note_time  = millis();
         }
                 
}

//functions


void sendNoteOff(int prev_note){
  if(nrf8001_midi.status.connected==1){
    nrf8001_midi.parseMIDItoAppleBle(PIPE_MIDI_MIDI_IO_TX, 0, prev_note, 0);
    //delay(12); //wait 12ms before sending on note
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



