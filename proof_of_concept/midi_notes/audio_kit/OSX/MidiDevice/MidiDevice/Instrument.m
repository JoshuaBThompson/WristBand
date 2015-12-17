//
//  Instrument.m
//  MidiDevice
//
//  Created by sofiebio on 12/1/15.
//  Copyright © 2015 wristband. All rights reserved.
//

#import "Instrument.h"

@implementation Instrument


- (instancetype)initWithInstrumet: (AKInstrument *)newInstrument
{
    self = [super init];
    _otherInstrument = newInstrument;
    self.track = [[Track alloc] init];
    _count = 0.0;
    
    _record = FALSE;
    if (self) {
        //todo?
    }
    return self;
}

- (void)recordNotes {
    NSLog(@"Setting Record!!!!!");
    //first turn off any playback or record that might be running
    [self stopRecord];
    
    //now play any recorded notes in the background and start click track
    [self playRecord];
    
    //set record to True since playRecord sets it to False and start recording notes over existing record
    _record = TRUE;
}

- (void) clearTrack {
    NSLog(@"Clearing track notes");
    //stopRecording and then clear track phrase / sequence
    [self stopRecord];
    [self.track reset];
}

- (void)stopRecord {
    _record = FALSE;
    NSLog(@"Stopping record / play");
    [self.track stopTimer];
    [_otherInstrument stopPhrase];
}

- (void)playRecord{
    NSLog(@"Playing recorded note!!!!!");
    _record = FALSE;
    
    //if click track not started yet then start it, otherwise that's it
    //note: this is just a click track and will not affect the playback, we can remove it
    if(!self.track.clickTrack.timerStarted){
        [self.track startTimer];
    }
    
    float measureDuration = self.track.measure.totalDuration;
    [_otherInstrument repeatPhrase:self.track.phrase duration:measureDuration];
    
    
}

- (void)startMidiInputHandler {
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(midiNoteOnWithNotif:) name:AKMidiNoteOnNotification object:nil];
}

- (void)midiNoteOnWithNotif:(NSNotification *)notif
{
    NSLog(@"Received NOTE ON!! %@", notif.userInfo[@"note"]);
    NSLog(@"Record is %hhd!!!!!", _record);
    
    if(_record){
        AKTambourineNote *note = [[AKTambourineNote alloc] init];
        [self.track addNote:note];
        [_otherInstrument play];
    }
    else{
        [_otherInstrument play];
    }
    
}

- (void)midiNoteOn
{
    NSLog(@"Record is %hhd!!!!!", _record);
    
    if(_record){
        
        AKTambourineNote *note = [[AKTambourineNote alloc] init];
        [self.track addNote:note];
        [_otherInstrument play];
    }
    else{
        [_otherInstrument play];
    }
    
}

/*
 Updates tempo object used by track class
 */

- (void)updateTempo: (float)tempoValue{
    self.track.tempo.beatsPerMin = tempoValue;
}

/*
 Updates measures object used by track class
 */

- (void)updateMeasures:(int)measuresValue{
    self.track.measure.measureCount = measuresValue;
    
    //update the other params of the measure object based on the new measure count value
    [self.track.measure updateMeasure];
}



@end
