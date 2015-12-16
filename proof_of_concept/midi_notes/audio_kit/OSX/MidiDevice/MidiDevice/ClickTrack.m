//
//  ClickTrack.m
//  MidiDevice
//
//  Created by sofiebio on 12/16/15.
//  Copyright © 2015 wristband. All rights reserved.
//

//
//  Tempo.m
//  MidiDevice
//
//  Created by sofiebio on 12/9/15.
//  Copyright © 2015 wristband. All rights reserved.
//

#import "ClickTrack.h"

@implementation ClickTrack
-(id) initWithTempoAndTimeSignature:(Tempo *)tempo Signature:(TimeSignature *)timeSignature{
    self = [super init];
    if(self){
        self.timeSignature = timeSignature;
        self.tempo = tempo;
        
        self.secPerClick = 0.0;
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


-(void) playClickTrack{
    [self.phrase reset];
    float secPerBeat = self.tempo.secPerMin / self.tempo.beatsPerMin;
    
    //sec per click = sec per beat *  standard quarter note (4.0) / time signature note
    //ex: if time signature = 4/8 then sec per click = sec per beat * 4 / 8
    self.secPerClick = secPerBeat * 4.0/self.timeSignature.noteSubDiv;
    float startTime = 0.0;
    int totalClicks = self.timeSignature.beatsPerMeasure;
    
    for(int i = 0; i<totalClicks; i++){
        AKMandolinNote *note = [[AKMandolinNote alloc] init];
        note.frequency.value = 440;
        [self.phrase addNote:note atTime:startTime + i*self.secPerClick];
        NSLog(@"added click track note %d", i);
    }
    
    [self.instrument repeatPhrase:self.phrase duration:totalClicks*self.secPerClick];
}
-(void) stopClickTrack{
    NSLog(@"Stoping click track");
    [self.instrument stopPhrase];
}
@end

