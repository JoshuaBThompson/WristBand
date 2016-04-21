//
//  Track.h
//  MidiDevice
//
//  Created by sofiebio on 12/9/15.
//  Copyright © 2015 wristband. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AKFoundation.h"
#import "Tempo.h"
#import "TimeSignature.h"
#import "Measure.h"
#import "ClickTrack.h"

@interface Track : NSObject
//akphrase to hold notes
@property AKPhrase * phrase;

//tempo to set speed
@property Tempo * tempo;

//click track
@property ClickTrack * clickTrack;

//time signature (ex: 4 4th...etc)
@property TimeSignature * timeSignature;
//measure (ex: how many 4 4ths...etc)
@property Measure * measure;


//methods
-(void) addNote: (AKNote *)note;
-(void) reset;
-(void) startTimer;
-(void) stopTimer;

@end
