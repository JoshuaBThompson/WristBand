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
    var quantizeResolution = 1.0
    var quantizeEnabled = false
    var presetsPerInst = 4
    var noteAdded = false
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
    var timeSignature = TimeSignature()
    var tempo = Tempo()
    var clickTrack: ClickTrack!
    
    //MARK: computed variables
    
    var presetMeasureCount: Int {
        return instruments[selectedPreset].instruments[selectedPreset].trackManager.measureCount
    }
    var selectedInstrumentName: String {
        return instruments[selectedInstrument].instruments[selectedPreset].instrument.name
    }
    
    var instrument: InstrumentCollection {
        return instruments[selectedInstrument]
    }
    
    var presetTrack: InstrumentTrack {
        return instruments[selectedInstrument].instruments[selectedPreset]
    }
    
    init(){
        mixer = AKMixer()
        clickTrack = ClickTrack(songRef: self, clickTempo: tempo, clickTimeSignature: timeSignature)
        mixer.connect(clickTrack)
        
        
        //instrument 1 - snare
        snareTracks = InstrumentCollection(globalClickTrack: clickTrack, preset1: SnareInstrument1(), preset2: SnareInstrument2(), preset3: SnareInstrument3(), preset4: SnareInstrument4())
        instruments.append(snareTracks)
        mixer.connect(snareTracks.mixer)
        
        //instrument 2 - kick
        kickTracks = InstrumentCollection(globalClickTrack: clickTrack, preset1: KickInstrument1(), preset2: KickInstrument2(), preset3: KickInstrument3(), preset4: KickInstrument4())
        instruments.append(kickTracks)
        mixer.connect(kickTracks.mixer)
        
        //instrument 3 - hat
        hatTracks = InstrumentCollection(globalClickTrack: clickTrack, preset1: HatInstrument1(), preset2: HatInstrument2(), preset3: HatInstrument3(), preset4: HatInstrument4())
        instruments.append(hatTracks)
        mixer.connect(hatTracks.mixer)
        
        //Use click track of inst 1 (doesn't matter which one since they all have same click track)
        AudioKit.output = mixer
    }
    
    func start(){
        //start audiokit output
        AudioKit.start()
    }
    func clearPreset(){
        //stop()
        instruments[selectedInstrument].clearPreset()
    }
    
    func clear(){
        print("calling collections clear!")
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

    
    func playNote(){
        //play note based on selected instrument
        let note = instruments[selectedInstrument].instruments[selectedPreset].instrument.note
        instruments[selectedInstrument].instruments[selectedPreset].instrument.play(noteNumber: note, velocity: 127)
        instruments[selectedInstrument].instruments[selectedPreset].instrument.stop(noteNumber: note)
    }

    
    func selectInstrumentFromPreset(preset: Int){
        let presetNum = preset % presetsPerInst //ex: if preset = 2 then presetNum = 2%4 = 2
        let instNum = preset / presetsPerInst  //ex: instNum = 2/4 = 0
        
        selectPreset(presetNum)
        selectInstrument(instNum)
    }
    
    func selectInstrument(number: Int){
        if(number < instruments.count){
            if(recordEnabled){
                instruments[selectedInstrument].deselect()
                //update track measure length of instruments in collection if first recording of a track
            }
            prevSelectedInstrument = selectedInstrument
            selectedInstrument = number
            
        }
    }
    
    func selectPreset(preset: Int){
        prevSelectedPreset = selectedPreset
        selectedPreset = preset
        instruments[selectedInstrument].selectPreset(selectedPreset)
        if(recordEnabled && presetTrack.trackManager.firstInstance && presetTrack.trackManager.noteCount >= 1){
            clickTrack.timer.start() //reset timer when changing to new instrument
        }
        else if(recordEnabled && noteAdded){
            stop_record()
        }
    }
    
    func addNote(){
        //play note event if not recording
        
        playNote()
        if !recordEnabled || !clickTrack.running {
            print("Record not enabled or pre-record not finished, no add note allowed")
            return
        }
        noteAdded = true
        instruments[selectedInstrument].addNote(preset: selectedPreset)
        if !playing {
            print("record started play")
            play()
        }
    }
    
    //MARK: update quantize
    func updatePresetQuantize(enabled enable: Bool=true, resolution: Double=1.0){
        if(enable){
            quantizeEnabled = true
            quantizeResolution = resolution
            instruments[selectedInstrument].enablePresetQuantize()
            instruments[selectedInstrument].updatePresetQuantize(resolution)
        }
        else{
            quantizeEnabled = true
            instruments[selectedInstrument].disablePresetQuantize()
        }
    }
    
    //MARK: change measure count of a preset track
    func updatePresetMeasureCount(count: Int){
        instruments[selectedInstrument].updatePresetMeasureCount(count)
    }
    
    //MARK: set current preset to mute
    func mutePreset(){
        
        instruments[selectedInstrument].mutePreset()
    }
    
    func unmutePreset(){
        instruments[selectedInstrument].unmutePreset()
    }
    
    
    //MARK: set current preset to solo (mute all other preset tracks but keep them looping)
    func enableSoloPreset(){
        instruments[selectedInstrument].soloPreset()
        
        for instNum in 0 ..< instruments.count {
            //mute all others
            if(instNum != selectedInstrument){
                instruments[instNum].muteAll()
            }
        }
    }
    
    //MARK: unmute all presets
    func disableSoloPreset(){
        
        for instNum in 0 ..< instruments.count {
            instruments[instNum].unmuteAll()
        }
    }
    
    func start_record(){
        recordEnabled = true
        clickTrack.timer.start()
        noteAdded = false
        
        //recorded all tracks
        for instNum in 0 ..< instruments.count {
            instruments[instNum].record()
        }
        
        //now addNote function will add notes to sequences track
    }
    
    
    func record(){
        if !playing {
            print("record cannot start before play")
            return
        }
        clickTrack.start_preroll()
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
