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

@interface ClickTrack : NSObject
@property Tempo * tempo;
@property TimeSignature * timeSignature;
@property AKPhrase *phrase;
@property AKTambourineInstrument * instrument;
@property float secPerClick;
-(void) playClickTrack;
-(void) stopClickTrack;
-(void) initInstrument;
-(id) initWithTempoAndTimeSignature: (Tempo *) tempo Signature: (TimeSignature *) timeSignature;


@end
