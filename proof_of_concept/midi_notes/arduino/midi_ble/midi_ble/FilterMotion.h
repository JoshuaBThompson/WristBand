/*
IMUduino.h - Originally based on FreeIMU.h - A libre and easy to use orientation sensing library for Arduino
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

//#ifndef FilterMotion_h
#define FilterMotion_h

//Motion Types
#define ACCELMOTION 0
#define GYROMOTION 1


// -----------------filter constants for Acceleration Notes-----------------

//Constants for determining rising slope
#define AccelR1            5000
#define AccelR2            5000
#define AccelR3            (AccelR1 + AccelR2)*1

//Constants for falling slope
#define AccelF1            -7000
#define AccelF2            -7000
#define AccelF3            (AccelF1 + AccelF2)*1

//Max and min samples to count before throwing out rising slope
#define AccelMaxSamples     12
#define AccelMinSamples     3

//Min samples required to do calculation (x1, x2, x3)
#define AccelMinCount       3

//minimum average sum of all points on valid note:  xsum/count >= accel sum
#define AccelASum           6000

// -----------------filter constants for Gyro Notes-----------------

//Constants for determining rising slope
#define GyroR1            500
#define GyroR2            700
#define GyroR3            (GyroR1 + GyroR2)*1

//Constants for falling slope
#define GyroF1            -700
#define GyroF2            -700
#define GyroF3            (GyroF1 + GyroF2)*1

//Max samples to count before throwing out rising slope
#define GyroMaxSamples     12
#define GyroMinSamples     4

//Min samples required to do calculation (x1, x2, x3)
#define GyroMinCount       3

//minimum average sum of all points on valid note xsum/count
#define GyroASum           1100


#include "Arduino.h"


class FilterMotion
{
  public:
    FilterMotion(int);
    void init();
    bool areSamplesReady();
    void updateX(int x);
    void getDelX();
    bool isRising();
    bool isFalling();
    long int getXSum(int x);
    void reset();
    bool noteValid();
    bool resetNeeded();
    bool isUndersampled();
    bool isOversampled();
    int getNote(int x);
    void loadAccelParams();
    void loadGyroParams();

    bool falling, rising, samplesReady;
    long int delX1, delX2, delX3, x1, x2, x3, xref, xsum, sampleCount, updateCount;
    int aSum, r1, r2, r3, f1, f2, f3, minSamples, maxSamples, minCount;
};




//#endif // FilterMotion_h

