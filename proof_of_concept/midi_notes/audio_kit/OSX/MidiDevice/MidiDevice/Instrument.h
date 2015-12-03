//
//  Instrument.h
//  MidiDevice
//
//  Created by sofiebio on 12/1/15.
//  Copyright © 2015 wristband. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AKFoundation.h"


@interface Instrument : AKMidiInstrument
    @property (weak) AKInstrument * otherInstrument;
    @property BOOL record;
    @property AKPhrase * phrase;
    @property float count;
    @property double start;
    @property NSDate * startDate;
    @property NSDate * endDate;

    //methods
- (instancetype)initWithInstrumet: (AKInstrument *)newInstrument;
- (void)recordNotes;
- (void)playRecord;
- (void)startMidiInputHandler;
- (void)midiNoteOn;
@end