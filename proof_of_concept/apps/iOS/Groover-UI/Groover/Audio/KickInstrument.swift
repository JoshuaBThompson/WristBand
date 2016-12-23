//
//  KickInstrument.swift
//  MidiDevice_TCL_V0.0.0
//
//  Created by Joshua Thompson on 5/20/16.
//  Copyright © 2016 wristband. All rights reserved.
//

//
//  Instrument1Presets.swift
//  MidiDevice_TCL_V0.0.0
//
//  Created by sofiebio on 5/7/16.
//  Copyright © 2016 wristband. All rights reserved.
//

import Foundation
import AudioKit


/****************Kick Instrument 1
 Desc: This synth drum replicates a Kick instrument
 *****************/

class KickInstrument1: SynthInstrument{
    /// Create the synth Kick instrument
    ///
    /// - parameter voiceCount: Number of voices (usually two is plenty for drums)
    ///
    
    override init() {
        super.init()
        note = 60
        name = "Kick Instrument 1"
        sampler.loadWav("Sounds/Kick/kick-1")
        self.avAudioNode = sampler.avAudioNode
    }
    
}


/****************Kick Instrument 2
 Desc: This synth drum replicates a Kick instrument
 *****************/

class KickInstrument2: SynthInstrument{
    /// Create the synth Kick instrument
    ///
    /// - parameter voiceCount: Number of voices (usually two is plenty for drums)
    ///
    
    override init() {
        super.init()
        note = 70
        name = "Kick Instrument 2"
        sampler.loadWav("Sounds/Kick/kick-2")
        self.avAudioNode = sampler.avAudioNode
        
    }
    
}


/****************Kick Instrument 3
 Desc: This synth drum replicates a Kick instrument
 *****************/

class KickInstrument3: SynthInstrument{
    /// Create the synth Kick instrument
    ///
    /// - parameter voiceCount: Number of voices (usually two is plenty for drums)
    ///
    
    override init() {
        super.init()
        note = 80
        name = "Kick Instrument 3"
        sampler.loadWav("Sounds/Kick/kick-3")
        self.avAudioNode = sampler.avAudioNode
    }
    
}



/****************Kick Instrument 4
 Desc: This synth drum replicates a Kick instrument
 *****************/

class KickInstrument4: SynthInstrument{
    /// Create the synth Kick instrument
    ///
    /// - parameter voiceCount: Number of voices (usually two is plenty for drums)
    ///
    
    override init() {
        super.init()
        note = 90
        name = "Kick Instrument 4"
        sampler.loadWav("Sounds/Kick/kick-4")
        self.avAudioNode = sampler.avAudioNode
    }
    
}


