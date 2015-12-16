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
        self.clickTrack = [[ClickTrack alloc] initWithTempoAndTimeSignature:self.tempo Signature:self.timeSignature];
        self.measure = [[Measure alloc] initWithTempoAndTimeSig:self.tempo withTimeSignature:self.timeSignature];
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
    [self.clickTrack playClickTrack];
    self.startDate = [NSDate date];
    self.startTime = [_startDate timeIntervalSince1970];
    self.timerStarted = true;
}

-(void) stopTimer{
    //stop tempo clock
    [self.clickTrack stopClickTrack];
    self.startTime = 0;
    self.timerStarted = false;
}

/*
 Get elapsed measure
 */
-(float) getMeasureElapsed{
    return 0;
}

/*
 Get the time elapsed within the measure bounds
 */
-(float) getMeasureTimeElapsed{
    float totalElapsedTime = [self getTimeElapsed];
    //get measure time elapsed
    float measureTimeElapsed = 0.0;
    if(totalElapsedTime <= self.measure.totalDuration){
        measureTimeElapsed = totalElapsedTime;
    }
    else{
        //get modulus of two float numbers ex: 220.4 sec / 100.0 sec = 20.4
        //this will be the time elapsed of the total measure duration
        measureTimeElapsed = fmod(totalElapsedTime, self.measure.totalDuration);
    }
    return measureTimeElapsed;
    
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
        //get time elapsed of measured loop, will start again at 0 when time = total measure duration
        float timeStamp = [self getMeasureTimeElapsed];
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
