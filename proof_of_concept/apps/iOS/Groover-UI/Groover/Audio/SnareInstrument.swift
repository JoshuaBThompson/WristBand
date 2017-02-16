//
//  SnareInstrument.swift
//  MidiDevice_TCL_V0.0.0
//
//  Created by Joshua Thompson on 5/20/16.
//  Copyright © 2016 wristband. All rights reserved.
//


import Foundation
import AudioKit


/****************Snare Instrument 1
 Desc: This synth drum replicates a Snare instrument
 *****************/

class SnareInstrument1: SynthInstrument{
    /// Create the synth Snare instrument
    ///
    /// - parameter voiceCount: Number of voices (usually two is plenty for drums)
    ///
    
    override init() {
        super.init()
        note = 60
        name = "Snare Instrument 1"
        sampler.loadWav("Sounds/Snare/snare-1")

        self.avAudioNode = sampler.avAudioNode
    }
    
}


/****************Snare Instrument 2
 Desc: This synth drum replicates a Snare instrument
 *****************/

class SnareInstrument2: SynthInstrument{
    /// Create the synth Snare instrument
    ///
    /// - parameter voiceCount: Number of voices (usually two is plenty for drums)
    ///
    
    override init() {
        super.init()
        note = 70
        name = "Snare Instrument 2"
        sampler.loadWav("Sounds/Snare/snare-2")
        self.avAudioNode = sampler.avAudioNode
        
    }
    
}


/****************Snare Instrument 3
 Desc: This synth drum replicates a Snare instrument
 *****************/

class SnareInstrument3: SynthInstrument{
    /// Create the synth Snare instrument
    ///
    /// - parameter voiceCount: Number of voices (usually two is plenty for drums)
    ///
    
    override init() {
        super.init()
        note = 80
        name = "Snare Instrument 3"
        sampler.loadWav("Sounds/Snare/snare-3")
        self.avAudioNode = sampler.avAudioNode
    }
    
}



/****************Snare Instrument 4
 Desc: This synth drum replicates a Snare instrument
 *****************/

class SnareInstrument4: SynthInstrument{
    /// Create the synth Snare instrument
    ///
    /// - parameter voiceCount: Number of voices (usually two is plenty for drums)
    ///
    
    override init() {
        super.init()
        note = 90
        name = "Snare Instrument 4"
        sampler.loadWav("Sounds/Snare/snare-4")
        self.avAudioNode = sampler.avAudioNode
    }
    
}


