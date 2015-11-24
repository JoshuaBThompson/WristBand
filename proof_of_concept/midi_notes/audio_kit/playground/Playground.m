//
//  MidiInstrumentPlayground.m
//  AudioKit
//
//  Created by Aurelius Prochazka on 6/17/15. (But it feels like Halloween!)
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "Playground.h"

@interface Instrument : AKMidiInstrument
@property (weak) AKInstrument * otherInstrument;
@property NSNumber * record;
@property AKPhrase * phrase;
@property float count;
@property double start;
@property NSDate * startDate;
@property NSDate * endDate;
@end

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
    
    _record = [NSNumber numberWithBool:@NO];
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
    _record = @YES;
    // do stuff...
    _startDate = [NSDate date];
    _start = [_startDate timeIntervalSince1970];
    [_phrase reset];
    
}

- (void)playRecord{
    NSLog(@"Playing recorded note!!!!!");
    _record = @NO;
    
    [_otherInstrument playPhrase:_phrase];
    
    
}

- (void)startMidiInputHandler {
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(midiNoteOn:) name:AKMidiNoteOnNotification object:nil];
}

- (void)midiNoteOn:(NSNotification *)notif
{
    NSLog(@"Received NOTE ON!! %@", notif.userInfo[@"note"]);
    NSLog(@"Record is %@!!!!!", _record);
    
    if([_record isEqualToValue:@YES]){
        
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

@implementation Playground

- (void) setup
{
    [super setup];
    
}

- (void)run
{
    [super run];
    
    AKTambourineInstrument * tambourine = [[AKTambourineInstrument alloc] initWithNumber:1];
    [AKOrchestra addInstrument:tambourine];
    
    AKAmplifier *amp = [[AKAmplifier alloc] initWithInput:tambourine.output];
    amp.instrumentNumber = 2;
    [AKOrchestra addInstrument:amp];
    [amp start];
    
    
    Instrument *instrument = [[Instrument alloc] initWithInstrumet:tambourine];
    [AKOrchestra addInstrument:instrument];
    [instrument startMidiInputHandler];
    [instrument startListeningOnAllMidiChannels];
    [instrument play];
    
    
    [self addButtonWithTitle:@"Play Once" block:^{ [tambourine play]; }];
    [self addButtonWithTitle:@"Record" block:^{ [instrument recordNotes]; }];
    [self addButtonWithTitle:@"Play" block:^{ [instrument playRecord]; }];
    
    
    
    
}

@end
