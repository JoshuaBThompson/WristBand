/*
Common.h developed by jbthompson.eng@gmail.com
Date Created: 12/22/2015
*/

#ifndef COMMON_H__
#define COMMON_H__

#include "Arduino.h"

/*
 * Common struct used by many of the objects
 */
typedef enum {ACCEL, GYRO, MAG} sources_t;
typedef enum {X, Y, Z} axis_t;

#endif //COMMON_H_