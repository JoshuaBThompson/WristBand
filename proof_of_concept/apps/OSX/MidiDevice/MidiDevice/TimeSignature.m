//
//  TimeSignature.m
//  MidiDevice
//
//  Created by sofiebio on 12/9/15.
//  Copyright © 2015 wristband. All rights reserved.
//

#import "TimeSignature.h"

@implementation TimeSignature

-(id) init{
    self = [super init];
    if(self){
        self.noteSubDiv = 4; //quarter note
        self.beatsPerMeasure = 4; //4 quarter notes in a measure
    }
    return self;
}

@end
