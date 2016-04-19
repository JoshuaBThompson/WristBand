
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
#define CCMODE_STATUS   0xB0



//init nrf8001 object
nrf8001 nrf8001_midi = nrf8001();
IMUduino my3IMU = IMUduino();
FilterMotion filterX = FilterMotion();


int raw_values[11];
int accelX, accelY, accelZ;
char note = 0, prev_note = 0, velocity = 127, ccNote = 0;
bool noteX = false;
unsigned long time_elapsed = 0, start_time = 0, prev_note_time = 0;

//angle calculation variables
int average_count = 0, max_ave_count = 5, accel_scale_y = 16675, accel_scale_z = 17809, angle = 0;
int calc_average_y[5];
int calc_average_z[5];
float running_average_y = 0.0, running_average_z = 0.0, angle_f = 0.0, y_offset=-450.0, z_offset=-450.0;


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
         if(millis() - start_time > 30){
           //get new start time (moved from end of loop)
            start_time = millis();
              
              my3IMU.getRawValues(raw_values);
              accelX = raw_values[0];
              accelY = raw_values[1];
              accelZ = raw_values[2];
              
              updateAngle(); //calculate average angle of device about x axis using y and z accelerations

              //continuous controll note value 0 - 127
              ccNote = getCCNote(accelZ);
              
              //get note if motion valid
              noteX = filterX.isNote(accelX);
              
              if(noteX){
                    note = getNoteFromAngle();//get note value from angle and user sent value (user can set note of angle 1 , 2 or 3 using iphone app)
                    
                    //make sure to send a note off midi from the previous note generated
                   if(prev_note > 0){
                      sendNoteOff(prev_note);
                      prev_note = 0;
                      
                   }
    
                    //send midi on note 
                   sendNoteOn(note);
                   
                   prev_note = note;
                   prev_note_time = millis();
                   
                   sendCCNote(ccNote); //this will result in device sending cc data to the iphone or pc. User must send cc note type via iphone or this will just be cc 0 (which is still a valid cc cmd)    
              }
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
    nrf8001_midi.sendFullMIDI(PIPE_MIDI_MIDI_IO_TX, nrf8001_midi.noteOffStatus, noteVal, 0); //accel note off
  }
}

void sendNoteOn(char noteVal){
  if(nrf8001_midi.status.connected==1){             
     nrf8001_midi.sendFullMIDI(PIPE_MIDI_MIDI_IO_TX, nrf8001_midi.noteOnStatus, noteVal, velocity); //accel note
  }
}

void sendCCNote(char ccVal){
  if(nrf8001_midi.status.connected==1){
       nrf8001_midi.sendFullMIDI(PIPE_MIDI_MIDI_IO_TX, nrf8001_midi.ccModeStatus, nrf8001_midi.ccDataByte0, ccVal); //cc
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

void updateAngle(void){
  if(average_count < max_ave_count){
                calc_average_y[average_count] = accelY;
                calc_average_z[average_count] = accelZ;
                average_count += 1;
            }

  else if (average_count == max_ave_count){
      running_average_y = 0;
      running_average_z = 0;
      for( char i=0; i < max_ave_count; i++){
          running_average_y += (float)calc_average_y[i]/(float)max_ave_count;
          running_average_z += (float)calc_average_z[i]/(float)max_ave_count;
      }
      running_average_y = running_average_y - y_offset;
      running_average_z = running_average_z - z_offset;
      average_count = 0;
  }
    
  if((running_average_y >= -1*accel_scale_y) && (running_average_y <= 1*accel_scale_y)){
      if((running_average_z >= -1*accel_scale_z) && (running_average_z <= 1*accel_scale_z)){
          angle_f = atan2(running_average_y, running_average_z)*180.0/PI;
          angle = (int)angle_f;
          Serial.println(angle,DEC);
      }
  }
  
}

char getNoteFromAngle(void){
  char angle1Note = nrf8001_midi.directionsOn[0]; //initially 25, user can send 0A0000 to set to 0 or for example 0A0041 to set to 65 (since 41 hex = 65 deciminal)
  char angle2Note = nrf8001_midi.directionsOn[1]; //initially 45, user can send 0A0100 to set to 0 or for example 0A0141 to set to 65
  char angle3Note = nrf8001_midi.directionsOn[2]; //initially 65, user can send 0A0200 to set to 0 or for example 0A0241 to set to 65
  
  
  //only 2 angles for now....
  if(angle <= 0){
     return angle1Note;
  }
  
  if(angle > 0){
     return angle2Note;
  }
  
  
  //should not reach here, but if so will return Note = 0
  return 0;
  
}



