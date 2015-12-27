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


RotationFilter::RotationFilter(IMUFilter * imuFilterPtr) {

  // todo:?
  imuFilter = imuFilterPtr;
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

/*
 * Update rotation angle from imu data
 */

void RotationFilter::updateState(void){
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





