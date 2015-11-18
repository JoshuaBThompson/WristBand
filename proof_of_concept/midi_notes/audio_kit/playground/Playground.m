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
@end

@implementation Instrument


- (instancetype)initWithInstrumet: (AKInstrument *)newInstrument
{
    self = [super init];
    _otherInstrument = newInstrument;
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

- (void)startMidiInputHandler {
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(midiNoteOn:) name:AKMidiNoteOnNotification object:nil];
}

- (void)midiNoteOn:(NSNotification *)notif
{
    NSLog(@"Received NOTE ON!! %@", notif.userInfo[@"note"]);
    [_otherInstrument play];
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
    
    AKTambourineNote *note = [[AKTambourineNote alloc] init];

    Instrument *instrument = [[Instrument alloc] initWithInstrumet:tambourine];
    [AKOrchestra addInstrument:instrument];
    [instrument startMidiInputHandler];
    [instrument startListeningOnAllMidiChannels];
    [instrument play];
    
    [self addButtonWithTitle:@"Play Once" block:^{ [tambourine play]; }];
    
    
    

}

@end
