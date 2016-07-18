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
    
    init(voiceCount: Int) {
        super.init(instrumentVoice: KickInstrument1Voice(), voiceCount: voiceCount)
        note = 60
        name = "Kick Instrument 1"
    }
    
    /// Start playback of a particular voice with MIDI style note and velocity
    ///
    /// - parameter voice: Voice to start
    /// - parameter note: MIDI Note Number
    /// - parameter velocity: MIDI Velocity (0-127)
    ///
    override func playVoice(voice: AKVoice, note: Int, velocity: Int) {
        voice.start()
    }
    
    /// Stop playback of a particular voice
    ///
    /// - parameter voice: Voice to stop
    /// - parameter note: MIDI Note Number
    ///
    override func stopVoice(voice: AKVoice, note: Int) {
        voice.stop()
    }
    
}

/// Kick Instrument 1 Voice
class KickInstrument1Voice: SynthInstrumentVoice{
    override init(){
        
        super.init()
        sampler = AKSampler()
        sampler.loadWav("Sounds/Kick/kick-1")
        self.avAudioNode = sampler.avAudioNode
    }
    
    override func start() {
        sampler.playNote()
    }
    
    override func stop(){
        //sampler.stopNote()
    }
    
    override func duplicate() -> AKVoice {
        let copy = KickInstrument1Voice()
        return copy
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
    
    init(voiceCount: Int) {
        super.init(instrumentVoice: KickInstrument2Voice(), voiceCount: voiceCount)
        note = 70
        name = "Kick Instrument 2"
        
    }
    
    /// Start playback of a particular voice with MIDI style note and velocity
    ///
    /// - parameter voice: Voice to start
    /// - parameter note: MIDI Note Number
    /// - parameter velocity: MIDI Velocity (0-127)
    ///
    override func playVoice(voice: AKVoice, note: Int, velocity: Int) {
        voice.start()
    }
    
    /// Stop playback of a particular voice
    ///
    /// - parameter voice: Voice to stop
    /// - parameter note: MIDI Note Number
    ///
    override func stopVoice(voice: AKVoice, note: Int) {
        voice.stop()
    }
    
}

/// Kick Instrument 2 Voice
class KickInstrument2Voice: SynthInstrumentVoice{
    override init(){
        
        super.init()
        sampler = AKSampler()
        sampler.loadWav("Sounds/Kick/kick-2")
        self.avAudioNode = sampler.avAudioNode
    }
    
    override func start() {
        sampler.playNote()
    }
    
    override func stop(){
        //sampler.stopNote()
    }
    
    override func duplicate() -> AKVoice {
        let copy = KickInstrument2Voice()
        return copy
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
    
    init(voiceCount: Int) {
        super.init(instrumentVoice: KickInstrument3Voice(), voiceCount: voiceCount)
        note = 80
        name = "Kick Instrument 3"
        
    }
    
    /// Start playback of a particular voice with MIDI style note and velocity
    ///
    /// - parameter voice: Voice to start
    /// - parameter note: MIDI Note Number
    /// - parameter velocity: MIDI Velocity (0-127)
    ///
    override func playVoice(voice: AKVoice, note: Int, velocity: Int) {
        voice.start()
    }
    
    /// Stop playback of a particular voice
    ///
    /// - parameter voice: Voice to stop
    /// - parameter note: MIDI Note Number
    ///
    override func stopVoice(voice: AKVoice, note: Int) {
        voice.stop()
    }
    
}

/// Kick Instrument 3 Voice
class KickInstrument3Voice: SynthInstrumentVoice{
    override init(){
        
        super.init()
        sampler = AKSampler()
        sampler.loadWav("Sounds/Kick/kick-3")
        self.avAudioNode = sampler.avAudioNode
    }
    
    override func start() {
        sampler.playNote()
    }
    
    override func stop(){
        //sampler.stopNote()
    }
    
    override func duplicate() -> AKVoice {
        let copy = KickInstrument3Voice()
        return copy
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
    
    init(voiceCount: Int) {
        super.init(instrumentVoice: KickInstrument4Voice(), voiceCount: voiceCount)
        note = 90
        name = "Kick Instrument 4"
        
    }
    
    /// Start playback of a particular voice with MIDI style note and velocity
    ///
    /// - parameter voice: Voice to start
    /// - parameter note: MIDI Note Number
    /// - parameter velocity: MIDI Velocity (0-127)
    ///
    override func playVoice(voice: AKVoice, note: Int, velocity: Int) {
        voice.start()
    }
    
    /// Stop playback of a particular voice
    ///
    /// - parameter voice: Voice to stop
    /// - parameter note: MIDI Note Number
    ///
    override func stopVoice(voice: AKVoice, note: Int) {
        voice.stop()
    }
    
}

/// Kick Instrument 4 Voice
class KickInstrument4Voice: SynthInstrumentVoice{
    override init(){
        
        super.init()
        sampler = AKSampler()
        sampler.loadWav("Sounds/Kick/kick-4")
        self.avAudioNode = sampler.avAudioNode
    }
    
    override func start() {
        sampler.playNote()
    }
    
    override func stop(){
        //sampler.stopNote()
    }
    
    override func duplicate() -> AKVoice {
        let copy = KickInstrument4Voice()
        return copy
    }
}


