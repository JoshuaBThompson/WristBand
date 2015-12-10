//
//  Tempo.m
//  MidiDevice
//
//  Created by sofiebio on 12/9/15.
//  Copyright © 2015 wristband. All rights reserved.
//

#import "Tempo.h"

@implementation Tempo
-(id) init{
    self = [super init];
    if(self){
        self.beatsPerMin = 60.0; //default tempo
        self.secPerMin = 60.0;
        self.beatsPerSec = self.beatsPerMin / self.secPerMin;
        self.phrase = [AKPhrase phrase];
        [self initInstrument];
    }
    return self;
}

-(void)initInstrument{
    self.instrument = [[AKTambourineInstrument alloc] initWithNumber:2];
    
    self.instrument.amplitude.minimum = 0.25;
    self.instrument.amplitude.maximum = 0.75;
    
    //self.instrument.bodySize.minimum = 0.25;
    //self.instrument.bodySize.maximum = 0.6;
    [AKOrchestra addInstrument:self.instrument];
    
    
    AKAmplifier *amp = [[AKAmplifier alloc] initWithInput:self.instrument.output];
    amp.instrumentNumber = 3;
    [AKOrchestra addInstrument:amp];
    [amp start];
}

-(float) getBeatsPerSec{
    float beatsPerSec = self.beatsPerMin / self.secPerMin;
    self.beatsPerSec = beatsPerSec;
    return beatsPerSec;
}

-(void) playTempo{
    [self.phrase reset];
    float secPerBeat = self.secPerMin / self.beatsPerMin;
    float startTime = 0.0;
    float beatNumber = 0;
    AKMandolinNote *note1 = [[AKMandolinNote alloc] init];
    note1.frequency.value = 440;
    [self.phrase addNote:note1 atTime:startTime + beatNumber*secPerBeat];
    beatNumber++;
    
    AKMandolinNote *note2 = [[AKMandolinNote alloc] init];
    note2.frequency.value = 440;
    [self.phrase addNote:note2 atTime:startTime + beatNumber*secPerBeat];
    beatNumber++;
    
    AKMandolinNote *note3 = [[AKMandolinNote alloc] init];
    note3.frequency.value = 440;
    [self.phrase addNote:note3 atTime: startTime + beatNumber*secPerBeat];
    beatNumber++;
    
    AKMandolinNote *note4 = [[AKMandolinNote alloc] init];
    note4.frequency.value = 440;
    [self.phrase addNote:note4 atTime: startTime + beatNumber*secPerBeat];
    
    [self.instrument repeatPhrase:self.phrase duration:4*secPerBeat];
}
-(void) stopTempo{
    NSLog(@"Stoping tempo");
    [self.instrument stopPhrase];
}
@end
