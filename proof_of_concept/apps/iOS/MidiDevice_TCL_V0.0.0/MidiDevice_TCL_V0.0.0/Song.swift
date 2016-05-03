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
    var longestTime = 0.0
    
    //computed
    var secPerMeasure: Double { return clickTrack.secPerMeasure }
    var beatsPerMeasure: Int { return timeSignature.beatsPerMeasure }
    var totalBeats: Int { return count * beatsPerMeasure}
    var totalDuration: Double {
        if (longestTime > secPerMeasure){
            //round up to nearest integer to get number of measures
            //if longest time recorded is greater then secPerMeasure then make more measures
            //so we don't lose beats that were made while recording
            count = Int(ceil(Double(longestTime)/Double(secPerMeasure)))
        }
        else{
            count = 1; //todo: how should we update measure counts?
        }
        return secPerMeasure * Double(count)
    }
    var timeElapsed: Double {
        //this gets called when a beat is added to the track
        let timeElapsedSec = timer.stop()
        var time = 0.0
        if timeElapsedSec <= totalDuration {
            time = timeElapsedSec
        }
        else{
            time = fmod(timeElapsedSec, totalDuration)
        }
        if longestTime < time {
            //this will record when a beat was added (gets the longest time beat)
            longestTime = time
        }
        
        return time
        
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
    
    var selectedDrum = 0
    var midi = AKMIDI()
    var drumA: SynthDrumA!
    var drumB: SynthDrumB!
    var drumC: SynthDrumC!
    var drumD: SynthDrumD!
    var drumAMidi: AKMIDIInstrument!
    var drumBMidi: AKMIDIInstrument!
    var drumCMidi: AKMIDIInstrument!
    var drumDMidi: AKMIDIInstrument!
    var mixer: AKMixer!
    var notePosition: Double = 1
    var recordEnabled = false
    var playing = false
    var drums = [SynthDrum]()
    
    init(){
        
        drumA = SynthDrumA(voiceCount: 1) //custom synth drum A
        drums.append(drumA)
        drumB = SynthDrumB(voiceCount: 1) //custom synth drum B
        drums.append(drumB)
        drumC = SynthDrumC(voiceCount: 1) //custom synth drum C
        drums.append(drumC)
        drumD = SynthDrumD(voiceCount: 1) //custom synth drum D
        drums.append(drumD)
        
        measure = Measure()
        mixer = AKMixer()
        mixer.connect(drumA)
        mixer.connect(drumB)
        mixer.connect(drumC)
        mixer.connect(drumD)
        mixer.connect(measure.clickTrack)
        drumAMidi = AKMIDIInstrument(instrument: drumA)
        drumAMidi.enableMIDI(midi.midiClient, name: "Synth drum A midi")
        drumBMidi = AKMIDIInstrument(instrument: drumB)
        drumBMidi.enableMIDI(midi.midiClient, name: "Synth drum B midi")
        drumCMidi = AKMIDIInstrument(instrument: drumC)
        drumCMidi.enableMIDI(midi.midiClient, name: "Synth drum C midi")
        drumDMidi = AKMIDIInstrument(instrument: drumD)
        drumDMidi.enableMIDI(midi.midiClient, name: "Synth drum D midi")
        
        
        AudioKit.output = mixer
        
        
        trackManager.newTrack()
        trackManager.tracks[0].setMIDIOutput(drumAMidi.midiIn)
        trackManager.newTrack()
        trackManager.tracks[1].setMIDIOutput(drumBMidi.midiIn)
        trackManager.newTrack()
        trackManager.tracks[2].setMIDIOutput(drumCMidi.midiIn)
        trackManager.newTrack()
        trackManager.tracks[3].setMIDIOutput(drumDMidi.midiIn)
        
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
        measure.longestTime = 0.0 //clear
        
        //clear all recorded tracks
        for trackNum in 0 ..< trackManager.trackCount {
            trackManager.tracks[trackNum].clear()
        }
    }
    
    func playNote(drumNumber: Int){
        //play note based on selected instrument
        print("Playing note")
        if(drumNumber < drums.count){
            let note = drums[drumNumber].note;
            drums[drumNumber].playNote(note, velocity: 127)
            drums[drumNumber].stopNote(note)
        }
        
    }
    
    func addSelectedNote(){
        addNote(drum: selectedDrum)
    }
    
    func addNote(drum drumNumber: Int){
        //play note event if not recording
        
        playNote(drumNumber)
        if !recordEnabled {
            print("Record not enabled, no add note allowed")
            return
        }
        let note = drums[drumNumber].note
        //only add note if record is enabled, otherwise just play it
        //add note to current track
        //todo: input to function should a note with vel, note value
        //todo: next add note to current track based on selected instrument (not yet developed)
        let timeElapsed = measure.timeElapsed
        print(String(format: "Time elapsed %f", timeElapsed))
        trackManager.tracks[drumNumber].addNote(note, velocity: 127, position: timeElapsed, duration: 0)
        if !playing { play() }
        
    }
    
    func record(){
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
        pause()
        measure.tempo.beatsPerMin = newBeatsPerMin
        print("todo: click track update tempo")
        measure.clickTrack.update(measure.tempo, clickTimeSignature: measure.timeSignature)
        trackManager.setBPM(Double(measure.clickTrack.tempo.beatsPerMin))
        trackManager.setLength(measure.totalDuration)
        unpause()
    }
    
    
    func setTimeSignature(newBeatsPerMeasure: Int, newNote: Int){
        pause()
        measure.timeSignature.beatsPerMeasure = newBeatsPerMeasure
        measure.timeSignature.beatUnit = newNote
        measure.clickTrack.update(measure.tempo, clickTimeSignature: measure.timeSignature)
        trackManager.setLength(measure.totalDuration)
        print("track manager length \(trackManager.length)")
        unpause()
        
    }
    
    func pause(){
        if(playing){
            trackManager.stop()
            trackManager.loopOff()
        }
    }
    
    func unpause(){
        if(playing){
            trackManager.loopOn()
            trackManager.play()
        }
    }
    
}
