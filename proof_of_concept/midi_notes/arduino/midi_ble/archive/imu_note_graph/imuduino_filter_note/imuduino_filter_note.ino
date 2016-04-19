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
#include <math.h> // (no semicolon)

//#define DEBUG
#include "DebugUtils.h"
#include "IMUduino.h"
#include <Wire.h>
#include <SPI.h>

int raw_values[11];
int noteX = 0, noteY = 0, noteZ = 0, accelX = 0, accelY = 0, accelZ = 0, gyroY=0;
char user;
char buf[6] = {0, 0, 0, 0, 0, 0};

//angle calculation variables
int average_count = 0, max_ave_count = 12, accel_scale_y = 16675, accel_scale_z = 17809, angle = 0;
int calc_average_y[12];
int calc_average_z[12];
float running_average_y = 0.0, running_average_z = 0.0, angle_f = 0.0;

//new algorithm variables
long int x1 = 0, x0 = 0, maxSamples = 15, minDiff = 5000, minSum = 5000, samples=0, minFalling = -7000, catchFalling = -10000;
bool rising, falling;
long int xSum = 0, diff = 0;
// Set the FreeIMU object
IMUduino my3IMU = IMUduino();

void setup() {
  
  Serial.begin(115200);
  //while(!Serial);
  Wire.begin();
    
  delay(500);
  my3IMU.init(true);  
}


void loop() {
        
        if(Serial.available() > 0){
            user = Serial.read();
            if(user == 'x'){
              my3IMU.getRawValues(raw_values);

              
            accelX = raw_values[0];
            accelY = raw_values[1];
            accelZ = raw_values[2];
            gyroY = raw_values[4];
            
            
            //----------------angle calculation
            
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
                
                average_count = 0;
            }
    
            if((running_average_y >= -1*accel_scale_y) && (running_average_y <= 1*accel_scale_y)){
                if((running_average_z >= -1*accel_scale_z) && (running_average_z <= 1*accel_scale_z)){
                    angle_f = atan2(running_average_y, running_average_z)*180.0/PI;
                    angle = (int)angle_f;
                }
            }
            
            
            //---------------Send data
            
            buf[0] = accelY; buf[1] = accelY >> 8;
            buf[2] = accelZ; buf[3] = accelZ >> 8;
            buf[4] = angle; buf[5] = angle >> 8;
            Serial.write(buf,6);
              
            }
          
        }   
     
}

