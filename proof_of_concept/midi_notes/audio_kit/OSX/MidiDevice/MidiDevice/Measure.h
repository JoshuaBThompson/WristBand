//
//  Measure.h
//  MidiDevice
//
//  Created by sofiebio on 12/9/15.
//  Copyright © 2015 wristband. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Tempo.h"
#import "TimeSignature.h"

@interface Measure : NSObject
@property int measureCount;
@property float secPerMeasure;
@property float totalDuration;
@property int totalBeats;
@property int beatsPerMeasure;
@property TimeSignature * timeSignature;
@property Tempo * tempo;

-(id) initWithTempoAndTimeSig: (Tempo *) tempo withTimeSignature: (TimeSignature *) timeSignature;
-(void) updateMeasure;
@end
