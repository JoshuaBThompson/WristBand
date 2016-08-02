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
    var snareTracks: InstrumentCollection!
    var kickTracks: InstrumentCollection!
    var hatTracks: InstrumentCollection!
    var instruments = [InstrumentCollection]()
    var instrument: InstrumentCollection!
    var timeSignature = TimeSignature()
    var tempo = Tempo()
    var clickTrack: ClickTrack!
    var selectedInstrumentName: String {
        return instrument.instruments[selectedPreset].instrument.name
    }
    
    init(){
        mixer = AKMixer()
        clickTrack = ClickTrack(clickTempo: tempo, clickTimeSignature: timeSignature)
        mixer.connect(clickTrack)
        
        //instrument 1 - snare
        snareTracks = InstrumentCollection(globalClickTrack: clickTrack, preset1: SnareInstrument1(voiceCount:1), preset2: SnareInstrument2(voiceCount:1), preset3: SnareInstrument3(voiceCount:1), preset4: SnareInstrument4(voiceCount:1))
        instruments.append(snareTracks)
        mixer.connect(snareTracks.mixer)
        
        //instrument 2 - kick
        kickTracks = InstrumentCollection(globalClickTrack: clickTrack, preset1: KickInstrument1(voiceCount:1), preset2: KickInstrument2(voiceCount:1), preset3: KickInstrument3(voiceCount:1), preset4: KickInstrument4(voiceCount:1))
        instruments.append(kickTracks)
        mixer.connect(kickTracks.mixer)
        
        //instrument 3 - hat
        hatTracks = InstrumentCollection(globalClickTrack: clickTrack, preset1: HatInstrument1(voiceCount:1), preset2: HatInstrument2(voiceCount:1), preset3: HatInstrument3(voiceCount:1), preset4: HatInstrument4(voiceCount:1))
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
        //stop()
        instrument.clearPreset()
    }
    
    
    
    func clear(){
        //stop any currently playing tracks first
        stop()
        //clear all recorded tracks
        for instTracks in instruments {
            //clear all recorded tracks
            instTracks.clear()
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

    
    func playNote(presetNumber: Int){
        //play note based on selected instrument
        print("Playing instrument  \(selectedInstrument) preset \(presetNumber)")
        if(presetNumber < instrument.instruments.count){
            let note = instrument.instruments[presetNumber].instrument.note;
            instrument.instruments[presetNumber].instrument.playNote(note, velocity: 127)
            instrument.instruments[presetNumber].instrument.stopNote(note)
        }
        
    }
    
    func addSelectedNote(){
        addNote(preset: selectedPreset)
    }
    
    
    func selectInstrument(number: Int){
        if(number < instruments.count){
            if(recordEnabled){
                instrument.deselect() //update track measure length of instruments in collection if first recording of a track
            }
            prevSelectedInstrument = selectedInstrument
            selectedInstrument = number
            instrument = instruments[selectedInstrument]
            
        }
    }
    
    func selectPreset(preset: Int){
        prevSelectedPreset = selectedPreset
        selectedPreset = preset
        instrument.selectPreset(selectedPreset)
    }
    
    func addNote(preset presetNumber: Int){
        //play note event if not recording
        
        playNote(presetNumber)
        if !recordEnabled || !clickTrack.running {
            print("Record not enabled or pre-record not finished, no add note allowed")
            return
        }
        instrument.addNote(preset: presetNumber)
        if !playing {
            print("record started play")
            play()
        }
        
    }
    
    func record(){
        if !playing {
            print("record cannot start before play")
            return
        }
        print("Recording instrument \(selectedInstrument) note")
        recordEnabled = true
        clickTrack.stop() //will be started again after pre-record track is finished
        //clickTrack.timer.start()
        clickTrack.startTimerFromPreRecord()
        //recorded all tracks
        for instNum in 0 ..< instruments.count {
            instruments[instNum].record()
        }
        
        //now addNote function will add notes to sequences track
    }
    
    func stop_record(){
        recordEnabled = false
        clickTrack.timer.stop()
        for instNum in 0 ..< instruments.count {
            instruments[instNum].stop_record()
        }
        
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
        clickTrack.update()
        
        for inst in instruments{
            inst.updateTrackTempo()
        }
    }
    
    
    func setTimeSignature(newBeatsPerMeasure: Int, newNote: Int){
        stop()
        print("update all instruments with beats per measure \(newBeatsPerMeasure) and \(newNote) note")
        clickTrack.timeSignature.beatsPerMeasure = newBeatsPerMeasure
        clickTrack.timeSignature.beatUnit = newNote
        clickTrack.update()
        for inst in instruments{
            inst.updateTrackTimeSignature()
        }
        
    }
    

    
    
}
