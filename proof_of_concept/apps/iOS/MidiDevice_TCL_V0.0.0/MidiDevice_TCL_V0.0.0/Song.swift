//
//  TrackManager.swift
//  MidiDevice_TCL_V0.0.0
//
//  Created by sofiebio on 4/21/16.
//  Copyright © 2016 wristband. All rights reserved.
//

import Foundation
import CoreFoundation
import AudioKit

//Custom synth drum

class SynthDrum: AKPolyphonicInstrument{
    /// Create the synth snare instrument
    ///
    /// - parameter voiceCount: Number of voices (usually two is plenty for drums)
    ///
    init(voiceCount: Int) {
        super.init(voice: SynthDrumVoice(), voiceCount: voiceCount)
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

/// Custom Drum Synthesizer Voice
class SynthDrumVoice: AKVoice{
    
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
        let copy = SynthDrumVoice()
        return copy
    }
    
    /// Tells whether the node is processing (ie. started, playing, or active)
    override var isStarted: Bool {
        let playing: Bool = (noiseGenerator.isPlaying && waveGenerator.isPlaying)
        return playing
    }
    
    /// Function to start, play, or activate the node, all do the same thing
    override func start() {
        print("trigger drum")
        noiseGenerator.trigger()
        waveGenerator.trigger()
    }
    
    /// Function to stop or bypass the node, both are equivalent
    override func stop() {
        
    }
}

//Timer

class Timer {
    
    var startTime:CFAbsoluteTime
    var endTime:CFAbsoluteTime?
    
    init() {
        startTime = CFAbsoluteTimeGetCurrent()
    }
    
    func start(){
        startTime = CFAbsoluteTimeGetCurrent()
    }
    
    func stop() -> CFAbsoluteTime {
        endTime = CFAbsoluteTimeGetCurrent()
        
        return duration!
    }
    
    var duration:CFAbsoluteTime? {
        if let endTime = endTime {
            return endTime - startTime
        } else {
            return nil
        }
    }
}

//Time Signature

struct TimeSignature {
    var beatsPerMeasure = 4 //upper - ex: 4 quarter notes in a measure for a (4/4th)
    var beatUnit = 4 //lower - ex: quarter note (4/4th)
}


//Tempo

struct Tempo {
    var beatsPerMin = Double(60.0)
    let secPerMin = Double(60.0)
    var beatsPerSec: Double { return beatsPerMin / secPerMin }
}



//Measure
class Measure {
    var timeSignature = TimeSignature()
    var tempo = Tempo()
    var clickTrack: ClickTrack!
    var timer = Timer()
    var count = 1
    
    //computed
    var secPerMeasure: Double { return clickTrack.secPerMeasure }
    var beatsPerMeasure: Int { return timeSignature.beatsPerMeasure }
    var totalBeats: Int { return count * beatsPerMeasure}
    var totalDuration: Double {return secPerMeasure * Double(count)}
    var timeElapsed: Double {
        let timeElapsedSec = timer.stop()
        if timeElapsedSec <= totalDuration {
            return timeElapsedSec
        }
        else{
            return fmod(timeElapsedSec, totalDuration)
        }
    }
    
    init(){
        clickTrack = ClickTrack(clickTempo: tempo, clickTimeSignature: timeSignature)
    }
    
    
}

//ClickTrack
class ClickTrack: AKVoice{
    var tempo: Tempo!
    var timeSignature: TimeSignature!
    var clickOperation: AKOperation!
    var clickGenerator: AKOperationGenerator!
    
    //computed
    var secPerMeasure: Double {return Double(timeSignature.beatsPerMeasure) / tempo.beatsPerSec * 4/Double(timeSignature.beatUnit) }
    var secPerClick: Double { return secPerMeasure / Double(timeSignature.beatsPerMeasure) }
    var clickPerSec: Double { return 1/secPerClick }
    var beep: AKOperation!
    var trig: AKOperation!
    var beeps: AKOperation!
    
    init(clickTempo: Tempo, clickTimeSignature: TimeSignature){
        super.init()
        tempo = clickTempo
        timeSignature = clickTimeSignature
        
        beep = AKOperation.sineWave(frequency: 480)
        
        trig = AKOperation.metronome(AKOperation.parameters(0))
        
        beeps = beep.triggeredWithEnvelope(
            trig,
            attack: 0.01, hold: 0, release: 0.01)
        
        clickGenerator = AKOperationGenerator(operation: beeps)
        clickGenerator.parameters = [clickPerSec]
        avAudioNode = clickGenerator.avAudioNode
        clickGenerator.start()
    }
    
    func update(clickTempo: Tempo, clickTimeSignature: TimeSignature){
        print("update click track")
        //update click track freq data
        tempo = clickTempo
        timeSignature = clickTimeSignature
        clickGenerator.parameters = [clickPerSec] // clickPerSec is computed var that used updated tempo and timeSignature
        
    }
    
    //MARK: functions
    
}



class Song {
    var measure = Measure()
    var trackManager = AKSequencer()
    
    //Testing
    var midi = AKMIDI()
    var snareMidi: AKMIDIInstrument!
    var snareInst: AKSynthSnare!
    var drum: SynthDrum!
    var drumMidi: AKMIDIInstrument!
    var mixer: AKMixer!
    var notePosition: Double = 1
    var recordEnabled = false
    var playing = false
    
    init(){
        
        snareInst = AKSynthSnare(voiceCount: 1)
        drum = SynthDrum(voiceCount: 1) //custom synth drum
        snareInst.amplitude = 2
        measure = Measure()
        mixer = AKMixer()
        mixer.connect(snareInst)
        mixer.connect(drum)
        mixer.connect(measure.clickTrack)
        snareMidi = AKMIDIInstrument(instrument: snareInst)
        snareMidi.enableMIDI(midi.midiClient, name: "Synth snare midi")
        drumMidi = AKMIDIInstrument(instrument: drum)
        drumMidi.enableMIDI(midi.midiClient, name: "Synth drum midi")
        
        
        AudioKit.output = mixer
        
        
        trackManager.newTrack()
        trackManager.tracks[0].setMIDIOutput(snareMidi.midiIn)
        trackManager.newTrack()
        trackManager.tracks[1].setMIDIOutput(drumMidi.midiIn)
        
        trackManager.setBPM(Double(measure.clickTrack.tempo.beatsPerMin))
        trackManager.setLength(measure.totalDuration)
        
        print(String(format: "sequence bpm %f", measure.clickTrack.tempo.beatsPerMin))
        print(String(format: "sequence length %f", measure.totalDuration))
        
        
    }
    
    func start(){
        //start audiokit output
        AudioKit.start()
    }
    
    func clear(){
        //stop any currently playing tracks first
        stop()
        
        //clear all recorded tracks
        for trackNum in 0 ..< trackManager.trackCount {
            trackManager.tracks[trackNum].clear()
        }
    }
    
    func playRawNote(note: Int, status: Int){
        //play note using note value and status (on or off)
        print("play note")
        drum.playNote(90, velocity: 127) //the params don't do anything yet... just triggers custom drum sound
        drum.stopNote(90)
        
    }
    
    func playNote(note: Int){
        //play note based on selected instrument
        print("Playing note")
        if note == 90{
            snareInst.playNote(note, velocity: 127)
            snareInst.stopNote(note)
        }
        else if note == 80 {
            drum.playNote(note, velocity: 127)
            drum.stopNote(note)
        }
        
    }
    
    func addNote(note: Int, trackNumber: Int){
        //play note event if not recording
        
        playNote(note)
        if !recordEnabled {
            print("Record not enabled, no add note allowed")
            return
        }
        //only add note if record is enabled, otherwise just play it
        //add note to current track
        //todo: input to function should a note with vel, note value
        //todo: next add note to current track based on selected instrument (not yet developed)
        let timeElapsed = measure.timeElapsed
        print(String(format: "Time elapsed %f", timeElapsed))
        trackManager.tracks[trackNumber].addNote(note, velocity: 127, position: timeElapsed, duration: 0)
        if !playing { play() }
        
    }
    
    func record(){
        //stop()
        print("Recording note")
        recordEnabled = true
        measure.timer.start()
        //now addNote function will add notes to sequences track
    }
    
    func play(){
        print("Playing notes in sequence track")
        //play note in sequence track (just play first track for now)
        trackManager.loopOn()
        trackManager.play()
        playing = true
        
    }
    
    func stop(){
        print("Stop playing notes in sequence track")
        recordEnabled = false
        //stop playing note in sequence track
        trackManager.loopOff()
        trackManager.stop()
        measure.timer.stop()
        playing = false
    }
    
    func setTempo(newBeatsPerMin: Double){
        measure.tempo.beatsPerMin = newBeatsPerMin
        print("todo: click track update tempo")
        measure.clickTrack.update(measure.tempo, clickTimeSignature: measure.timeSignature)
        trackManager.setBPM(Double(measure.clickTrack.tempo.beatsPerMin))
        trackManager.setLength(measure.totalDuration)
    }
    
    func setTimeSignature(newBeatsPerMeasure: Int, newNote: Int){
        measure.timeSignature.beatsPerMeasure = newBeatsPerMeasure
        measure.timeSignature.beatUnit = newNote
        measure.clickTrack.update(measure.tempo, clickTimeSignature: measure.timeSignature)
        trackManager.setLength(measure.totalDuration)
        
    }
    
    
}
