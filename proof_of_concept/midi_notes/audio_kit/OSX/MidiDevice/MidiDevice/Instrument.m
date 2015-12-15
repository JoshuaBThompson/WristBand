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
    _record = TRUE;
    [self.track reset];
    [self.track startTimer];
}

- (void)stopRecord {
    _record = FALSE;
    [self.track stopTimer];
}

- (void)playRecord{
    NSLog(@"Playing recorded note!!!!!");
    _record = FALSE;
    [self.track stopTimer];
    [_otherInstrument playPhrase: self.track.phrase];
    
    
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
