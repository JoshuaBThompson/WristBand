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

//Constants for determining when motion constitutes note
#define MinDiff             50
#define MinSum              500
#define MinFalling         -50
#define CatchFalling       -100

//Max samples that can be used to generate a note
#define MaxSamples     15




#include "Arduino.h"


class FilterMotion
{
  public:
    
    //Methods
    FilterMotion(void);
    void reset(void);
    void setX0(long int x);
    void setX1(long int x);
    bool isNote(long int x);

    //Variables
    unsigned int samples;
    long int x1, x0, xSum, diff;
    bool rising, falling, note;
};




//#endif // FilterMotion_h


