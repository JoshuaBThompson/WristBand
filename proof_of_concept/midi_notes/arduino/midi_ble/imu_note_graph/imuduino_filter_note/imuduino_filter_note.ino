/**  ..... FreeIMU library ....
 * Example program for using the FreeIMU connected to an Arduino Leonardo.
 * The program reads sensor data from the FreeIMU, computes the yaw, pitch
 * and roll using the FreeIMU library sensor fusion and use them to move the
 * mouse cursor. The mouse is emulated by the Arduino Leonardo using the Mouse
 * library.
 * 
 * @author Fabio Varesano - fvaresano@yahoo.it
*/

//   ..... Adafruit nRF8001 libary ....
/*********************************************************************
This is an example for our nRF8001 Bluetooth Low Energy Breakout

  Pick one up today in the adafruit shop!
  ------> http://www.adafruit.com/products/1697

Adafruit invests time and resources providing this open source code, 
please support Adafruit and open-source hardware by purchasing 
products from Adafruit!

Written by Kevin Townsend/KTOWN  for Adafruit Industries.
MIT license, check LICENSE for more information
All text above, and the splash screen below must be included in any redistribution
*********************************************************************/

#include <HMC58X3.h>
#include <MS561101BA.h>
#include <I2Cdev.h>
#include <MPU60X0.h>
#include <EEPROM.h>

//#define DEBUG
#include "DebugUtils.h"
#include "IMUduino.h"
#include "FilterMotion.h"
#include <Wire.h>
#include <SPI.h>

int raw_values[11];
int noteX = 0, noteY = 0, noteZ = 0, accelX = 0, accelY = 0, accelZ = 0;
int gyroX = 0, gyroY = 0, gyroZ = 0;
char user;
char buf[6] = {0, 0, 0, 0, 0, 0};

//testing new algorithm
long int x1 = 0, x0 = 0, maxSamples = 15, minDiff = 5000, minSum = 5000, samples=0, minFalling = -7000, catchFalling = -10000;
bool rising, falling;
long int xSum = 0, diff = 0;
// Set the FreeIMU object
IMUduino my3IMU = IMUduino();
/*
FilterMotion filterX = FilterMotion(ACCELMOTION);
FilterMotion filterY = FilterMotion(ACCELMOTION);
FilterMotion filterZ = FilterMotion(ACCELMOTION);
*/

void setup() {
////  Mouse.begin();
  
  Serial.begin(115200);
  while(!Serial);
  Wire.begin();
  
  //Serial.println(F("Test: Adafruit Bluefruit Low Energy nRF8001 + FreeIMU Print echo demo"));
  
  delay(500);
  my3IMU.init(true);
  /*
  filterX.init();
  filterY.init();
  filterZ.init();
  */
  
  //get first x sample x0
  my3IMU.getRawValues(raw_values);
  accelX = raw_values[0];

  x0 = accelX;
}


void loop() {
  /*
        delay(1000);
        my3IMU.getRawValues(raw_values);
        accelX = raw_values[0];
        Serial.println("x");
        Serial.println(accelX);
   */
        
        if(Serial.available() > 0){
            user = Serial.read();
            if(user == 'x'){
              my3IMU.getRawValues(raw_values);

              
              accelX = raw_values[0];
              accelY = raw_values[1];
              accelZ = raw_values[2];

              //if(accelX >= 32768){
              //  accelX = accelX - 65536;
              //}
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
           
              /*
              noteX = filterX.getNote(accelX);
              noteY = filterY.getNote(accelY);
              noteZ = filterZ.getNote(accelZ);
              */
              /*
              if(noteX >= noteY && noteX >= noteZ && noteX > 0){
                noteX = 30000;
                buf[0] = noteX; buf[1] = noteX >> 8;
              }
              else if(noteY >= noteX && noteY >= noteZ && noteY > 0){
                noteY = 20000;
                buf[0] = noteY; buf[1] = noteY >> 8;
              }
              else if (noteZ >= noteX && noteZ >= noteY && noteZ > 0){
                 noteZ = 10000;
                 buf[0] = noteZ; buf[1] = noteZ >> 8;
              }
              else{
                buf[0] = 0; buf[1] = 0;
              }
              */
             buf[0] = noteX; buf[1] = noteX >> 8;
              
              
            buf[2] = accelX; buf[3] = accelX >> 8;
            buf[4] = samples; buf[5] = 0;
              //raw x values instead of note buf[2] = raw_values[0]; buf[3] = raw_values[0] >> 8;
              Serial.write(buf,6);
              //delay(40);
              
            }
          
        }
        
     
}


