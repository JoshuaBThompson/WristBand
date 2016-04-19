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


FilterMotion::FilterMotion(void) {

  // initialize variables
    reset();
  
}

/*
* setX1: set the class variable x0 representing the previous data point, usually set to x1 after difference calculation
*/
void FilterMotion::setX0(long int x){
    x0 = x;
}

/*
* setX1: set the class variable x1 representing the most recent data point
*/
void FilterMotion::setX1(long int x){
    x1 = x;
}


/*
* isNote: See if a note is generated with new data point
*/
bool FilterMotion::isNote(long int x){  
    
    //-------Get x0, x1 and difference between them
    setX1(x);
    diff = x1 - x0; //get difference between current and prev samples to see if acceleration is rising or falling
    setX0(x1); //update x0 for next sample
    
    
    //-------Get rising, falling and sample count
    rising = rising || (diff >= MinDiff); //rising if rising previously or current rising detected
    
    if(rising){
      samples++; //only increment samples if rising / falling
      falling = diff <= MinFalling;
      
      if(falling){
        samples++;
      }
    }
     
    
    //--------Get running sum
    //If not rising then set to 0
    xSum = (xSum + diff) * rising;
    
    //--------Get note
    if(diff <= CatchFalling && !note && !rising){
      //catch a large falling data point that might have been missed
      //If the fall is large enough then this is probably a note
      note = true;
    }
    else{
      //normal note should be interpreted when total xsum is close to initial x0 recorded when first rise detected
      //rising and falling must both be set to indicate a complete note
      note = (xSum <= MinSum) && rising && falling;
    }
    
    //-------Check for reset condition
    if(note || (samples >= MaxSamples)){
        //reset all if note is valid or max samples detected
        xSum = 0; 
        samples = 0;
        rising = 0;
        falling = 0;
    }
    
    return note;
}


/*
* reset: Initiliaze / reset variables
*/
void FilterMotion::reset() {
    falling = false;
    rising = false;
    note = false;
    x1 = x0 = xSum = diff = 0;
    samples = 0;
  
}





