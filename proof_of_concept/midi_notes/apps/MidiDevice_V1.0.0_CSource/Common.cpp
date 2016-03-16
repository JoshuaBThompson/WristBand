//
//  Common.cpp
//  beatDetectionTest
//
//  Created by sofiebio on 3/9/16.
//  Copyright © 2016 wristband. All rights reserved.
//

#include <stdio.h>
#include "Common.h"
#include <time.h>       /* clock_t, clock, CLOCKS_PER_SEC */

//time functions

//get millisec passed since start of program

unsigned long millis(void){
    
    unsigned long ms_per_sec = 1000;
    clock_t clocks_passed = clock(); //returns cycles of clock
    float sec_passsed = (float)clocks_passed / CLOCKS_PER_SEC; //convert to seconds
    unsigned long ms_passed = sec_passsed * ms_per_sec; //convert to ms
    
    return ms_passed;
}
