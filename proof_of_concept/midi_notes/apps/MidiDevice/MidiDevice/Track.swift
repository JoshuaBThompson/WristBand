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
    
    
    init(clickTempo: Tempo, clickTimeSignature: TimeSignature){
        super.init()
        tempo = clickTempo
        timeSignature = clickTimeSignature
        clickOperation = AKOperation.metronome(clickPerSec) // metronome needs frequency of beat
        clickGenerator = AKOperationGenerator(operation: clickOperation)
        avAudioNode = clickGenerator.avAudioNode
        
        clickGenerator.start()
    }
    
    func update(clickTempo: Tempo, clickTimeSignature: TimeSignature){
        print("update click track")
        tempo = clickTempo
        timeSignature = clickTimeSignature
        
    }
    
    //MARK: functions
    
}



class Track {
    var measure = Measure()
    var sequence = AKSequencer()
    
    //Testing
    var midi = AKMIDI()
    var kickMidi: AKMIDIInstrument!
    var kickInst: AKSynthKick!
    var mixer: AKMixer!
    var notePosition: Double = 1
    var recordEnabled = false
    
    init(){
    
        kickInst = AKSynthKick(voiceCount: 1)
        measure = Measure()
        mixer = AKMixer()
        mixer.connect(kickInst)
        mixer.connect(measure.clickTrack)
        kickMidi = AKMIDIInstrument(instrument: kickInst)
        kickMidi.enableMIDI(midi.midiClient, name: "Synth kick midi")
        AudioKit.output = mixer
        sequence.newTrack()
        sequence.tracks[0].setMIDIOutput(kickMidi.midiIn)
        sequence.setBPM(Float(measure.clickTrack.clickPerSec))
        
        
    }
    
    func start(){
        //start audiokit output
        AudioKit.start()
    }
    
    func playNote(){
        //play note based on selected instrument
        print("Playing note")
        
    }
    
    func addNote(note: Int){
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
        sequence.tracks[0].addNote(note, vel: 80, position: timeElapsed, dur: 1)
        notePosition++
    }
    
    func record(){
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
        
    }
    
    func stop(){
        print("Stop playing notes in sequence track")
        recordEnabled = false
        //stop playing note in sequence track
        sequence.loopOff()
        sequence.stop()
        measure.timer.stop()
    }
    
    func setTempo(newBeatsPerMin: Double){
        measure.tempo.beatsPerMin = newBeatsPerMin
        print("todo: click track update tempo")
        measure.clickTrack.update(measure.tempo, clickTimeSignature: measure.timeSignature)
    }
    
    func setTimeSignature(newBeatsPerMeasure: Int, newNote: Int){
        measure.timeSignature.beatsPerMeasure = newBeatsPerMeasure
        measure.timeSignature.beatUnit = newNote
        measure.clickTrack.update(measure.tempo, clickTimeSignature: measure.timeSignature)
    }
    
    
}
