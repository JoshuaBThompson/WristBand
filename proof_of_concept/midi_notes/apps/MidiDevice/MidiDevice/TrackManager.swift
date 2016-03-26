//
//  Track.swift
//  MidiDevice
//
//  Created by sofiebio on 2/13/16.
//  Copyright © 2016 wristband. All rights reserved.
//

import Foundation
import CoreFoundation
import AudioKit

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



class TrackManager {
    var measure = Measure()
    var sequence = AKSequencer() //contains the tracks
    
    //Testing
    var midi = AKMIDI()
    var kickMidi: AKMIDIInstrument!
    var kickInst: AKSynthKick!
    var snareInst: AKSynthSnare!
    var snareMidi: AKMIDIInstrument!
    var mixer: AKMixer!
    var notePosition: Double = 1
    var recordEnabled = false
    var playing = false
    
    init(){
    
        kickInst = AKSynthKick(voiceCount: 1)
        snareInst = AKSynthSnare(voiceCount: 2)
        snareInst.amplitude = 2
        kickInst.amplitude = 2
        measure = Measure()
        mixer = AKMixer()
        mixer.connect(kickInst)
        mixer.connect(snareInst)
        mixer.connect(measure.clickTrack)
        kickMidi = AKMIDIInstrument(instrument: kickInst)
        kickMidi.enableMIDI(midi.midiClient, name: "Synth kick midi")
        snareMidi = AKMIDIInstrument(instrument: snareInst)
        snareMidi.enableMIDI(midi.midiClient, name: "Synth snare midi")
        
        AudioKit.output = mixer
        
        
        sequence.newTrack()
        sequence.tracks[0].setMIDIOutput(kickMidi.midiIn)
        sequence.newTrack()
        sequence.tracks[1].setMIDIOutput(snareMidi.midiIn)
        sequence.newTrack()
        sequence.tracks[2].setMIDIOutput(kickMidi.midiIn)
        sequence.setBPM(Float(measure.clickTrack.clickPerSec))
        sequence.setLength(measure.totalDuration)
        
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
        for var trackNum=0; trackNum < sequence.trackCount; trackNum++ {
            sequence.tracks[trackNum].clear()
        }
    }
    
    func playRawNote(note: Int, status: Int){
        //play note using note value and status (on or off)
        snareInst.playNote(90, velocity: 127)
        snareInst.stopNote(90);

    }
    
    func playNote(note: Int){
        //play note based on selected instrument
        print("Playing note")
        if note == 90{
            kickInst.playNote(note, velocity: 127)
            kickInst.stopNote(note)
        }
        else if note == 80 {
            snareInst.playNote(note, velocity: 127)
            snareInst.stopNote(note)
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
        sequence.tracks[trackNumber].addNote(note, vel: 127, position: timeElapsed, dur: 0.5)
        if !playing { play() }
        
    }
    
    func record(){
        //stop()
        print("Recording note")
        recordEnabled = true
        measure.timer.start()
        //start recording
        //set record enabled
        //now addNote function will add notes to sequences track
    }
    
    func play(){
        print("Playing notes in sequence track")
        //play note in sequence track (just play first track for now)
        sequence.loopOn()
        sequence.play()
        playing = true
        
    }
    
    func stop(){
        print("Stop playing notes in sequence track")
        recordEnabled = false
        //stop playing note in sequence track
        sequence.loopOff()
        sequence.stop()
        measure.timer.stop()
        playing = false
    }
    
    func setTempo(newBeatsPerMin: Double){
        measure.tempo.beatsPerMin = newBeatsPerMin
        print("todo: click track update tempo")
        measure.clickTrack.update(measure.tempo, clickTimeSignature: measure.timeSignature)
        sequence.setBPM(Float(measure.clickTrack.tempo.beatsPerMin))
        sequence.setLength(measure.totalDuration)
    }
    
    func setTimeSignature(newBeatsPerMeasure: Int, newNote: Int){
        measure.timeSignature.beatsPerMeasure = newBeatsPerMeasure
        measure.timeSignature.beatUnit = newNote
        measure.clickTrack.update(measure.tempo, clickTimeSignature: measure.timeSignature)
        sequence.setLength(measure.totalDuration)
        
    }
    
    
}
