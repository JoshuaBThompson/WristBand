//
//  Measure.m
//  MidiDevice
//
//  Created by sofiebio on 12/9/15.
//  Copyright © 2015 wristband. All rights reserved.
//

#import "Measure.h"

@implementation Measure

-(id) initWithTempoAndTimeSig:(Tempo *)tempo withTimeSignature:(TimeSignature *)timeSignature{
    self = [super init];
    if(self){
        self.measureCount = 1;
        self.tempo = tempo;
        self.timeSignature = timeSignature;
        [self updateMeasure];
    }
    return self;
}

-(void) updateMeasure{
    //secPerMeasure = beatsPerMeasure / beatsPerSec
    //total duration = secPerMeasure * measureCount;
    
    float beatsPerSec = [self.tempo getBeatsPerSec];
    float subDivScale = self.timeSignature.beatsPerMeasure / self.timeSignature.noteSubDiv; //ex: 4 4th = 1 scale (4/4)
                                                                                            //ex: 4 8th = 1/2 (4/8)
    float beatsPerMeasure = (self.timeSignature.beatsPerMeasure) * (subDivScale);
    self.secPerMeasure = beatsPerMeasure / beatsPerSec;
    self.totalDuration = self.secPerMeasure * self.measureCount;
}

@end
