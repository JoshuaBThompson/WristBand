//
//  Track.m
//  MidiDevice
//
//  Created by sofiebio on 12/9/15.
//  Copyright © 2015 wristband. All rights reserved.
//

#import "Track.h"

@implementation Track

//methods
-(id) init{
    self = [super init];
    if(self){
        self.phrase = [AKPhrase phrase];
        self.tempo = [[Tempo alloc] init];
        self.timeSignature = [[TimeSignature alloc] init];
        self.measure = [[Measure alloc] initWithTempoAndTimeSig:self.tempo withTimeSignature:self.timeSignature];
        self.clickTrack = [[ClickTrack alloc] initWithTempoAndTimeSignature:self.tempo Signature:self.timeSignature withMeasure:self.measure];

    }
    return self;
}

-(void) reset{
    [self.phrase reset];
    [self stopTimer];
}

-(void) startTimer{
    //start tempo clock
    [self.clickTrack startTimer];
}

-(void) stopTimer{
    //stop tempo clock
    [self.clickTrack stopTimer];
}


/*
 Add notes to the phrase object, a sequences of notes inserted at specific times that can be played back by an
 instrument
 */
-(void) addNote: (AKNote *)note{
    //if timer started get elapsed time and insert note into phrase
    if(self.clickTrack.timerStarted){
        //get time elapsed of measured loop, will start again at 0 when time = total measure duration
        float timeStamp = [self.clickTrack getMeasureTimeElapsed];
        [self.phrase addNote: note atTime: timeStamp];
        NSLog(@"Added note at time %f", timeStamp);
        
    }
    else{
    // if time not started yet, then insert note at time 0 and then start timer
        [self.phrase addNote: note atTime: 0];
        NSLog(@"Added note at time 0");
        [self startTimer];
    }
}

@end
