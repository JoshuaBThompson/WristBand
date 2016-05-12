//
//  TestDrums.swift
//  MidiDevice_TCL_V0.0.0
//
//  Created by sofiebio on 5/10/16.
//  Copyright © 2016 wristband. All rights reserved.
//

import Foundation
import AudioKit



//test instruments
class Kick: SynthInstrument {
    /// Create the synth kick instrument
    ///
    /// - parameter voiceCount: Number of voices (usually two is plenty for drums)
    ///
    init(voiceCount: Int) {
        super.init(instrumentVoice: SynthKickVoice(), voiceCount: voiceCount)
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
        
    }
}

//voice
/// Kick Drum Synthesizer Voice
internal class SynthKickVoice: SynthInstrumentVoice {
    var generator: AKOperationGenerator
    
    var filter: AKMoogLadder
    
    /// Create the synth kick voice
    override init() {
        
        let frequency = AKOperation.lineSegment(AKOperation.trigger, start: 120, end: 40, duration: 0.03)
        let volumeSlide = AKOperation.lineSegment(AKOperation.trigger, start: 1, end: 0, duration: 0.3)
        let boom = AKOperation.sineWave(frequency: frequency, amplitude: volumeSlide)
        
        generator = AKOperationGenerator(operation: boom)
        filter = AKMoogLadder(generator)
        filter.cutoffFrequency = 666
        filter.resonance = 0.00
        
        super.init()
        avAudioNode = filter.avAudioNode
        generator.start()
    }
    
    /// Function create an identical new node for use in creating polyphonic instruments
    override func duplicate() -> AKVoice {
        let copy = SynthKickVoice()
        return copy
    }
    
    /// Tells whether the node is processing (ie. started, playing, or active)
    override var isStarted: Bool {
        return generator.isPlaying
    }
    
    /// Function to start, play, or activate the node, all do the same thing
    override func start() {
        generator.trigger()
    }
    
    /// Function to stop or bypass the node, both are equivalent
    override func stop() {
        
    }
}
