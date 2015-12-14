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

@interface Track : NSObject
//akphrase to hold notes
@property AKPhrase * phrase;

//tempo to set speed
@property Tempo * tempo;
//time signature (ex: 4 4th...etc)
@property TimeSignature * timeSignature;
//measure (ex: how many 4 4ths...etc)
@property Measure * measure;

//time stamp for adding notes to phrase
@property double startTime;
@property bool timerStarted;
@property NSDate * startDate;
@property NSDate * endDate;

//methods
-(void) addNote: (AKNote *)note;
-(void) reset;
-(void) startTimer;
-(void) stopTimer;
-(float) getTimeElapsed;
-(float) getMeasureElapsed;
-(float) getMeasureTimeElapsed;

@end
