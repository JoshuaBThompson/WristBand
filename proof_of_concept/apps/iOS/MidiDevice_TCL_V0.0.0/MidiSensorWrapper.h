//
//  MidiSensorWrapper.h
//  MidiDevice_TCL_V0.0.0
//
//  Created by sofiebio on 4/21/16.
//  Copyright © 2016 wristband. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MidiSensorWrapper : NSObject
-(instancetype)init;
-(int)getNoteOnStatus;
-(void)updateStateWith: (int)x andY: (int)y andZ:(int)z andMillisElapsed: (unsigned long)elapsed_ms;
-(void)handleMidiEvents;
-(int)getEventStatus;
-(int)getEventNote;
-(unsigned long) getElapsedTimeMs;

//actions
- (void) setMinDiff: (int)diff;
- (void) setCatchFalling: (int)falling;
- (void) setMinSum: (int)sum;
- (void) setMinFalling: (int)minFalling;
- (void) setSensorInterval: (int)interval;
- (void) setMaxSamples: (int)samples;

@property int count;
@property bool beat;

@end
