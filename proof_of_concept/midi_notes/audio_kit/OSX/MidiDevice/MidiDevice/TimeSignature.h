//
//  TimeSignature.h
//  MidiDevice
//
//  Created by sofiebio on 12/9/15.
//  Copyright © 2015 wristband. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TimeSignature : NSObject
@property int noteSubDiv; //ex: 1/4 note
@property int beatsPerMeasure; //ex: 4 X 1/4
@end
