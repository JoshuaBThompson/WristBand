//
//  SynthDrum.swift
//  MidiDevice_TCL_V0.0.0
//
//  Created by sofiebio on 4/30/16.
//  Copyright © 2016 wristband. All rights reserved.
//

import Foundation
import AudioKit

/****************Base class of synth drums
 ****************/

class SynthDrum: AKPolyphonicInstrument{
    var note: Int!
    override init(voice: AKVoice, voiceCount: Int) {
        super.init(voice: voice, voiceCount: voiceCount)
    }
}


/****************Custom synth drum (A)
  Desc: This synth drum replicates a low frequency bass drum using clipping, compressor and distortion / noise
*****************/

class SynthDrumA: SynthDrum{
    /// Create the synth snare instrument
    ///
    /// - parameter voiceCount: Number of voices (usually two is plenty for drums)
    ///
    init(voiceCount: Int) {
        super.init(voice: SynthDrumVoiceA(), voiceCount: voiceCount)
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

/// Custom Drum Synthesizer Voice (A)
class SynthDrumVoiceA: AKVoice{
    
    //operations
    var triangleTrigger: AKOperation!
    var triangleWave: AKOperation!
    var noiseOperation: AKOperation!
    var noiseTrigger: AKOperation!
    
    
    //generators
    var noiseGenerator: AKOperationGenerator
    var waveGenerator: AKOperationGenerator!
    
    //filters
    var distortion: AKTanhDistortion!
    var noiseFilter: AKLowPassFilter!
    var compressor: AKCompressor!
    
    //mixer
    var mixer: AKMixer!
    
    //params
    var frequency: AKOperation!
    
    
    
    /// Create the synth drum voice
    override init() {
        frequency = AKOperation.lineSegment(AKOperation.trigger, start: 30.0, end: 20.0, duration: 0.20)
        triangleWave = AKOperation.triangleWave(frequency: frequency, amplitude: 1)
        triangleTrigger = triangleWave.triggeredWithEnvelope(AKOperation.trigger, attack: 0.0001, hold: 0.0, release: 0.20)
        waveGenerator = AKOperationGenerator(operation: triangleTrigger)
        
        distortion = AKTanhDistortion(waveGenerator, pregain: 1.2, postgain: 1, postiveShapeParameter: 0, negativeShapeParameter: 0)
        
        noiseOperation = AKOperation.whiteNoise(amplitude: 0.1)
        noiseTrigger = noiseOperation.triggeredWithEnvelope(AKOperation.trigger, attack: 0.01, hold: 0.0, release: 0.01) //0.02 = 20 ms
        noiseGenerator = AKOperationGenerator(operation: noiseTrigger)
        noiseFilter = AKLowPassFilter(noiseGenerator, cutoffFrequency: 1000)
        
        mixer = AKMixer(noiseFilter, distortion)
        
        compressor = AKCompressor(mixer, threshold: -10, headRoom: 5, attackTime: 0.001, releaseTime: 0.05,masterGain: 5)
        
        
        super.init()
        //set avaudionode
        self.avAudioNode = compressor.avAudioNode
        //start generators, filters ...etc
        compressor.start()
        noiseFilter.start()
        waveGenerator.start()
        noiseGenerator.start()
        distortion.start()
        
    }
    
    /// Function create an identical new node for use in creating polyphonic instruments
    override func duplicate() -> AKVoice {
        let copy = SynthDrumVoiceA()
        return copy
    }
    
    /// Tells whether the node is processing (ie. started, playing, or active)
    override var isStarted: Bool {
        let playing: Bool = (noiseGenerator.isPlaying && waveGenerator.isPlaying)
        return playing
    }
    
    /// Function to start, play, or activate the node, all do the same thing
    override func start() {
        print("trigger drum A")
        noiseGenerator.trigger()
        waveGenerator.trigger()
    }
    
    /// Function to stop or bypass the node, both are equivalent
    override func stop() {
        
    }
}


/***************Custom synth drum (B)
 Desc: This synth drum replicates a low frequency bass drum using clipping, compressor and distortion / noise
 ***************/

class SynthDrumB: SynthDrum{
    /// Create the synth snare instrument
    ///
    /// - parameter voiceCount: Number of voices (usually two is plenty for drums)
    ///
    init(voiceCount: Int) {
        super.init(voice: SynthDrumVoiceB(), voiceCount: voiceCount)
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

/// Custom Drum Synthesizer Voice (B)
class SynthDrumVoiceB: AKVoice{
    
    //operations
    var triangleTrigger: AKOperation!
    var triangleWave: AKOperation!
    var noiseOperation: AKOperation!
    var noiseTrigger: AKOperation!
    
    
    //generators
    var noiseGenerator: AKOperationGenerator
    var waveGenerator: AKOperationGenerator!
    
    //filters
    var distortion: AKTanhDistortion!
    var noiseFilter: AKLowPassFilter!
    var compressor: AKCompressor!
    
    //mixer
    var mixer: AKMixer!
    
    //params
    var frequency: AKOperation!
    
    
    
    /// Create the synth drum voice
    override init() {
        frequency = AKOperation.lineSegment(AKOperation.trigger, start: 60.0, end: 40.0, duration: 0.20)
        triangleWave = AKOperation.triangleWave(frequency: frequency, amplitude: 1)
        triangleTrigger = triangleWave.triggeredWithEnvelope(AKOperation.trigger, attack: 0.0001, hold: 0.0, release: 0.20)
        waveGenerator = AKOperationGenerator(operation: triangleTrigger)
        
        distortion = AKTanhDistortion(waveGenerator, pregain: 1.2, postgain: 1, postiveShapeParameter: 0, negativeShapeParameter: 0)
        
        noiseOperation = AKOperation.whiteNoise(amplitude: 0.1)
        noiseTrigger = noiseOperation.triggeredWithEnvelope(AKOperation.trigger, attack: 0.01, hold: 0.0, release: 0.01) //0.02 = 20 ms
        noiseGenerator = AKOperationGenerator(operation: noiseTrigger)
        noiseFilter = AKLowPassFilter(noiseGenerator, cutoffFrequency: 1000)
        
        mixer = AKMixer(noiseFilter, distortion)
        
        compressor = AKCompressor(mixer, threshold: -10, headRoom: 5, attackTime: 0.001, releaseTime: 0.05,masterGain: 5)
        
        
        super.init()
        //set avaudionode
        self.avAudioNode = compressor.avAudioNode
        //start generators, filters ...etc
        compressor.start()
        noiseFilter.start()
        waveGenerator.start()
        noiseGenerator.start()
        distortion.start()
        
    }
    
    /// Function create an identical new node for use in creating polyphonic instruments
    override func duplicate() -> AKVoice {
        let copy = SynthDrumVoiceB()
        return copy
    }
    
    /// Tells whether the node is processing (ie. started, playing, or active)
    override var isStarted: Bool {
        let playing: Bool = (noiseGenerator.isPlaying && waveGenerator.isPlaying)
        return playing
    }
    
    /// Function to start, play, or activate the node, all do the same thing
    override func start() {
        print("trigger drum B")
        noiseGenerator.trigger()
        waveGenerator.trigger()
    }
    
    /// Function to stop or bypass the node, both are equivalent
    override func stop() {
        
    }
}



/*************Custom synth drum (C)
 Desc: This synth drum replicates a low frequency bass drum using clipping, compressor and distortion / noise
 *************/

class SynthDrumC: SynthDrum{
    /// Create the synth snare instrument
    ///
    /// - parameter voiceCount: Number of voices (usually two is plenty for drums)
    ///
    init(voiceCount: Int) {
        super.init(voice: SynthDrumVoiceC(), voiceCount: voiceCount)
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

/// Custom Drum Synthesizer Voice (C)
class SynthDrumVoiceC: AKVoice{
    
    //operations
    var triangleTrigger: AKOperation!
    var triangleWave: AKOperation!
    var noiseOperation: AKOperation!
    var noiseTrigger: AKOperation!
    
    
    //generators
    var noiseGenerator: AKOperationGenerator
    var waveGenerator: AKOperationGenerator!
    
    //filters
    var distortion: AKTanhDistortion!
    var noiseFilter: AKLowPassFilter!
    var compressor: AKCompressor!
    
    //mixer
    var mixer: AKMixer!
    
    //params
    var frequency: AKOperation!
    
    
    
    /// Create the synth drum voice
    override init() {
        frequency = AKOperation.lineSegment(AKOperation.trigger, start: 90.0, end: 60.0, duration: 0.20)
        triangleWave = AKOperation.triangleWave(frequency: frequency, amplitude: 1)
        triangleTrigger = triangleWave.triggeredWithEnvelope(AKOperation.trigger, attack: 0.0001, hold: 0.0, release: 0.20)
        waveGenerator = AKOperationGenerator(operation: triangleTrigger)
        
        distortion = AKTanhDistortion(waveGenerator, pregain: 1.2, postgain: 1, postiveShapeParameter: 0, negativeShapeParameter: 0)
        
        noiseOperation = AKOperation.whiteNoise(amplitude: 0.1)
        noiseTrigger = noiseOperation.triggeredWithEnvelope(AKOperation.trigger, attack: 0.01, hold: 0.0, release: 0.01) //0.02 = 20 ms
        noiseGenerator = AKOperationGenerator(operation: noiseTrigger)
        noiseFilter = AKLowPassFilter(noiseGenerator, cutoffFrequency: 1000)
        
        mixer = AKMixer(noiseFilter, distortion)
        
        compressor = AKCompressor(mixer, threshold: -10, headRoom: 5, attackTime: 0.001, releaseTime: 0.05,masterGain: 5)
        
        
        super.init()
        //set avaudionode
        self.avAudioNode = compressor.avAudioNode
        //start generators, filters ...etc
        compressor.start()
        noiseFilter.start()
        waveGenerator.start()
        noiseGenerator.start()
        distortion.start()
        
    }
    
    /// Function create an identical new node for use in creating polyphonic instruments
    override func duplicate() -> AKVoice {
        let copy = SynthDrumVoiceC()
        return copy
    }
    
    /// Tells whether the node is processing (ie. started, playing, or active)
    override var isStarted: Bool {
        let playing: Bool = (noiseGenerator.isPlaying && waveGenerator.isPlaying)
        return playing
    }
    
    /// Function to start, play, or activate the node, all do the same thing
    override func start() {
        print("trigger drum C")
        noiseGenerator.trigger()
        waveGenerator.trigger()
    }
    
    /// Function to stop or bypass the node, both are equivalent
    override func stop() {
        
    }
}


/*************Custom synth drum (D)
 Desc: This synth drum replicates a low frequency bass drum using clipping, compressor and distortion / noise
 *************/

class SynthDrumD: SynthDrum{
    /// Create the synth snare instrument
    ///
    /// - parameter voiceCount: Number of voices (usually two is plenty for drums)
    ///
        init(voiceCount: Int) {
        super.init(voice: SynthDrumVoiceD(), voiceCount: voiceCount)
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

/// Custom Drum Synthesizer Voice (D)
class SynthDrumVoiceD: AKVoice{
    
    //operations
    var triangleTrigger: AKOperation!
    var triangleWave: AKOperation!
    var noiseOperation: AKOperation!
    var noiseTrigger: AKOperation!
    
    
    //generators
    var noiseGenerator: AKOperationGenerator
    var waveGenerator: AKOperationGenerator!
    
    //filters
    var distortion: AKTanhDistortion!
    var noiseFilter: AKLowPassFilter!
    var compressor: AKCompressor!
    
    //mixer
    var mixer: AKMixer!
    
    //params
    var frequency: AKOperation!
    
    
    
    /// Create the synth drum voice
    override init() {
        frequency = AKOperation.lineSegment(AKOperation.trigger, start: 120.0, end: 80.0, duration: 0.20)
        triangleWave = AKOperation.triangleWave(frequency: frequency, amplitude: 1)
        triangleTrigger = triangleWave.triggeredWithEnvelope(AKOperation.trigger, attack: 0.0001, hold: 0.0, release: 0.20)
        waveGenerator = AKOperationGenerator(operation: triangleTrigger)
        
        distortion = AKTanhDistortion(waveGenerator, pregain: 1.2, postgain: 1, postiveShapeParameter: 0, negativeShapeParameter: 0)
        
        noiseOperation = AKOperation.whiteNoise(amplitude: 0.1)
        noiseTrigger = noiseOperation.triggeredWithEnvelope(AKOperation.trigger, attack: 0.01, hold: 0.0, release: 0.01) //0.02 = 20 ms
        noiseGenerator = AKOperationGenerator(operation: noiseTrigger)
        noiseFilter = AKLowPassFilter(noiseGenerator, cutoffFrequency: 1000)
        
        mixer = AKMixer(noiseFilter, distortion)
        
        compressor = AKCompressor(mixer, threshold: -10, headRoom: 5, attackTime: 0.001, releaseTime: 0.05,masterGain: 5)
        
        
        super.init()
        //set avaudionode
        self.avAudioNode = compressor.avAudioNode
        //start generators, filters ...etc
        compressor.start()
        noiseFilter.start()
        waveGenerator.start()
        noiseGenerator.start()
        distortion.start()
        
    }
    
    /// Function create an identical new node for use in creating polyphonic instruments
    override func duplicate() -> AKVoice {
        let copy = SynthDrumVoiceD()
        return copy
    }
    
    /// Tells whether the node is processing (ie. started, playing, or active)
    override var isStarted: Bool {
        let playing: Bool = (noiseGenerator.isPlaying && waveGenerator.isPlaying)
        return playing
    }
    
    /// Function to start, play, or activate the node, all do the same thing
    override func start() {
        print("trigger drum D")
        noiseGenerator.trigger()
        waveGenerator.trigger()
    }
    
    /// Function to stop or bypass the node, both are equivalent
    override func stop() {
        
    }
}
