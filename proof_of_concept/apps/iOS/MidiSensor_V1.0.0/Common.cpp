//
//  Common.cpp
//  beatDetectionTest
//
//  Created by sofiebio on 3/9/16.
//  Copyright © 2016 wristband. All rights reserved.
//

#include "Common.h"


//time functions

//get millisec passed since start of program

void update_global_millis(unsigned long millis_elapsed){
    global_millis += millis_elapsed;
}

unsigned long millis(void){
    
    return global_millis;
}
