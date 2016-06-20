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
 Desc: This synth drum replicates a snare instrument
 *****************/

class SnareInstrument1: SynthInstrument{
    /// Create the synth snare instrument
    ///
    /// - parameter voiceCount: Number of voices (usually two is plenty for drums)
    ///
    
    init(voiceCount: Int) {
        super.init(instrumentVoice: SnareInstrument1Voice(), voiceCount: voiceCount)
        note = 60
        
    }
    
    /// Start playback of a particular voice with MIDI style note and velocity
    ///
    /// - parameter voice: Voice to start
    /// - parameter note: MIDI Note Number
    /// - parameter velocity: MIDI Velocity (0-127)
    ///
    override func playVoice(voice: AKVoice, note: Int, velocity: Int) {
        print("starting snare voice")
        voice.start()
        
    }
    
    /// Stop playback of a particular voice
    ///
    /// - parameter voice: Voice to stop
    /// - parameter note: MIDI Note Number
    ///
    override func stopVoice(voice: AKVoice, note: Int) {
        print("stopping snare voice")
        voice.stop()
        
    }
    
}

/// Snare Instrument 1 Voice
class SnareInstrument1Voice: SynthInstrumentVoice{
    var sampler: AKSampler!
    override init(){
        sampler = AKSampler()
        sampler.loadWav("Sounds/Snare/snare-1")
        //sampler.loadWav("Sounds/cheeb-bd")
        super.init()
        self.avAudioNode = sampler.avAudioNode
    }
    
    override func start() {
        sampler.playNote()
    }
    
    override func stop(){
        //sampler.stopNote()
    }
    
    override func duplicate() -> AKVoice {
        let copy = SamplerVoice()
        return copy
    }
}


/****************Snare Instrument 2
 Desc: This synth drum replicates a snare instrument
 *****************/

class SnareInstrument2: SynthInstrument{
    /// Create the synth snare instrument
    ///
    /// - parameter voiceCount: Number of voices (usually two is plenty for drums)
    ///
    
    init(voiceCount: Int) {
        super.init(instrumentVoice: SnareInstrument2Voice(), voiceCount: voiceCount)
        note = 70
        
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

/// Snare Instrument 2 Voice
class SnareInstrument2Voice: SynthInstrumentVoice{
    var sampler: AKSampler!
    override init(){
        sampler = AKSampler()
        sampler.loadWav("Sounds/Snare/snare-2")
        //sampler.loadWav("Sounds/cheeb-bd")
        super.init()
        self.avAudioNode = sampler.avAudioNode
    }
    
    override func start() {
        sampler.playNote()
    }
    
    override func stop(){
        //sampler.stopNote()
    }
    
    override func duplicate() -> AKVoice {
        let copy = SnareInstrument2Voice()
        return copy
    }
}


/****************Snare Instrument 3
 Desc: This synth drum replicates a snare instrument
 *****************/

class SnareInstrument3: SynthInstrument{
    /// Create the synth snare instrument
    ///
    /// - parameter voiceCount: Number of voices (usually two is plenty for drums)
    ///
    
    init(voiceCount: Int) {
        super.init(instrumentVoice: SnareInstrument3Voice(), voiceCount: voiceCount)
        note = 80
        
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

/// Snare Instrument 3 Voice
class SnareInstrument3Voice: SynthInstrumentVoice{
    var sampler: AKSampler!
    override init(){
        sampler = AKSampler()
        sampler.loadWav("Sounds/Snare/snare-3")
        //sampler.loadWav("Sounds/cheeb-bd")
        super.init()
        self.avAudioNode = sampler.avAudioNode
    }
    
    override func start() {
        sampler.playNote()
    }
    
    override func stop(){
        //sampler.stopNote()
    }
    
    override func duplicate() -> AKVoice {
        let copy = SnareInstrument3Voice()
        return copy
    }
}


/****************Snare Instrument 4
 Desc: This synth drum replicates a snare instrument
 *****************/

class SnareInstrument4: SynthInstrument{
    /// Create the synth snare instrument
    ///
    /// - parameter voiceCount: Number of voices (usually two is plenty for drums)
    ///
    
    init(voiceCount: Int) {
        super.init(instrumentVoice: SnareInstrument4Voice(), voiceCount: voiceCount)
        note = 90
        
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

/// Snare Instrument 4 Voice
class SnareInstrument4Voice: SynthInstrumentVoice{
    var sampler: AKSampler!
    override init(){
        sampler = AKSampler()
        sampler.loadWav("Sounds/Snare/snare-4")
        //sampler.loadWav("Sounds/cheeb-bd")
        super.init()
        self.avAudioNode = sampler.avAudioNode
    }
    
    override func start() {
        sampler.playNote()
    }
    
    override func stop(){
        //sampler.stopNote()
    }
    
    override func duplicate() -> AKVoice {
        let copy = SnareInstrument4Voice()
        return copy
    }
}



