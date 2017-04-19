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

protocol SongCallbacks: class {
    func stopRecordFromSong()
    func updateTimelineAfterDelete()
    func startRecordFromSong()
}

class Song {
    var noteAdded = false
    var selectedInstrument = 0
    var prevSelectedInstrument = 0
    var mixer: AKMixer!
    var notePosition: Double = 1
    var recordEnabled = false
    var playing = false
    var instruments = [InstrumentManager]()
    var timeSignature = TimeSignature()
    var tempo = Tempo()
    var clickTrack: ClickTrack!
    var songsDatabase: [SongDatabase]!
    var current_song: SongDatabase!
    var loadSavedSongs = true
    var sound_library: SoundLibrary!
    var delegate: SongCallbacks?

    //MARK: computed variables
    var timeline: LoopTimeline {
        return self.instrument.timeline
    }
    
    var defaultMeasureCount: Int {
        return clickTrack.instrument.defaultMeasures
    }
    
    var presetMeasureCount: Int {
        return instrument.measures
    }
    var selectedInstrumentName: String {
        return instrument.midi_instrument.name
    }
    
    var presetVolumePercent: Int {
        return Int(instrument.midi_instrument.volume * 100.0)
    }
    
    var instrument: InstrumentManager {
        return instruments[selectedInstrument]
    }
    
    var currentPan: Double {
        return instrument.midi_instrument.panner.pan
    }
    
    var currentPanPercent: Double {
        return instrument.midi_instrument.panner.pan * 100.0
    }
    
    init(){
        mixer = AKMixer()
        clickTrack = ClickTrack(songRef: self, clickTempo: tempo, clickTimeSignature: timeSignature)
        mixer.connect(clickTrack)
        sound_library = SoundLibrary() //load instrument sounds from default library 'Sounds_Extra' in main bundle
        loadNewSong()
        
        //connect all instrument outputs to Audiokit output
        AudioKit.output = mixer

    }
    
    func initInstruments(){
        for instrument in sound_library.instruments {
            let instrument_manager = InstrumentManager(click_track: clickTrack, midi_instrument: instrument)
            instruments.append(instrument_manager)
            mixer.connect(instrument_manager.midi_instrument.panner)
        }
        
    }
    
    
    func getSavedSongs() -> [SongDatabase]? {
        print("Song database file path: \(SongDatabase.ArchiveURL.path)")
        let saved_songs =  NSKeyedUnarchiver.unarchiveObject(withFile: SongDatabase.ArchiveURL.path) as? [SongDatabase]
        if(saved_songs != nil){
            for song in saved_songs! {
                song.save = true
            }
        }
        return saved_songs
    }
    
    func loadSong(song_num: Int){
        if let savedSongs = getSavedSongs(){
            songsDatabase = savedSongs
            if(song_num < songsDatabase.count){
                //now stop current song and clear track notes in cache
                clear()
                
                //now load saved song track data
                self.setCurrentSong(song_num: song_num)
                self.loadInstruments()
            }
        }
        else{
            print("loadSong Error: Song \(song_num) not available in songs database")
        }
    }
    
    func setCurrentSong(song_num: Int){
        if(song_num < songsDatabase.count){
            self.current_song = songsDatabase[song_num]
            //now update global variables
            let saved_tempo = Double(self.current_song.tempo!)
            let saved_global_measues = self.current_song.global_measures
            let saved_time_sig_beats = self.current_song.time_sig_beats
            let saved_time_sig_note = self.current_song.time_sig_note
            
            setTempo(saved_tempo)
            setTimeSignature(saved_time_sig_beats!, beatUnit: saved_time_sig_note!)
            setDefaultMeasures(measureCount: saved_global_measues!)
            
        }
    }
    
    func loadNewSong(){
        if(loadSavedSongs){
            if let savedSongs = getSavedSongs(){
                songsDatabase = savedSongs
            }
        }
        if((songsDatabase) == nil){
            print("Could not load saved song")
            self.songsDatabase = [SongDatabase]()
        }
        
        self.current_song = SongDatabase()
        self.current_song.name = "Unsaved Song"
        loadInstruments()
    }
    
    func loadTrack(instrument_manager: InstrumentManager, num: Int){
        
        if(songsDatabase == nil){
            return
        }
        if(num < self.current_song.tracks.count){
            self.current_song.tracks[num].loadSavedTrack()
            instrument_manager.clear()
            instrument_manager.notes = self.current_song.tracks[num].track
            instrument_manager.recorded = (instrument_manager.notes.count > 0) ? false : true
            instrument_manager.measures = self.current_song.tracks[num].measures
            instrument_manager.midi_instrument.panner.pan = self.current_song.tracks[num].pan
            instrument_manager.midi_instrument.volume = self.current_song.tracks[num].volume
            
            print("loaded saved track \(num)")
        }
        else{
            let count = self.current_song.tracks.count
            let newSongTrack = SongTrack()
            newSongTrack.loadNewTrack(instrument_manager: instrument_manager)
            instrument_manager.notes = newSongTrack.track
            self.current_song.tracks.append(newSongTrack)
            print("loaded new track \(count)")
        }
    }
    
    func isSongSaved()->Bool{
        return self.current_song.save
    }
    
    func setSongSave(){
        print("set current song for saving")
        current_song.save = true
        if(songsDatabase != nil){
            if(!songsDatabase.contains(where: {$0 === current_song})){
                songsDatabase.append(current_song)
            }
        }
    }
    
    func setSongName(name: String){
        self.current_song.name = name
    }
    
    func getSongName(song_num: Int)->String{
        if(song_num < self.songsDatabase.count){
            return self.songsDatabase[song_num].name
        }
        else{
            return "Invalid Song"
        }
    }
    func deleteSong(num: Int){
        self.stop()
        if(num < songsDatabase.count){
            print("Deleting song \(num)")
            if(self.current_song == self.songsDatabase[num]){
                self.current_song = nil
            }
            self.songsDatabase.remove(at: num)
            
            //update database after removing song
            self.saveSongDatabase()
            
            //now load new empty song to take deleted songs place
            self.loadNewSong()
        }
    }
    
    func saveSong(){
        if(songsDatabase == nil || self.current_song == nil){
            return
        }
        
        //only save song if marked for saving
        if(!self.current_song.save){
            print("song not set for saving")
            return
        }
        
        /* save global vars */
        self.current_song.tempo = Int(self.clickTrack.tempo.beatsPerMin)
        self.current_song.global_measures = clickTrack.instrument.defaultMeasures
        self.current_song.time_sig_beats = clickTrack.timeSignature.beatsPerMeasure
        self.current_song.time_sig_note = clickTrack.timeSignature.beatUnit
        
        /* save track vars */
        for i in 0 ..< self.current_song.tracks.count {
            self.current_song.tracks[i].loadNewTrack(instrument_manager: instruments[i])
            print("Saving song pan \(self.current_song.tracks[i].pan)")
            
        }
        
        self.saveSongDatabase()
        
    }
    
    func saveSongDatabase(){
        print("Song database file path: \(SongDatabase.ArchiveURL.path)")
        let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(songsDatabase, toFile: SongDatabase.ArchiveURL.path)
        if !isSuccessfulSave {
            print("Failed to save song...")
        }
    }
    
    
    func loadInstruments(){
        //Load instruments for current_song
        
        if(instruments.count == 0){
            initInstruments() //create instruments with blank tracks
        }
        
        
        //now load saved track data from database
        for instNum in 0 ..< instruments.count {
            loadTrack(instrument_manager: instruments[instNum], num: instNum)
        }
        
        saveSong()
        
    }
    

    func updateMeasureTimeline()->Bool{
        let recorded = self.instrument.recorded//!self.instrument.trackManager.firstInstance
        let ready: Bool = (recorded || recordEnabled)
        if(!playing || !ready){
            return false
        }
        
        self.instrument.timeline.update()
        return true
    }
    
    func start(){
        //start audiokit output
        AudioKit.start()
    }
    func clearPreset(){
        //stop()
        instrument.clear()
    }
    
    func deleteTrack(){
        clearPreset()
        delegate?.updateTimelineAfterDelete()
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
        let note = instruments[selectedInstrument].midi_instrument.midi_note
        instruments[selectedInstrument].midi_instrument.rawPlay(note, velocity: 127)
        instruments[selectedInstrument].midi_instrument.stop(noteNumber: MIDINoteNumber(note))
    }
    
    func selectInstrument(_ number: Int){
        print("Selecting instrument \(number)")
        if(number < instruments.count){
            if(recordEnabled){
                instrument.stopRecord()
                stop_record()
                //update track measure length of instruments in collection if first recording of a track
            }
            prevSelectedInstrument = selectedInstrument
            selectedInstrument = number
            
        }
    }
    
    func selectInstrumentByAssignedPosition(_ position: Int){
        //use sound_library.position_map to get sound mapped know position
        var i = 0
        for inst in instruments {
            let name = inst.midi_instrument.name
            let pos = self.sound_library.position_map[name]
            if(pos == position){
                selectInstrument(i)
                return
            }
            i += 1
        }
    }
    
    func addNote(){
        //play note event if not recording
        
        playNote()
        let last_preroll = clickTrack.instrument.preRollEnded
        if (!recordEnabled || !clickTrack.running) && !last_preroll {
            //print("Record not enabled or pre-record not finished, no add note allowed")
            return
        }
        noteAdded = true
        instruments[selectedInstrument].addNote()
    }
    
    //MARK: update quantize
    func updatePresetQuantize(enabled enable: Bool=true, resolution: Double=1.0, triplet_en: Bool = false){
        if(enable){
            //track specific update only
            instrument.quantize_enabled = true
            instrument.quantizer.update(resolution, triplet_en: triplet_en, beat_scale: clickTrack.timeSignature.beatScale)
            instrument.updateLoopAfterQuantize()
            
        }
        else{
            instrument.quantize_enabled = false
            instrument.updateLoopAfterQuantize()
            
        }
    }
    
    //MARK: change measure count of a preset track
    func updatePresetMeasureCount(_ count: Int){
        print("updated inst \(selectedInstrument) measure count to \(count)")
        instrument.updateMeasure(count: count)
    }
    
    //MARK: set current preset to mute
    func mutePreset(){
        
        instrument.midi_instrument.muted = true
    }
    
    func unmutePreset(){
        instrument.midi_instrument.muted = false
    }
    
    //MARK: Volume - update preset volume (percent 0 - 100%)
    func updatePresetVolume(_ percent: Double){
        //select volume 0-100% ( corresponds to midi velocity 0 - 127 )
        var vol = percent
        
        //make sure volume within range
        if(vol >= 100.0){vol = 100.0}
        if(vol < 0.0){vol = 0.0}
        
        //now all volume of notes heard for preset will be amplified or decreased by scale factor
        instrument.midi_instrument.volume = vol/100.0
        
    }
    
    //MARK: Pan - update preset pan (-1 left, 0 center, 1 right and everything else in between)
    func updatePresetPan(_ pan: Double){
        if(pan != self.currentPan){
            instrument.midi_instrument.panner.pan = pan
        }
    }
    
    //like updatePresetPan but use % instead of actual decimal value: ex 0.01 is the same as 1% so input 1, 1 is the same as 100% so input 100
    func updatePresetPanPercent(_ panPercent: Double){
        var pan = panPercent/100.0
        if panPercent > 100.0 {
            pan = 1.0
        }
        else if panPercent < -100.0 {
            pan = -1.0
        }
        if(pan != self.currentPan){
            print("pan percent \(pan)")
            instrument.midi_instrument.panner.pan = pan
        }
    }
    
    
    func decPresetPan(){
        let currentPan = self.currentPan
        
        //decrease volume by 0.01 (out of 1)
        updatePresetPan(currentPan - 0.01)
    }
    
    func incPresetPan(){
        let currentPan = self.currentPan
        
        //increase volume by 0.01 (out of 1)
        updatePresetPan(currentPan + 0.01)
    }
    
    //MARK: Instrument volume updates
    func decPresetVolume(){
        let currentVol = instruments[selectedInstrument].volume
        
        //decrease volume by 1% (out of 100%)
        updatePresetVolume(currentVol-1)
    }
    
    func incPresetVolume(){
        let currentVol = instruments[selectedInstrument].volume
        
        //increase volume by 1% (out of 100%)
        updatePresetVolume(currentVol+1)
    }
    
    
    //MARK: set current preset to solo (mute all other preset tracks but keep them looping)
    func enableSoloPreset(){
        for instNum in 0 ..< instruments.count{
            if(instNum != selectedInstrument){
                instruments[instNum].midi_instrument.muted = true
            }
            else{
                instruments[instNum].midi_instrument.muted = false
            }
        }
    }
    
    //MARK: unmute all presets
    func disableSoloPreset(){
        
        for instNum in 0 ..< instruments.count{
            instruments[instNum].midi_instrument.muted = false
        }
    }
    
    
    func start_record(){
        
        if(!instrument.recorded){
            //todo?
        }
        instrument.record()
        recordEnabled = true
        noteAdded = false
        delegate?.startRecordFromSong()
        //now addNote function will add notes to sequences track
    }
    
    
    func record(){
        if !playing {
            print("record cannot start before play")
            return
        }
        if(!instrument.recorded){
            //only start preroll if selected preset is empty / has not been recorded
            clickTrack.instrument.resetDefaultMeasureCounter()
            clickTrack.start_preroll()
            clickTrack.instrument.newRecordEnabled = true
        }
        else{
            start_record()
        }
        
    }
    
    func stop_record(){
        if(!recordEnabled){
            //only do execute stop_record if recording
            return
        }
        recordEnabled = false
        clickTrack.instrument.newRecordEnabled = recordEnabled
        instrument.stopRecord()
        saveSong()
    }
    
    func play(){
        print("Playing notes of instrument  \(selectedInstrument)")
        
        if(!clickTrack.enabled){
            clickTrack.enable() //run click track but mute it
        }
        clickTrack.reset()
        
        for inst in instruments{
            inst.play()
        }
        playing = true
        //clickTrack.timer.start()
        clickTrack.start() //start global multitrack
        
    }
    
    func startPresetWithDefaultMeasureCount(){
        //tells preset to use the defaultMeasure count (global measure) instead of waiting for user to hit 'stop' record
        self.instrument.startLoopFromDefaultMeasures()
        self.stop_record()
        self.delegate?.stopRecordFromSong()
        
    }
    
    func stop(){
        print("Stop playing instrument  \(selectedInstrument)")
        //recordEnabled = false
        //stop all recorded tracks
        clickTrack.stop()
        for inst in instruments{
            inst.stop()
        }
        
        recordEnabled = false
        playing = false
        saveSong()
    }
    
    func setTempo(_ newBeatsPerMin: Double){
        //stop()
        clickTrack.tempo.set_tempo(bpm: newBeatsPerMin)
        clickTrack.update()
        
    }
    
    func setDefaultMeasures(measureCount: Int){
        clickTrack.instrument.defaultMeasures = measureCount
        for inst in instruments {
            //only override local instrument default measure if it was not recorded yet
            if(!inst.recorded){
                inst.updateMeasure(count: measureCount)
            }
        }
    }
    
    func setTimeSignature(_ newBeatsPerMeasure: Int, beatUnit: Int){
        if(!playing){
            clickTrack.timeSignature.beatsPerMeasure = clickTrack.timeSignature.getBeatsPerMeasure(bpm: newBeatsPerMeasure)
            clickTrack.timeSignature.beatUnit = clickTrack.timeSignature.getBeatUnit(beat_unit: beatUnit)
            clickTrack.reset(clearAll: true)
        }
        
    }
    
    func updateLoopFromClickTrack(){
        for inst in instruments {
            inst.updateLoopFromClickTrack()
        }
    }
    
    func updateNotesFromClickTrack(){
        for inst in instruments {
            inst.updateNotesFromClickTrack()
        }
    }
    
    
}
