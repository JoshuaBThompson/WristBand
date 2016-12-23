//
//  HatInstrument.swift
//  MidiDevice_TCL_V0.0.0
//
//  Created by Joshua Thompson on 5/20/16.
//  Copyright © 2016 wristband. All rights reserved.
//



import Foundation
import AudioKit


/****************Hat Instrument 1
 Desc: This synth drum replicates a Hat instrument
 *****************/

class HatInstrument1: SynthInstrument{
    /// Create the synth Hat instrument
    ///
    /// - parameter voiceCount: Number of voices (usually two is plenty for drums)
    ///
    
    init(library_num: Int = 0) {
        super.init()
        note = 60
        name = "Hat Instrument 1"
        sampler.loadWav("Sounds/Hat/hat-1")
        self.avAudioNode = sampler.avAudioNode
    }
    
}


/****************Hat Instrument 2
 Desc: This synth drum replicates a Hat instrument
 *****************/

class HatInstrument2: SynthInstrument{
    /// Create the synth Hat instrument
    ///
    /// - parameter voiceCount: Number of voices (usually two is plenty for drums)
    ///
    
    init(library_num: Int = 0) {
        super.init()
        note = 70
        name = "Hat Instrument 2"
        sampler.loadWav("Sounds/Hat/hat-2")
        self.avAudioNode = sampler.avAudioNode
        
    }
    
}


/****************Hat Instrument 3
 Desc: This synth drum replicates a Hat instrument
 *****************/

class HatInstrument3: SynthInstrument{
    /// Create the synth Hat instrument
    ///
    /// - parameter voiceCount: Number of voices (usually two is plenty for drums)
    ///
    
    init(library_num: Int = 0) {
        super.init()
        note = 80
        name = "Hat Instrument 3"
        sampler.loadWav("Sounds/Hat/hat-3")
        self.avAudioNode = sampler.avAudioNode
    }
    
}



/****************Hat Instrument 4
 Desc: This synth drum replicates a Hat instrument
 *****************/

class HatInstrument4: SynthInstrument{
    /// Create the synth Hat instrument
    ///
    /// - parameter voiceCount: Number of voices (usually two is plenty for drums)
    ///
    
    init(library_num: Int = 0) {
        super.init()
        note = 90
        name = "Hat Instrument 4"
        sampler.loadWav("Sounds/Hat/hat-4")
        self.avAudioNode = sampler.avAudioNode
    }
    
}


