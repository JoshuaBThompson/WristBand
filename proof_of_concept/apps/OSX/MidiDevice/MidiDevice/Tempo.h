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
@property float beatsPerSec;
@property float secPerMin;

-(float) getBeatsPerSec;

@end