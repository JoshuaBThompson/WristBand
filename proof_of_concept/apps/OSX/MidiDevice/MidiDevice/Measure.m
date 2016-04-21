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
    
    float quarterNoteBeatsPerSec = [self.tempo getBeatsPerSec]; //quarter note beats per sec
    float subDivScale = 4.0/self.timeSignature.noteSubDiv; //ex: 4 4th = 1 scale (4/4)
                                                        //ex: 4 8th = 1/2 (4/8)
    float quarterNoteBeatsPerMeasure = (self.timeSignature.beatsPerMeasure) * (subDivScale);
    self.beatsPerMeasure = self.timeSignature.beatsPerMeasure;
    self.totalBeats = self.beatsPerMeasure * self.measureCount;
    self.secPerMeasure = quarterNoteBeatsPerMeasure / quarterNoteBeatsPerSec;
    self.totalDuration = self.secPerMeasure * self.measureCount;
    NSLog(@"secPerMeasure %f / duration %f / measureCount %d", self.secPerMeasure, self.totalDuration, self.measureCount);
}


@end