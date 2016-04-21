/*
BeanIMU.h developed by jbthompson.eng@gmail.com
Date Created: 12/22/2015
*/

#ifndef BeanIMU_h
#define BeanIMU_h

#include "Arduino.h"

/*
 * BeanIMU class
 */

class BeanIMU
{
  public:
    //Methods
    BeanIMU(void);
    void init(void);
    void getRawValues(int * rawValuesArray); 
};

#endif // BeanIMU_h




