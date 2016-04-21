//
//  ClickTrack.m
//  MidiDevice
//
//  Created by sofiebio on 12/16/15.
//  Copyright © 2015 wristband. All rights reserved.
//

//
//  Tempo.m
//  MidiDevice
//
//  Created by sofiebio on 12/9/15.
//  Copyright © 2015 wristband. All rights reserved.
//

#import "ClickTrack.h"

@implementation ClickTrack{
    NSTimer *clickTimer;
    int clickCounter;
}
-(id) initWithTempoAndTimeSignature:(Tempo *)tempo Signature:(TimeSignature *)timeSignature withMeasure: (Measure *) measure{
    self = [super init];
    if(self){
        self.timeSignature = timeSignature;
        self.tempo = tempo;
        self.measure = measure;
        self.startDate = [NSDate date];
        self.endDate = [NSDate date];
        self.startTime = [self.startDate timeIntervalSince1970];
        self.timerStarted = false;
        clickCounter = 0;
        self.secPerClick = 0.0;
        self.phrase = [AKPhrase phrase];
        [self initInstrument];
    }
    return self;
}

-(void) onTimerTick{
    //self.currentMeasureCount = [self getMeasureElapsed];
    clickCounter++;
    if(clickCounter > self.measure.totalBeats){
        clickCounter = 1;
    }
    
    //self.totalTimeElapsed = clickCounter * self.secPerClick;
    self.currentMeasureCount = clickCounter / self.measure.beatsPerMeasure;
    self.currentBeatInMeasure = clickCounter;
}

-(void) stopTimerTick{
    //stop timer that gets measure count
    [clickTimer invalidate];
    clickTimer = nil;
    clickCounter = 0;
    self.currentMeasureCount = 0;
    self.currentBeatInMeasure = 0;
    self.startTime = 0;
    self.timerStarted = false;
}

-(void) startTimerTick{
    NSLog(@"Starting timer tick at %f sec per click", self.secPerClick);
    NSLog(@"total beats %d", self.measure.totalBeats);
    self.startDate = [NSDate date];
    self.startTime = [_startDate timeIntervalSince1970];
    self.timerStarted = true;
    clickTimer = [NSTimer scheduledTimerWithTimeInterval: self.secPerClick
                                                  target: self
                                                selector:@selector(onTimerTick)
                                                userInfo: nil repeats:YES];
}

-(void)initInstrument{
    self.instrument = [[AKTambourineInstrument alloc] initWithNumber:2];
    
    self.instrument.amplitude.minimum = 0.25;
    self.instrument.amplitude.maximum = 0.75;
    
    //self.instrument.bodySize.minimum = 0.25;
    //self.instrument.bodySize.maximum = 0.6;
    [AKOrchestra addInstrument:self.instrument];
    
    
    AKAmplifier *amp = [[AKAmplifier alloc] initWithInput:self.instrument.output];
    amp.instrumentNumber = 3;
    [AKOrchestra addInstrument:amp];
    [amp start];
}


-(void) playClickTrack{
    [self.phrase reset];
    float secPerBeat = self.tempo.secPerMin / self.tempo.beatsPerMin;
    
    //sec per click = sec per beat *  standard quarter note (4.0) / time signature note
    //ex: if time signature = 4/8 then sec per click = sec per beat * 4 / 8
    self.secPerClick = secPerBeat * 4.0/self.timeSignature.noteSubDiv;
    float startTime = 0.0;
    int totalClicks = self.timeSignature.beatsPerMeasure;
    
    for(int i = 1; i<=totalClicks; i++){
        ClickTrackNote *note = [[ClickTrackNote alloc] initWithClickTrack:self];
        note.frequency.value = 440;
        [self.phrase addNote:note atTime:startTime + i*self.secPerClick];
    }
    
    [self.instrument repeatPhrase:self.phrase duration:totalClicks*self.secPerClick];
}
-(void) stopClickTrack{
    NSLog(@"Stopping click track");
    [self.instrument stopPhrase];
}

/*
 Get time elapsed since startTimer method called, if method was not called return 0
 */
-(float) getTimeElapsed{
    float elapsed = 0;
    
    if(self.timerStarted){
        self.endDate = [NSDate date];
        double end = [_endDate timeIntervalSince1970];
        elapsed = end - self.startTime;
    }
    self.totalTimeElapsed = elapsed;
    return elapsed;
}

/*
 Get elapsed measure
 */
-(float) getMeasureElapsed{
    float currentTimeInMeasure = roundf([self getMeasureTimeElapsed]);
    NSLog(@"Current time in measure %f", currentTimeInMeasure);
    self.currentBeatInMeasure = currentTimeInMeasure + 1;
    //current measure = int (current time) / int (time of 1 measure)
    //currentTimeInMeasure + 1 since current time in measure starts at 0 (0,1,2,3...etc)
    int currentMeasure = (currentTimeInMeasure + 1) / self.measure.secPerMeasure;
    return currentMeasure;
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

-(void) startTimer{
    //start tempo clock
    [self playClickTrack];
    //start timer that updates current measure count
    [self startTimerTick];
}

-(void) stopTimer{
    //stop tempo clock
    [self stopClickTrack];
    
    //stop timer that updates current measure count
    [self stopTimerTick];
}

@end

//---------Click track note
@implementation ClickTrackNote
-(id)initWithClickTrack:(ClickTrack *)clickTrack{
    self = [super init];
    if(self){
        self.clickTrack = clickTrack;
    }
    return self;
}

-(void)play{
    [super play];
    //[self.clickTrack getMeasureElapsed];
}

@end

