/*
IMUduino_AG.h - Originally based on FreeIMU.h - A libre and easy to use orientation sensing library for Arduino
Copyright (C) 2011 Fabio Varesano <fabio at varesano dot net>

Development of this code has been supported by the Department of Computer Science,
Universita' degli Studi di Torino, Italy within the Piemonte Project
http://www.piemonte.di.unito.it/


This program is free software: you can redistribute it and/or modify
it under the terms of the version 3 GNU General Public License as
published by the Free Software Foundation.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.

*/



//----NOTE! This is a modified version of IMUduino. Only thing different is the barometer is removed!------//

#ifndef IMUduino_AG_h
#define IMUduino_AG_h


#define IMUduino_AG_v04

// *** No configuration needed below this line ***


#define IMUduino_AG_LIB_VERSION "20140717"

#define IMUduino_AG_DEVELOPER "Femtuduino, modified by jbthompson.eng@gmail.com"

#define IMUduino_AG_FREQ "16 MHz"


// board IDs

#define IMUduino_AG_ID "IMUduino_AG v0.4"


#define HAS_AXIS_ALIGNED() (defined(IMUduino_AG_v04))



#include <Wire.h>
#include "Arduino.h"
#include "calibration.h"

#ifndef CALIBRATION_H
#include <EEPROM.h>
#endif

#define IMUduino_AG_EEPROM_BASE 0x0A
#define IMUduino_AG_EEPROM_SIGNATURE 0x19


  #include <Wire.h>
  #include "I2Cdev.h"
  #include "MPU60X0.h"
  #define FIMU_ACCGYRO_ADDR MPU60X0_DEFAULT_ADDRESS


#ifndef cbi
#define cbi(sfr, bit) (_SFR_BYTE(sfr) &= ~_BV(bit))
#endif

class IMUduino_AG
{
  public:
    IMUduino_AG();
    void init();
    void init(bool fastmode);
    
    void init(int accgyro_addr, bool fastmode);

    #ifndef CALIBRATION_H
    void calLoad();
    #endif
    void zeroGyro();
    void getRawValues(int * raw_values);
    
    MPU60X0 accgyro;
    
    
    int* raw_acc, raw_gyro;
    // calibration parameters
    int16_t gyro_off_x, gyro_off_y, gyro_off_z;
    int16_t acc_off_x, acc_off_y, acc_off_z;
    float acc_scale_x, acc_scale_y, acc_scale_z;
    
  private:
    float sampleFreq; // half the sample period expressed in seconds
    
};

float invSqrt(float number);
void arr3_rad_to_deg(float * arr);



#endif // IMUduino_AG_h

