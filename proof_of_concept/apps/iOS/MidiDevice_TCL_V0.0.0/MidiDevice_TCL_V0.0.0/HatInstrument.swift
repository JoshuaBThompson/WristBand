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
    
    init(voiceCount: Int) {
        super.init(instrumentVoice: HatInstrument1Voice(), voiceCount: voiceCount)
        note = 60
        
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

/// Hat Instrument 1 Voice
class HatInstrument1Voice: SynthInstrumentVoice{
    var sampler: AKSampler!
    override init(){
        sampler = AKSampler()
        sampler.loadWav("Sounds/Hat/TCM_Hat_1")
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
        let copy = HatInstrument1Voice()
        return copy
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
    
    init(voiceCount: Int) {
        super.init(instrumentVoice: HatInstrument2Voice(), voiceCount: voiceCount)
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

/// Hat Instrument 2 Voice
class HatInstrument2Voice: SynthInstrumentVoice{
    var sampler: AKSampler!
    override init(){
        sampler = AKSampler()
        sampler.loadWav("Sounds/Hat/TCM_Hat_2")
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
        let copy = HatInstrument2Voice()
        return copy
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
    
    init(voiceCount: Int) {
        super.init(instrumentVoice: HatInstrument3Voice(), voiceCount: voiceCount)
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

/// Hat Instrument 3 Voice
class HatInstrument3Voice: SynthInstrumentVoice{
    var sampler: AKSampler!
    override init(){
        sampler = AKSampler()
        sampler.loadWav("Sounds/Hat/TCM_Hat_3")
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
        let copy = HatInstrument3Voice()
        return copy
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
    
    init(voiceCount: Int) {
        super.init(instrumentVoice: HatInstrument4Voice(), voiceCount: voiceCount)
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

/// Hat Instrument 4 Voice
class HatInstrument4Voice: SynthInstrumentVoice{
    var sampler: AKSampler!
    override init(){
        sampler = AKSampler()
        sampler.loadWav("Sounds/Hat/TCM_Hat_4")
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
        let copy = HatInstrument4Voice()
        return copy
    }
}

