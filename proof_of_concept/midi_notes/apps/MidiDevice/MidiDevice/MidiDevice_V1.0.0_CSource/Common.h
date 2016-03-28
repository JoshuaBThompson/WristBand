/*
 Common.h developed by jbthompson.eng@gmail.com
 Date Created: 12/22/2015
 */

#ifndef COMMON_h
#define COMMON_h


/*
 * Common struct used by many of the objects
 */
typedef enum {ACCEL, GYRO, MAG} sources_t;
typedef enum {X, Y, Z} axis_t;


//time functions
static unsigned long global_millis;

void update_global_millis(unsigned long millis_elapsed);

unsigned long millis(void);

#endif //COMMON_h