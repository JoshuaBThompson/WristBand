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
    var prevSelectedInstrument = 0
    var selectedPreset = 0
    var prevSelectedPreset = 0
    var mixer: AKMixer!
    var notePosition: Double = 1
    var recordEnabled = false
    var playing = false
    var snareTracks: InstrumentPresetTracks!
    var kickTracks: InstrumentPresetTracks!
    var hatTracks: InstrumentPresetTracks!
    var instruments = [InstrumentPresetTracks]()
    var instrument: InstrumentPresetTracks!
    var timeSignature = TimeSignature()
    var tempo = Tempo()
    var clickTrack: ClickTrack!
    var selectedInstrumentName: String {
        return instrument.instruments[selectedPreset].name
    }
    
    init(){
        mixer = AKMixer()
        clickTrack = ClickTrack(clickTempo: tempo, clickTimeSignature: timeSignature)
        
        
        //instrument 1 - snare
        snareTracks = InstrumentPresetTracks(clickTrack: clickTrack, preset1: SnareInstrument1(voiceCount:1), preset2: SnareInstrument2(voiceCount:1), preset3: SnareInstrument3(voiceCount:1), preset4: SnareInstrument4(voiceCount:1))
        instruments.append(snareTracks)
        mixer.connect(snareTracks.mixer)
        
        //instrument 2 - kick
        kickTracks = InstrumentPresetTracks(clickTrack: clickTrack, preset1: KickInstrument1(voiceCount:1), preset2: KickInstrument2(voiceCount:1), preset3: KickInstrument3(voiceCount:1), preset4: KickInstrument4(voiceCount:1))
        instruments.append(kickTracks)
        mixer.connect(kickTracks.mixer)
        
        //instrument 3 - hat
        hatTracks = InstrumentPresetTracks(clickTrack: clickTrack, preset1: HatInstrument1(voiceCount:1), preset2: HatInstrument2(voiceCount:1), preset3: HatInstrument3(voiceCount:1), preset4: HatInstrument4(voiceCount:1))
        instruments.append(hatTracks)
        mixer.connect(hatTracks.mixer)
        
        //Use click track of inst 1 (doesn't matter which one since they all have same click track)
        AudioKit.output = mixer
        instrument = snareTracks //just start of with snare instruments as initial collection (we can change this later...)
    }
    
    func start(){
        //start audiokit output
        AudioKit.start()
    }
    func clearPreset(){
        stop()
        instrument.clearPreset()
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
    
    func enableClickTrack(){
        clickTrack.unmute()
        clickTrack.enable()
        
    }
    
    func disableClickTrack(){
        clickTrack.disable()
    }
    
    
    func toggleClickTrackMute(){
        if(clickTrack.muted){
            clickTrack.unmute()
        }
        else{
            clickTrack.mute()
        }
        
    }
    
    func selectInstrument(number: Int){
        if(number < instruments.count){
            prevSelectedInstrument = selectedInstrument
            selectedInstrument = number
            instrument = instruments[selectedInstrument]
            
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
    
    func selectPreset(preset: Int){
        prevSelectedPreset = selectedPreset
        selectedPreset = preset
        instrument.selectedInst = selectedPreset
    }
    
    func addNote(preset presetNumber: Int){
        //play note event if not recording
        
        playNote(presetNumber)
        if !recordEnabled {
            print("Record not enabled, no add note allowed")
            return
        }
        instrument.addNote(preset: presetNumber)
        if !playing {
            print("record started play")
            play()
        }
        
    }
    
    func record(){
        print("Recording instrument \(selectedInstrument) note")
        recordEnabled = true
        //recorded all tracks
        for instNum in 0 ..< instruments.count {
            instruments[instNum].record()
        }
        if !playing {
            print("record started play")
            play()
        }
        //now addNote function will add notes to sequences track
    }
    
    func play(){
        print("Playing notes of instrument  \(selectedInstrument)")
        //play note in sequence track (just play first track for now)
        //play all recorded tracks
        if(!clickTrack.enabled){
            clickTrack.enable() //run click track but mute it
        }
        clickTrack.start()
        for instNum in 0 ..< instruments.count {
            instruments[instNum].play()
        }
        playing = true
        
    }
    
    func stop(){
        print("Stop playing instrument  \(selectedInstrument)")
        recordEnabled = false
        //stop all recorded tracks
        clickTrack.stop()
        for instNum in 0 ..< instruments.count {
            instruments[instNum].stop()
        }
        playing = false
    }
    
    func setTempo(newBeatsPerMin: Double){
        stop()
        print("update all instruments with tempo \(newBeatsPerMin)")
        clickTrack.tempo.beatsPerMin = newBeatsPerMin
        let tempo = clickTrack.tempo
        let timeSig = clickTrack.timeSignature
        clickTrack.update(tempo, clickTimeSignature:timeSig)
        
        for inst in instruments{
            inst.trackManager.setBPM(Double(instrument.measure.clickTrack.tempo.beatsPerMin))
            inst.trackManager.setLength(instrument.measure.totalDuration)
        }
    }
    
    
    func setTimeSignature(newBeatsPerMeasure: Int, newNote: Int){
        stop()
        print("update all instruments with beats per measure \(newBeatsPerMeasure) and \(newNote) note")
        clickTrack.timeSignature.beatsPerMeasure = newBeatsPerMeasure
        clickTrack.timeSignature.beatUnit = newNote
        let tempo = clickTrack.tempo
        let timeSig = clickTrack.timeSignature
        clickTrack.update(tempo, clickTimeSignature: timeSig)
        for inst in instruments{
            inst.trackManager.setLength(instrument.measure.totalDuration)
        }
        
    }
    

    
    
}
