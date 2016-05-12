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
    var instrument1Tracks: InstrumentPresetTracksTest!
    //var instrument2Tracks: InstrumentPresetTracks!
    var instruments = [InstrumentPresetTracksTest]()
    var instrument: InstrumentPresetTracksTest!
    
    init(){
        mixer = AKMixer()
        
        //instrument 1
        //instrument1Tracks = InstrumentPresetTracks(preset1: Instrument1Preset1(voiceCount:1), preset2: Instrument1Preset2(voiceCount:1), preset3: Instrument1Preset3(voiceCount:1), preset4: Instrument1Preset4(voiceCount:1))
        //instrument1Tracks = InstrumentPresetTracks(preset1: Instrument1Preset1Test(voiceCount:1), preset2: Instrument1Preset1Test(voiceCount:1), preset3: Instrument1Preset1Test(voiceCount:1), preset4: Instrument1Preset1Test(voiceCount:1))
        instrument1Tracks = InstrumentPresetTracksTest()
        instruments.append(instrument1Tracks)
        mixer.connect(instrument1Tracks.mixer)
        
        //instrument 2
        /*
        //instrument2Tracks = InstrumentPresetTracks(preset1: Instrument2Preset1(voiceCount:1), preset2: Instrument2Preset2(voiceCount:1), preset3: Instrument2Preset3(voiceCount:1), preset4: Instrument2Preset4(voiceCount:1))
        instrument2Tracks = InstrumentPresetTracks(preset1: Instrument1Preset1Test(voiceCount:1), preset2: Instrument1Preset1Test(voiceCount:1), preset3: Instrument1Preset1Test(voiceCount:1), preset4: Instrument1Preset1Test(voiceCount:1))

        instruments.append(instrument2Tracks)
        mixer.connect(instrument2Tracks.mixer)
        */
        
        
        AudioKit.output = mixer
        instrument = instrument1Tracks
    }
    
    func start(){
        //start audiokit output
        AudioKit.start()
        instrument.startClickTrack()
    }
    
    func clear(){
        //stop any currently playing tracks first
        stop()
        //clear all recorded tracks
        for instNum in 0 ..< instruments.count {
            //clear previously recorded longest time in track
            instruments[instNum].measure.longestTime = 0.0
            //clear all recorded tracks in selected instrument
            instruments[instNum].clear()
        }        
        
    }
    
    func selectInstrument(number: Int){
        if(number < instruments.count){
            //change tempo to next instrument
            instrument.stopClickTrack()
            selectedInstrument = number
            instrument = instruments[selectedInstrument]
            
            //start new click track
            instrument.startClickTrack()
            
        }
    }
    
    func playNote(presetNumber: Int){
        //play note based on selected instrument
        print("Playing instrument  \(selectedInstrument) preset \(presetNumber)")
        if(presetNumber < instrument.instruments.count){
            let note = instrument.instruments[presetNumber].note;
            instrument.instruments[presetNumber].playNote(note, velocity: 127)
            instrument.instruments[presetNumber].stopNote(note)
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
        instrument.addNote(preset: presetNumber)
        if !playing { play() }
        
    }
    
    func record(){
        print("Recording instrument \(selectedInstrument) note")
        recordEnabled = true
        //recorded all tracks
        for instNum in 0 ..< instruments.count {
            instruments[instNum].record()
        }
        //now addNote function will add notes to sequences track
    }
    
    func play(){
        print("Playing notes of instrument  \(selectedInstrument)")
        //play note in sequence track (just play first track for now)
        //play all recorded tracks
        for instNum in 0 ..< instruments.count {
            instruments[instNum].play()
        }
        playing = true
        
    }
    
    func stop(){
        print("Stop playing instrument  \(selectedInstrument)")
        recordEnabled = false
        //stop all recorded tracks
        for instNum in 0 ..< instruments.count {
            instruments[instNum].stop()
        }
        playing = false
    }
    
    func setTempo(newBeatsPerMin: Double){
        pause()
        instrument.measure.tempo.beatsPerMin = newBeatsPerMin
        print("todo: click track update tempo")
        instrument.measure.clickTrack.update(instrument.measure.tempo, clickTimeSignature: instrument.measure.timeSignature)
        instrument.trackManager.setBPM(Double(instrument.measure.clickTrack.tempo.beatsPerMin))
        instrument.trackManager.setLength(instrument.measure.totalDuration)
        unpause()
    }
    
    
    func setTimeSignature(newBeatsPerMeasure: Int, newNote: Int){
        pause()
        instrument.measure.timeSignature.beatsPerMeasure = newBeatsPerMeasure
        instrument.measure.timeSignature.beatUnit = newNote
        instrument.measure.clickTrack.update(instrument.measure.tempo, clickTimeSignature: instrument.measure.timeSignature)
        instrument.trackManager.setLength(instrument.measure.totalDuration)
        print("track manager length \(instrument.trackManager.length)")
        unpause()
        
    }
    
    func pause(){
        if(playing){
            //stop all recorded tracks
            for instNum in 0 ..< instruments.count {
                instruments[instNum].pause()
            }
        }
    }
    
    func unpause(){
        if(playing){
            //stop all recorded tracks
            for instNum in 0 ..< instruments.count {
                instruments[instNum].unpause()
            }
        }
    }
    
}
