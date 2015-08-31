/*
IMUDuino.cpp - Originally based on FreeIMU.cpp - A libre and easy to use orientation sensing library for Arduino
Copyright (C) 2011-2012 Fabio Varesano <fabio at varesano dot net>

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


#include <inttypes.h>
#include <stdint.h>
#include "FilterMotion.h"


FilterMotion::FilterMotion(int motionType) {

  // initialize variables
  falling = false;
  rising = false;
  samplesReady = false;
  delX1 = 0;
  delX2 = 0;
  delX3 = 0;
  x1 = 0;
  x2 = 0;
  x3 = 0;
  xref = 0;
  xsum = 0;
  sampleCount = 0;
  updateCount = 0;
  if(motionType==ACCELMOTION){
    loadAccelParams();
  }
  else if(motionType==GYROMOTION){
    loadGyroParams();
  }

}

void FilterMotion::loadAccelParams(){
  aSum = AccelASum; 
  r1 = AccelR1;
  r2 = AccelR2; 
  r3 = AccelR3;
  f1 = AccelF1;
  f2 = AccelF2;
  f3 = AccelF3;
  minSamples = AccelMinSamples;
  maxSamples = AccelMaxSamples;
  minCount = AccelMinCount;
}

void FilterMotion::loadGyroParams(){
  aSum = GyroASum; 
  r1 = GyroR1;
  r2 = GyroR2; 
  r3 = GyroR3;
  f1 = GyroF1;
  f2 = GyroF2;
  f3 = GyroF3;
  minSamples = GyroMinSamples;
  maxSamples = GyroMaxSamples;
  minCount = GyroMinCount;
}

void FilterMotion::init() {

  // initialize variables
  falling = false;
  rising = false;
  samplesReady = false;
  delX1 = 0;
  delX2 = 0;
  delX3 = 0;
  x1 = 0;
  x2 = 0;
  x3 = 0;
  xref = 0;
  xsum = 0;
  sampleCount = 0;
  updateCount = 0;

  //todo: anything else?
  
}



/**
 * Check if there are more than 3 updates made for (x1, x2, x3)
*/

bool FilterMotion::areSamplesReady(){

    if(samplesReady){
        return true;
    }

    //if samplesReady set once, then that's it, no need to check count anymore

    if(updateCount >= minCount) {
        samplesReady = true;
        return true;
    }
    else {
        samplesReady = false;
        return false;
    }
}


/**
 * Populate / update x1, x2 and x3 values for next calculation
*/

void FilterMotion::updateX(int x){
    //push x to x3 and x3 to x2 and x2 to x1
    //keep the order!
    x1 = x2;
    x2 = x3;
    x3 = x;

    //update count (for areSamplesReady)
    updateCount++;

    areSamplesReady();

}


/**
 * Get the delta X1 2 and 3 values used to calculate falling or rising
 * If samples not ready then just leave all as 0
*/

void FilterMotion::getDelX(){
    /* del_x1 = x2 - x1
       del_x2 = x3 - x2
       del_x3 = x3 - x1
    */

    if(samplesReady){
        delX1 = x2 - x1;
        delX2 = x3 - x2;
        delX3 = x3 - x1;
    }
    //delX1 2 and 3 init to 0 already if not samplesReady
}

/**
* Determine of x1, x2 and x3 indicate valid rising slope for note
*/

bool FilterMotion::isRising(){
    rising = (delX1 > r1) || (delX2 > r2) || (delX3 > r3);

    //check if rising detection if from previously falling slope and update xref, x1 if so
    //otherwise, if rising xref should be set to x1
    //todo: put this if / else into a different method
    if(rising){
        if( ( x2 < x1 ) && ( x2 < x3 ) ){
                xref = x2;
                x1 = x2;
        }
        else{
            xref = x1;
        }
    }

        return rising;
}


/**
* Determine of x1, x2 and x3 indicate valid falling slope for note
*/

bool FilterMotion::isFalling(){
    falling = (delX1 < f1) || (delX2 < f2) || (delX3 < f3);
        return falling;
}


/**
* Update running sum of samples if rising
*/
long int FilterMotion::getXSum(int xk){
    if(rising){
        if(!isFalling()){
            xsum += (xk - xref);
            sampleCount += 1;
        }
    }
    else if (isRising()){
       xsum += (x3 - xref);
       xsum += (x2 - xref);
       sampleCount += 1;
    }
    else{
       xsum = 0;
    }


    return xsum;
}


/**
* Reset filter variables
*/
void FilterMotion::reset(){
    rising = false;
    falling = false;
    xsum = 0;
    xref = 0;
    sampleCount = 2;
}


/**
* See if calculated note is valid / within ranged
*/
bool FilterMotion::noteValid(){
    bool valid = false;
    if(falling){
        valid = (sampleCount <= maxSamples) && (sampleCount >= minSamples) && (xsum/sampleCount) >= aSum;
    }
    return valid;
}

/**
* See if we need to reset filter - if oversampled, out of range..etc
*/

bool FilterMotion::resetNeeded(){

    bool reset_needed = false;

    if(falling){
            reset_needed = true;
    }
    else if(rising){
        reset_needed = sampleCount > maxSamples;
    }
    else{
       reset_needed = false;
    }

    return reset_needed;


}

/**
* See if oversampled during note calculation
*/

bool FilterMotion::isOversampled(){

    return sampleCount >= maxSamples;

}

/**
* See if undersampled during note calculation
*/

bool FilterMotion::isUndersampled(){

     return sampleCount <= minSamples;
}


/**
* Calculate a note from sampled data
*/

int FilterMotion::getNote(int xk){

    bool need_reset = false, valid = false;
    int note = 0, temp = 0;

    updateX(xk);
    getDelX();
    getXSum(xk);
    valid = noteValid();

    note = ((xsum * falling) / sampleCount)*(valid);

    need_reset = resetNeeded();

    if(need_reset){
       reset();
    }

    return note;

}


