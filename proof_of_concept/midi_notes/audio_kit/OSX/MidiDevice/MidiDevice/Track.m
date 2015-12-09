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
        self.measure = [[Measure alloc] init];
        self.startDate = [NSDate date];
        self.endDate = [NSDate date];
        self.startTime = [_startDate timeIntervalSince1970];
        self.timerStarted = false;
    }
    return self;
}

-(void) reset{
    [self.phrase reset];
    [self stopTimer];
}

-(void) startTimer{
    //start tempo clock
    [self.tempo playTempo];
    self.startDate = [NSDate date];
    self.startTime = [_startDate timeIntervalSince1970];
    self.timerStarted = true;
}

-(void) stopTimer{
    //stop tempo clock
    [self.tempo stopTempo];
    self.startTime = 0;
    self.timerStarted = false;
}

/*
 Get time elapsed since startTimer method called, if method was not called return 0
 */
-(float) getTimeElapsed{
    
    if(self.timerStarted){
        self.endDate = [NSDate date];
        double end = [_endDate timeIntervalSince1970];
        float elapsed = end - self.startTime;
        return elapsed;
    }
    else{
        return 0;
    }
}

/*
 Add notes to the phrase object, a sequences of notes inserted at specific times that can be played back by an
 instrument
 */
-(void) addNote: (AKNote *)note{
    //if timer started get elapsed time and insert note into phrase
    if(self.timerStarted){
        float timeStamp = [self getTimeElapsed];
        [self.phrase addNote: note atTime: timeStamp];
    }
    else{
    // if time not started yet, then insert note at time 0 and then start timer
        [self.phrase addNote: note atTime: 0];
        [self startTimer];
    }
}

@end
