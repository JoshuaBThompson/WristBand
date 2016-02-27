//
//  Track.swift
//  MidiDevice
//
//  Created by sofiebio on 2/13/16.
//  Copyright © 2016 wristband. All rights reserved.
//

import Foundation
import AudioKit

//Time Signature

struct TimeSignature {
    var beatsPerMeasure = 4 //upper - ex: 4 quarter notes in a measure for a (4/4th)
    var beatUnit = 4 //lower - ex: quarter note (4/4th)
}


//Tempo

struct Tempo {
    var beatsPerMin = 60.0
    let secPerMin = 60.0
    var beatsPerSec: Double { return beatsPerMin / secPerMin }
}



//Measure
class Measure {
    var timeSignature = TimeSignature()
    var tempo = Tempo()
    var clickTrack: ClickTrack!
    var count = 1
    var secPerMeasure: Double {return Double(timeSignature.beatsPerMeasure) / tempo.beatsPerSec * 4/Double(timeSignature.beatUnit) }
    var beatsPerMeasure: Int { return timeSignature.beatsPerMeasure }
    var totalBeats: Int { return count * beatsPerMeasure}
    var totalDuration: Double {return secPerMeasure * Double(count)}
    
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
    var secPerClick: Double!
    var clickPerSec: Double!
    var secPerBeat: Double!
    var beatsPerClick: Double!
    
    init(clickTempo: Tempo, clickTimeSignature: TimeSignature){
        tempo = clickTempo
        timeSignature = clickTimeSignature
        secPerBeat = 1/tempo.beatsPerSec
        beatsPerClick = (4.0/Double(timeSignature.beatUnit))
        secPerClick =  secPerBeat*beatsPerClick
        clickPerSec = 1/secPerClick
        clickOperation = AKOperation.metronome(clickPerSec) // metronome needs frequency of beat
        clickGenerator = AKOperationGenerator(operation: clickOperation)
        super.init()
        avAudioNode = clickGenerator.avAudioNode
        clickGenerator.start()
    }
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
    var Note1 = 90
    var Note2 = 80
    var Note3 = 70
    
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
        sequence.setBPM(100)
        
    }
    
    func start(){
        //start audiokit output
        AudioKit.start()
    }
    
    func playNote(){
        //play note based on selected instrument
        print("Playing note")
        
    }
    
    func addNote1(){
        print(String(format:"Adding note to pos %f", notePosition))
        //only add note if record is enabled, otherwise just play it
        //add note to current track
        //todo: input to function should a note with vel, note value
        //todo: next add note to current track based on selected instrument (not yet developed)
        sequence.tracks[0].addNote(Note1, vel: 80, position: notePosition, dur: 1)
        notePosition++
        
    }
    
    func addNote2(){
        print(String(format:"Adding note to pos %f", notePosition))
        //only add note if record is enabled, otherwise just play it
        //add note to current track
        //todo: input to function should a note with vel, note value
        //todo: next add note to current track based on selected instrument (not yet developed)
        sequence.tracks[0].addNote(Note2, vel: 80, position: notePosition, dur: 1)
        notePosition++
        
    }
    
    func addNote3(){
        print(String(format:"Adding note to pos %f", notePosition))
        //only add note if record is enabled, otherwise just play it
        //add note to current track
        //todo: input to function should a note with vel, note value
        //todo: next add note to current track based on selected instrument (not yet developed)
        sequence.tracks[0].addNote(Note3, vel: 80, position: notePosition, dur: 1)
        notePosition++
        
    }
    
    func record(){
        print("Recording note")
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
        //stop playing note in sequence track
        sequence.loopOff()
        sequence.stop()
    }
    
    
}
