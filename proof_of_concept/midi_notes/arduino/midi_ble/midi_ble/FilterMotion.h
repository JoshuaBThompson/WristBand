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



// filter constants

//Constants for determining rising slope
#define RX1            5000
#define RX2            5000
#define RX3            (RX1 + RX2)*1

//Constants for falling slope
#define FX1            -7000
#define FX2            -7000
#define FX3            (FX1 + FX2)*1

//Max samples to count before throwing out rising slope
#define MaxSamples     10
#define MinSamples     3

//Min samples required to do calculation (x1, x2, x3)
#define MinCount       3

//minimum average sum of all points on valid note xsum/count
#define ASum           7500


#include "Arduino.h"


class FilterMotion
{
  public:
    FilterMotion();
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

    bool falling, rising, samplesReady;
    long int delX1, delX2, delX3, x1, x2, x3, xref, xsum, sampleCount, updateCount;
    
};




//#endif // FilterMotion_h

