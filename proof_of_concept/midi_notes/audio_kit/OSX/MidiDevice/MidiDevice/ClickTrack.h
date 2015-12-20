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
@property int currentMeasureCount;
@property int currentBeatInMeasure;
@property float totalTimeElapsed;

//time stamp for adding notes to phrase
@property double startTime;
@property bool timerStarted;
@property NSDate * startDate;
@property NSDate * endDate;

-(void) playClickTrack;
-(void) stopClickTrack;
-(void) initInstrument;
-(id) initWithTempoAndTimeSignature: (Tempo *) tempo Signature: (TimeSignature *) timeSignature withMeasure: (Measure *) measure;

-(void) onTimerTick;
-(void) startTimerTick;
-(void) stopTimerTick;

-(void) startTimer;
-(void) stopTimer;
-(float) getTimeElapsed;
-(float) getMeasureElapsed;
-(float) getMeasureTimeElapsed;

@end


//---------Click track note
@interface ClickTrackNote : AKMandolinNote
//subclass the AKNote to execute callback method from clicktrack when play note is called
-(id) initWithClickTrack: (ClickTrack *)clickTrack;
@property ClickTrack * clickTrack;
@end
