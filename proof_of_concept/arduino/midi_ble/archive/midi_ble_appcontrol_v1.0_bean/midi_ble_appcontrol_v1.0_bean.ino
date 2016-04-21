#include "FilterMotion.h"



//Constants
#define NOTE_ON_STATUS      0x90
#define NOTE_OFF_STATUS     0x80
#define CCMODE_STATUS   0xB0

FilterMotion filterX = FilterMotion();


int raw_values[11];
int accelX, accelY, accelZ;
char note = 0, prev_note = 0, velocity = 127, ccNote = 0;
bool noteX = false;
unsigned long time_elapsed = 0, start_time = 0, prev_note_time = 0;

//angle calculation variables
int average_count = 0, max_ave_count = 5, accel_scale_y = 255, accel_scale_z = 255, angle = 0;
int calc_average_y[5];
int calc_average_z[5];
float running_average_y = 0.0, running_average_z = 0.0, angle_f = 0.0, y_offset=0, z_offset=0;


void setup(void)
{
  Serial.begin(115200);
  
  //Initialize 
  AccelerationReading acceleration = Bean.getAcceleration();
  accelX = acceleration.xAxis;
  //need to start the note filter with an initial value
  filterX.setX0(accelX);
    
  //Initialize time variables
  start_time = millis(); //get current time since program started say...5500 ms for example
  prev_note_time = millis(); //get current time since program started
}


void loop() {
         
         //data from sensors should be collected at least ~ every 35 milli seconds
         if(millis() - start_time > 30){
           //get new start time (moved from end of loop)
            Serial.println(millis() - start_time);
            start_time = millis();
            AccelerationReading acceleration = Bean.getAcceleration();
              
              accelX = acceleration.xAxis;
              accelY = acceleration.yAxis;
              accelZ = acceleration.zAxis;
              
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
  Serial.println("note off");
}

void sendNoteOn(char noteVal){
  Serial.println("note on");
}

void sendCCNote(char ccVal){
  
  Serial.println("cc note on");

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
      }
  }
  
}

char getNoteFromAngle(void){
  char angle1Note = 65;
  char angle2Note = 40;
  char angle3Note = 80;
  
  
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



