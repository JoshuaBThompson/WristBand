//
//  Tempo.m
//  MidiDevice
//
//  Created by sofiebio on 12/9/15.
//  Copyright © 2015 wristband. All rights reserved.
//

#import "Tempo.h"

@implementation Tempo
-(id) init{
    self = [super init];
    if(self){
        self.beatsPerMin = 60.0; //default tempo
        self.secPerMin = 60.0;
        self.beatsPerSec = self.beatsPerMin / self.secPerMin;
    }
    return self;
}

-(float) getBeatsPerSec{
    float beatsPerSec = self.beatsPerMin / self.secPerMin;
    self.beatsPerSec = beatsPerSec;
    return beatsPerSec;
}


@end
