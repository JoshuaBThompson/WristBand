//
//  ClickTrack.h
//  MidiDevice
//
//  Created by sofiebio on 12/16/15.
//  Copyright © 2015 wristband. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AKFoundation.h"
#import "Tempo.h"
#import "TimeSignature.h"
#import "Measure.h"

@interface ClickTrack : NSObject
@property Tempo * tempo;
@property TimeSignature * timeSignature;
@property Measure * measure;
@property AKPhrase *phrase;
@property AKTambourineInstrument * instrument;
@property float secPerClick;

//time stamp for adding notes to phrase
@property double startTime;
@property bool timerStarted;
@property NSDate * startDate;
@property NSDate * endDate;

-(void) playClickTrack;
-(void) stopClickTrack;
-(void) initInstrument;
-(id) initWithTempoAndTimeSignature: (Tempo *) tempo Signature: (TimeSignature *) timeSignature withMeasure: (Measure *) measure;

-(void) startTimer;
-(void) stopTimer;
-(float) getTimeElapsed;
-(float) getMeasureElapsed;
-(float) getMeasureTimeElapsed;


@end
