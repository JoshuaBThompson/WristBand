//
//  MidiSensorWrapper.m
//  MidiDevice_TCL_V0.0.0
//
//  Created by sofiebio on 4/21/16.
//  Copyright © 2016 wristband. All rights reserved.
//


#import "MidiSensorWrapper.h"
#include "MidiSensor.h"

@interface MidiSensorWrapper()
@property MidiSensor * sensor;
@property midi_event_t midiEvent;
@property midi_event_t prevMidiEvent;

@end

@implementation MidiSensorWrapper
- (instancetype)init
{
    if (self = [super init]) {
        self.sensor = new MidiSensor();
        self.sensor->init();
    }
    return self;
}

- (int)getNoteOnStatus
{
    return self.sensor->model.noteOn.note.statusByte;
}

- (void)updateStateWith: (int)x andY: (int)y andZ:(int)z andMillisElapsed: (unsigned long)elapsed_ms
{
    self.sensor->updateState(x, y, z, elapsed_ms);
}

- (void)handleMidiEvents
{
    
    if(!self.sensor->midiEventQueue.empty()){
        self.beat = true;
        self.midiEvent = self.sensor->readEvent();
        
        if(self.midiEvent.statusByte == self.prevMidiEvent.statusByte){
            self.count++;
        }
        else{
            self.count++;
        }
        self.prevMidiEvent = self.midiEvent;
        
    }
    else{
        self.beat = false;
    }
}

- (int) getEventNote
{
    return self.midiEvent.dataByte1;
    
}

- (int) getEventStatus
{
    return self.midiEvent.statusByte;
}


- (unsigned long) getElapsedTimeMs
{
    
    //return current program time in millisec
    return self.sensor->model.elapsedTime;
}

//actions
- (void) setMinDiff: (int)min
{
    self.sensor->motionFilter.beatFilter.model.minDiff= min;
}
- (void) setCatchFalling: (int)falling
{
    self.sensor->motionFilter.beatFilter.model.catchFalling = falling;
}
- (void) setMinSum: (int)sum
{
    self.sensor->motionFilter.beatFilter.model.minSum= sum;
}
- (void) setMinFalling: (int)minFalling
{
    self.sensor->motionFilter.beatFilter.model.minFalling= minFalling;
}
- (void) setSensorInterval: (int)interval
{
    self.sensor->model.intervalTime = interval;
}

- (void) setMaxSamples:(int)samples
{
    self.sensor->motionFilter.beatFilter.model.maxSamples = samples;
}


@end


