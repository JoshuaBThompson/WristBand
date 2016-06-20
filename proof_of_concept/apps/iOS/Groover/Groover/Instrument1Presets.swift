//
//  Instrument1Presets.swift
//  MidiDevice_TCL_V0.0.0
//
//  Created by sofiebio on 5/7/16.
//  Copyright © 2016 wristband. All rights reserved.
//

import Foundation
import AudioKit


/// Inst1 preset 2 voice test
class Instrument1Preset1VoiceTest: SynthInstrumentVoice{
    
    //operations
    var triangleTrigger: AKOperation!
    var triangleWave: AKOperation!
    var noiseOperation: AKOperation!
    var noiseTrigger: AKOperation!
    
    
    //generators
    var noiseGenerator: AKOperationGenerator
    var waveGenerator: AKOperationGenerator!
    
    //filters
    var noiseFilter: AKLowPassFilter!
    var compressor: AKCompressor!
    
    //mixers
    var mixer: AKMixer!
    var presetMixer: AKMixer! //testing
    
    
    //params
    var frequency: AKOperation!
    
    
    
    /// Create the synth drum voice
    override init() {
        frequency = AKOperation.lineSegment(AKOperation.trigger, start: 30.0, end: 20.0, duration: 0.20)
        triangleWave = AKOperation.triangleWave(frequency: frequency, amplitude: 1)
        triangleTrigger = triangleWave.triggeredWithEnvelope(AKOperation.trigger, attack: 0.0001, hold: 0.0, release: 0.20)
        waveGenerator = AKOperationGenerator(operation: triangleTrigger)
        
        noiseOperation = AKOperation.whiteNoise(amplitude: 0.1)
        noiseTrigger = noiseOperation.triggeredWithEnvelope(AKOperation.trigger, attack: 0.01, hold: 0.0, release: 0.01) //0.02 = 20 ms
        noiseGenerator = AKOperationGenerator(operation: noiseTrigger)
        noiseFilter = AKLowPassFilter(noiseGenerator, cutoffFrequency: 1000)
        
        mixer = AKMixer(noiseFilter, waveGenerator)
        
        
        
        super.init()
        //set avaudionode
        self.avAudioNode = mixer.avAudioNode //compressor.avAudioNode
        //start generators, filters ...etc
        noiseFilter.start()
        waveGenerator.start()
        noiseGenerator.start()
        
        
    }
    
    /// Function create an identical new node for use in creating polyphonic instruments
    override func duplicate() -> AKVoice {
        let copy = Instrument1Preset1VoiceTest()
        return copy
    }
    
    /// Tells whether the node is processing (ie. started, playing, or active)
    override var isStarted: Bool {
        let playing: Bool = waveGenerator.isPlaying
        return playing
    }
    
    /// Function to start, play, or activate the node, all do the same thing
    override func start() {
        noiseGenerator.trigger()
        waveGenerator.trigger()
    }
    
    /// Function to stop or bypass the node, both are equivalent
    override func stop() {
        
    }
}


/****************Custom instrument preset 1 test
 Desc: This synth drum replicates a low frequency bass drum using clipping, compressor and distortion / noise
 *****************/

class Instrument1Preset1Test: SynthInstrument{
    /// Create the synth snare instrument
    ///
    /// - parameter voiceCount: Number of voices (usually two is plenty for drums)
    ///
    
    init(voiceCount: Int) {
        super.init(instrumentVoice: Instrument1Preset1VoiceTest(), voiceCount: voiceCount)
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

/****************Custom instrument preset 1
 Desc: This synth drum replicates a low frequency bass drum using clipping, compressor and distortion / noise
 *****************/

class Instrument1Preset1: SynthInstrument{
    /// Create the synth snare instrument
    ///
    /// - parameter voiceCount: Number of voices (usually two is plenty for drums)
    ///
    
    init(voiceCount: Int) {
        super.init(instrumentVoice: Instrument1Preset1Voice(), voiceCount: voiceCount)
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

/// Inst1 preset 1 voice
class Instrument1Preset1Voice: SynthInstrumentVoice{
    
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
    
    //mixers
    var mixer: AKMixer!
    var presetMixer: AKMixer! //testing
    
    
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
        
        presetMixer = AKMixer(compressor, noiseFilter)
        
        
        super.init()
        //set avaudionode
        self.avAudioNode = presetMixer.avAudioNode //compressor.avAudioNode
        //start generators, filters ...etc
        compressor.start()
        noiseFilter.start()
        waveGenerator.start()
        noiseGenerator.start()
        distortion.start()
        
    }
    
    /// Function create an identical new node for use in creating polyphonic instruments
    override func duplicate() -> AKVoice {
        let copy = Instrument1Preset1Voice()
        return copy
    }
    
    /// Tells whether the node is processing (ie. started, playing, or active)
    override var isStarted: Bool {
        let playing: Bool = (noiseGenerator.isPlaying && waveGenerator.isPlaying)
        return playing
    }
    
    /// Function to start, play, or activate the node, all do the same thing
    override func start() {
        noiseGenerator.trigger()
        waveGenerator.trigger()
    }
    
    /// Function to stop or bypass the node, both are equivalent
    override func stop() {
        
    }
}




/****************Custom instrument preset 2
 Desc: This synth drum replicates a low frequency bass drum using clipping, compressor and distortion / noise
 *****************/

class Instrument1Preset2: SynthInstrument{
    /// Create the synth snare instrument
    ///
    /// - parameter voiceCount: Number of voices (usually two is plenty for drums)
    ///
    
    init(voiceCount: Int) {
        super.init(instrumentVoice: Instrument1Preset2Voice(), voiceCount: voiceCount)
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


/// Inst1 preset 2 voice
class Instrument1Preset2Voice: SynthInstrumentVoice{
    
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
    
    //mixers
    var mixer: AKMixer!
    var presetMixer: AKMixer! //testing
    
    
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
        
        presetMixer = AKMixer(compressor, noiseFilter)
        
        
        super.init()
        //set avaudionode
        self.avAudioNode = presetMixer.avAudioNode //compressor.avAudioNode
        //start generators, filters ...etc
        compressor.start()
        noiseFilter.start()
        waveGenerator.start()
        noiseGenerator.start()
        distortion.start()
        
    }
    
    /// Function create an identical new node for use in creating polyphonic instruments
    override func duplicate() -> AKVoice {
        let copy = Instrument1Preset2Voice()
        return copy
    }
    
    /// Tells whether the node is processing (ie. started, playing, or active)
    override var isStarted: Bool {
        let playing: Bool = (noiseGenerator.isPlaying && waveGenerator.isPlaying)
        return playing
    }
    
    /// Function to start, play, or activate the node, all do the same thing
    override func start() {
        noiseGenerator.trigger()
        waveGenerator.trigger()
    }
    
    /// Function to stop or bypass the node, both are equivalent
    override func stop() {
        
    }
}




/****************Custom instrument preset 3
 Desc: This synth drum replicates a low frequency bass drum using clipping, compressor and distortion / noise
 *****************/

class Instrument1Preset3: SynthInstrument{
    /// Create the synth snare instrument
    ///
    /// - parameter voiceCount: Number of voices (usually two is plenty for drums)
    ///
    
    init(voiceCount: Int) {
        super.init(instrumentVoice: Instrument1Preset3Voice(), voiceCount: voiceCount)
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

/// Inst1 preset 3 voice
class Instrument1Preset3Voice: SynthInstrumentVoice{
    
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
    
    //mixers
    var mixer: AKMixer!
    var presetMixer: AKMixer! //testing
    
    
    //params
    var frequency: AKOperation!
    
    
    
    /// Create the synth drum voice
    override init() {
        frequency = AKOperation.lineSegment(AKOperation.trigger, start: 120, end: 80.0, duration: 0.20)
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
        
        presetMixer = AKMixer(compressor, noiseFilter)
        
        
        super.init()
        //set avaudionode
        self.avAudioNode = presetMixer.avAudioNode //compressor.avAudioNode
        //start generators, filters ...etc
        compressor.start()
        noiseFilter.start()
        waveGenerator.start()
        noiseGenerator.start()
        distortion.start()
        
    }
    
    /// Function create an identical new node for use in creating polyphonic instruments
    override func duplicate() -> AKVoice {
        let copy = Instrument1Preset3Voice()
        return copy
    }
    
    /// Tells whether the node is processing (ie. started, playing, or active)
    override var isStarted: Bool {
        let playing: Bool = (noiseGenerator.isPlaying && waveGenerator.isPlaying)
        return playing
    }
    
    /// Function to start, play, or activate the node, all do the same thing
    override func start() {
        noiseGenerator.trigger()
        waveGenerator.trigger()
    }
    
    /// Function to stop or bypass the node, both are equivalent
    override func stop() {
        
    }
}


/****************Custom instrument preset 4
 Desc: This synth drum replicates a low frequency bass drum using clipping, compressor and distortion / noise
 *****************/

class Instrument1Preset4: SynthInstrument{
    /// Create the synth snare instrument
    ///
    /// - parameter voiceCount: Number of voices (usually two is plenty for drums)
    ///
    
    init(voiceCount: Int) {
        super.init(instrumentVoice: Instrument1Preset4Voice(), voiceCount: voiceCount)
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

/// Inst1 preset 4 voice
class Instrument1Preset4Voice: SynthInstrumentVoice{
    
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
    
    //mixers
    var mixer: AKMixer!
    var presetMixer: AKMixer! //testing
    
    
    //params
    var frequency: AKOperation!
    
    
    
    /// Create the synth drum voice
    override init() {
        frequency = AKOperation.lineSegment(AKOperation.trigger, start: 180.0, end: 90.0, duration: 0.20)
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
        
        presetMixer = AKMixer(compressor, noiseFilter)
        
        
        super.init()
        //set avaudionode
        self.avAudioNode = presetMixer.avAudioNode //compressor.avAudioNode
        //start generators, filters ...etc
        compressor.start()
        noiseFilter.start()
        waveGenerator.start()
        noiseGenerator.start()
        distortion.start()
        
    }
    
    /// Function create an identical new node for use in creating polyphonic instruments
    override func duplicate() -> AKVoice {
        let copy = Instrument1Preset4Voice()
        return copy
    }
    
    /// Tells whether the node is processing (ie. started, playing, or active)
    override var isStarted: Bool {
        let playing: Bool = (noiseGenerator.isPlaying && waveGenerator.isPlaying)
        return playing
    }
    
    /// Function to start, play, or activate the node, all do the same thing
    override func start() {
        noiseGenerator.trigger()
        waveGenerator.trigger()
    }
    
    /// Function to stop or bypass the node, both are equivalent
    override func stop() {
        
    }
}









