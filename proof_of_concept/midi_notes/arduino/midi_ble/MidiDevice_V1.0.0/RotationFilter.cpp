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
#include "RotationFilter.h"


RotationFilter::RotationFilter(void) {

  // todo:?
}

/*
 * Inititalize filter variables
 */
void RotationFilter::init(void){
   reset();
}

/*
* reset: Initiliaze / reset variables
*/
void RotationFilter::reset() {
  
}





