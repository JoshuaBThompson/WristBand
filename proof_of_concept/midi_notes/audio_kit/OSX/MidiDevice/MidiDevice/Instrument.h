//
//  Instrument.h
//  MidiDevice
//
//  Created by sofiebio on 12/1/15.
//  Copyright © 2015 wristband. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AKFoundation.h"
#import "Track.h"


@interface Instrument : AKMidiInstrument
    @property (weak) AKInstrument * otherInstrument;
    @property BOOL record;
    @property float count;

    //track
    @property Track * track;


    //methods
- (instancetype)initWithInstrumet: (AKInstrument *)newInstrument;
- (void)recordNotes;
- (void)playRecord;
- (void)startMidiInputHandler;
- (void)midiNoteOn;
- (void)updateTempo: (float)tempoValue;
@end