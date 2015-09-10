
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
FilterMotion accelNoteX = FilterMotion(ACCELMOTION);
FilterMotion accelNoteY = FilterMotion(ACCELMOTION);
FilterMotion accelNoteZ = FilterMotion(ACCELMOTION);

FilterMotion gyroNoteX = FilterMotion(GYROMOTION);
FilterMotion gyroNoteY = FilterMotion(GYROMOTION);
FilterMotion gyroNoteZ = FilterMotion(GYROMOTION);

int raw_values[11];
int noteX = 0, noteY = 0, noteZ = 0, accelX = 0, accelY = 0, accelZ = 0, gyroZ=0, gyroY=0, gyroX=0, noteZ_gyro=0, noteY_gyro=0, noteX_gyro=0, filter_note = 0;
char note_on = 0, note = 0, prev_note = 0, velocity = 0;
unsigned long time_elapsed = 0;
unsigned long start_time = 0, prev_note_time = 0;
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
  accelNoteX.init();
  accelNoteY.init();
  accelNoteZ.init();
  
  gyroNoteX.init();
  gyroNoteY.init();
  gyroNoteZ.init();
  //Serial.println(F("Arduino setup"));
  //Serial.println(F("Set line ending to newline to send data from the serial monitor"));
  nrf8001_midi.configureDevice();
 
  //Serial.println(F("Set up done"));
  start_time = millis(); //get current time since program started say...5500 ms for example
  prev_note_time = millis(); //get current time since program started
}


void loop() {
  
  nrf8001_midi.handleEvents();
  // print the string when a newline arrives:
            //check if time elapsed since start time > 45 ms
         
         //data from sensors should be collected ~ every 40 milli seconds
         if(millis() - start_time > 40){
              note = 0;
              filter_note = 0;
              //get accelerometer and gyroscope sensor data and put in raw_values array
              my3IMU.getRawValues(raw_values);
              
              //load accel and gyro data into variables
              accelX = raw_values[0];
              accelY = raw_values[1];
              accelZ = raw_values[2];
              
              gyroX = raw_values[3];
              gyroY = raw_values[4];
              gyroZ = raw_values[5];
              
              //add data to running note calculation, filter will see if this data point completes a note, adds to a developing note (rising slope) or is a non note data point
              noteX = accelNoteX.getNote(accelX);
              noteY = accelNoteY.getNote(accelY);
              noteZ = accelNoteZ.getNote(accelZ);
              
              //to remove a note from the midi output, just comment it out
              //ex: //noteX_gyro = gyroNoteX.getNote(gyroX);
              //this will remove the gyro note x from sound output
              
              noteX_gyro = gyroNoteX.getNote(gyroX);
              noteY_gyro = gyroNoteY.getNote(gyroY);
              noteZ_gyro = gyroNoteZ.getNote(gyroZ);
              
              //nrf8001_midi.rx_buffer[0] ...or  [1].... etc will control which notes will be allowed
              //example1: if sending data from uart ble app on iphone and you want only the acceleration notes on and the gyro notes off then you send: 111000
              //example2: for only noteX allowed send: 100000
              
              
              //compare notes of each direction and see which one has the large magnitude, the largest will be played on midi and the rest will be discarded
              if(noteX > 0 && noteX >= filter_note && nrf8001_midi.rx_buffer[0]){
                filter_note = noteX;
                note = 36; //kick C2
                velocity = 127;
              }
              if(noteY > 0 && noteY >= filter_note && nrf8001_midi.rx_buffer[1]){
                filter_note = noteY;
                note = 50; //crash 15 in D3
                velocity = 127;
              }
              if (noteZ > 0 && noteZ >= filter_note && nrf8001_midi.rx_buffer[2]){
                 filter_note = noteZ;
                 note = 44; //closed edge high hat G#2
                 velocity = 127;
              }
              if (noteZ_gyro > 0 && noteZ_gyro >= filter_note && nrf8001_midi.rx_buffer[3]){
                filter_note = noteZ_gyro;
                note = 37; //cowbell
                velocity = 127;
              }
              if (noteY_gyro > 0 && noteY_gyro >= filter_note && nrf8001_midi.rx_buffer[4]){
                filter_note = noteY_gyro;
                note = 45; //low tom
                velocity = 127;
              }
              if (noteX_gyro > 0 && noteX_gyro >= filter_note && nrf8001_midi.rx_buffer[5]){
                filter_note = noteX_gyro;
                note = 46; //open hi hat
                velocity = 127;
              }
              
              
              //see if note was generated and then reset all filters if it was
              if(note > 0){
                //reset all notes after sending a note, to reduce multiple notes from happening in succession (though it still happens, but less using resets)
                accelNoteX.reset();
                accelNoteY.reset();
                accelNoteZ.reset();
                gyroNoteZ.reset();
                gyroNoteY.reset();
                gyroNoteZ.reset();
                
                //make sure to send a note off midi from the previous note generated
                if(prev_note > 0){
                  Serial.println("40 ms note off ");
                  sendNoteOff(prev_note);
                  
                }
                
                //send midi on note 
                note_on = 1; //set note ON
                if(nrf8001_midi.status.connected==1){
                  nrf8001_midi.parseMIDItoAppleBle(PIPE_MIDI_MIDI_IO_TX, note_on, note, velocity);
                }
                prev_note = note;
                prev_note_time  = millis();
              }
          
           
          //get new start time 
          start_time = millis();  
            
         }
         
         if(millis() - prev_note_time > 100){
             Serial.println("100 ms note off missed ");
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



