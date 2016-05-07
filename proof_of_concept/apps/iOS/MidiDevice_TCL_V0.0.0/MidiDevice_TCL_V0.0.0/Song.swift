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


class Song {
    var selectedInstrument = 0
    var selectedPreset = 0
    var mixer: AKMixer!
    var notePosition: Double = 1
    var recordEnabled = false
    var playing = false
    var instrument1Tracks: InstrumentPresetTracks!
    var instruments = [InstrumentPresetTracks]()
    
    init(){
        instrument1Tracks = InstrumentPresetTracks(preset1: Instrument1Preset1(voiceCount:1), preset2: Instrument1Preset2(voiceCount:1), preset3: Instrument1Preset3(voiceCount:1), preset4: Instrument1Preset4(voiceCount:1))
        instruments.append(instrument1Tracks)
        mixer.connect(instrument1Tracks)
        AudioKit.output = mixer
    }
    
    func start(){
        //start audiokit output
        AudioKit.start()
    }
    
    func clear(){
        //stop any currently playing tracks first
        stop()
        instruments[selectedInstrument].measure.longestTime = 0.0 //clear
        
        //clear all recorded tracks in selected instrument
        instruments[selectedInstrument].clear()
    }
    
    func playNote(presetNumber: Int){
        //play note based on selected instrument
        print("Playing instrument  \(selectedInstrument) preset \(presetNumber)")
        if(presetNumber < instruments[selectedInstrument].instruments.count){
            let note = instruments[selectedInstrument].instruments[presetNumber].note;
            instruments[selectedInstrument].instruments[presetNumber].playNote(note, velocity: 127)
            instruments[selectedInstrument].instruments[presetNumber].stopNote(note)
        }
        
    }
    
    func addSelectedNote(){
        addNote(preset: selectedPreset)
    }
    
    func addNote(preset presetNumber: Int){
        //play note event if not recording
        
        playNote(presetNumber)
        if !recordEnabled {
            print("Record not enabled, no add note allowed")
            return
        }
        let note = instruments[selectedInstrument].instruments[presetNumber].note;
        //only add note if record is enabled, otherwise just play it
        //add note to current track
        //todo: input to function should a note with vel, note value
        //todo: next add note to current track based on selected instrument (not yet developed)
        let timeElapsed = instruments[selectedInstrument].measure.timeElapsed
        print(String(format: "Time elapsed %f", timeElapsed))
        instruments[selectedInstrument].trackManager.tracks[presetNumber].addNote(note, velocity: 127, position: timeElapsed, duration: 0)
        if !playing { play() }
        
    }
    
    func record(){
        print("Recording instrument \(selectedInstrument) note")
        recordEnabled = true
        instruments[selectedInstrument].record()
        //now addNote function will add notes to sequences track
    }
    
    func play(){
        print("Playing notes of instrument  \(selectedInstrument)")
        //play note in sequence track (just play first track for now)
        instruments[selectedInstrument].play()
        playing = true
        
    }
    
    func stop(){
        print("Stop playing instrument  \(selectedInstrument)")
        recordEnabled = false
        instruments[selectedInstrument].stop()
        playing = false
    }
    
    func setTempo(newBeatsPerMin: Double){
        pause()
        instruments[selectedInstrument].measure.tempo.beatsPerMin = newBeatsPerMin
        print("todo: click track update tempo")
        instruments[selectedInstrument].measure.clickTrack.update(instruments[selectedInstrument].measure.tempo, clickTimeSignature: instruments[selectedInstrument].measure.timeSignature)
        instruments[selectedInstrument].trackManager.setBPM(Double(instruments[selectedInstrument].measure.clickTrack.tempo.beatsPerMin))
        instruments[selectedInstrument].trackManager.setLength(instruments[selectedInstrument].measure.totalDuration)
        unpause()
    }
    
    
    func setTimeSignature(newBeatsPerMeasure: Int, newNote: Int){
        pause()
        instruments[selectedInstrument].measure.timeSignature.beatsPerMeasure = newBeatsPerMeasure
        instruments[selectedInstrument].measure.timeSignature.beatUnit = newNote
        instruments[selectedInstrument].measure.clickTrack.update(instruments[selectedInstrument].measure.tempo, clickTimeSignature: instruments[selectedInstrument].measure.timeSignature)
        instruments[selectedInstrument].trackManager.setLength(instruments[selectedInstrument].measure.totalDuration)
        print("track manager length \(instruments[selectedInstrument].trackManager.length)")
        unpause()
        
    }
    
    func pause(){
        if(playing){
            instruments[selectedInstrument].pause()
        }
    }
    
    func unpause(){
        if(playing){
            instruments[selectedInstrument].unpause()
        }
    }
    
}
