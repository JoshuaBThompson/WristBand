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
    _phrase = [AKPhrase phrase];
    _count = 0.0;
    _startDate = [NSDate date];
    _endDate = [NSDate date];
    _start = [_startDate timeIntervalSince1970];
    
    _record = FALSE;
    if (self) {
        //[self enableParameterLog:@"note number " parameter:self.note.notenumber timeInterval:1000];
        //[self enableParameterLog:@"frequency   " parameter:self.note.frequency timeInterval:1000];
        //[self enableParameterLog:@"velocity    " parameter:self.note.velocity timeInterval:1000];
        //[self enableParameterLog:@"modulation  " parameter:self.note.modulation timeInterval:0.1];
        //[self enableParameterLog:@"pitch bend  " parameter:self.note.pitchBend timeInterval:0.1];
        //[self enableParameterLog:@"aftertouch  " parameter:self.note.aftertouch timeInterval:0.1];
        
    }
    return self;
}

- (void)recordNotes {
    NSLog(@"Setting Record!!!!!");
    _record = TRUE;
    // do stuff...
    _startDate = [NSDate date];
    _start = [_startDate timeIntervalSince1970];
    [_phrase reset];
    
}

- (void)playRecord{
    NSLog(@"Playing recorded note!!!!!");
    _record = FALSE;
    
    [_otherInstrument playPhrase:_phrase];
    
    
}

- (void)startMidiInputHandler {
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(midiNoteOn:) name:AKMidiNoteOnNotification object:nil];
}

- (void)midiNoteOn:(NSNotification *)notif
{
    NSLog(@"Received NOTE ON!! %@", notif.userInfo[@"note"]);
    NSLog(@"Record is %hhd!!!!!", _record);
    
    if(_record){
        
        // do stuff...
        _endDate = [NSDate date];
        double end = [_endDate timeIntervalSince1970];
        float timeInterval = end - _start;
        NSLog(@"Recording note at %f", timeInterval);
        AKTambourineNote *note = [[AKTambourineNote alloc] init];
        [_phrase addNote: note atTime: timeInterval];
    }
    else{
        [_otherInstrument play];
    }
    
}

@end
