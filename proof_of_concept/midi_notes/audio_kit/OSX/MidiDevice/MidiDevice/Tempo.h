//
//  Tempo.h
//  MidiDevice
//
//  Created by sofiebio on 12/9/15.
//  Copyright © 2015 wristband. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AKFoundation.h"

@interface Tempo : NSObject
@property float beatsPerMin;
@property float secPerMin;
@property AKPhrase *phrase;
@property AKTambourineInstrument * instrument;
-(void) playTempo;
-(void) stopTempo;
-(void) initInstrument;

@end
