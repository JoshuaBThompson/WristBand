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
}

class Song {
    var quantizeResolution = 1.0
    var quantizeEnabled = false
    var noteAdded = false
    var selectedInstrument = 0
    var prevSelectedInstrument = 0
    var mixer: AKMixer!
    var notePosition: Double = 1
    var recordEnabled = false
    var playing = false
    var instruments = [InstrumentTrack]()
    var timeSignature = TimeSignature()
    var tempo = Tempo()
    var clickTrack: ClickTrack!
    var songsDatabase: [SongDatabase]!
    var current_song: SongDatabase!
    var loadSavedSongs = true
    var sound_library: SoundLibrary!
    var delegate: SongCallbacks?

    //MARK: computed variables
    var timeline: MeasureTimeline {
        return self.instrument.trackManager.timeline
    }
    
    var defaultMeasureCount: Int {
        return clickTrack.instrument.defaultMeasures
    }
    
    var presetMeasureCount: Int {
        return instruments[selectedInstrument].trackManager.measureCount
    }
    var selectedInstrumentName: String {
        return instruments[selectedInstrument].instrument.name
    }
    
    var presetVolumePercent: Int {
        return Int(instruments[selectedInstrument].volume)
    }
    
    var instrument: InstrumentTrack {
        return instruments[selectedInstrument]
    }
    
    var currentPan: Double {
        return instruments[selectedInstrument].pan
    }
    
    var currentPanPercent: Double {
        return instruments[selectedInstrument].pan * 100.0
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
            let inst_track = InstrumentTrack(clickTrack: clickTrack, presetInst: instrument)
            instruments.append(inst_track)
            mixer.connect(inst_track.instrument.panner)
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
    
    func loadTrack(track: TrackManager, num: Int){
        
        if(songsDatabase == nil){
            return
        }
        if(num < self.current_song.tracks.count){
            self.current_song.tracks[num].loadSavedTrack()
            track.clear()
            track.trackNotes = self.current_song.tracks[num].track
            track.velNotes = self.current_song.tracks[num].velocity
            track.durNotes = self.current_song.tracks[num].duration
            track.firstInstance = (track.trackNotes.count > 0) ? false : true
            track.updateMeasureCount(self.current_song.tracks[num].measures)
            track.instrument.updatePan(self.current_song.tracks[num].pan)
            track.instrument.updateVolume(self.current_song.tracks[num].volume)
            track.appendTrack(offset: 0)
            
            print("loaded saved track \(num)")
        }
        else{
            let count = self.current_song.tracks.count
            let newSongTrack = SongTrack()
            newSongTrack.loadNewTrack(trackManager: track)
            track.trackNotes = newSongTrack.track
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
        
        for i in 0 ..< self.current_song.tracks.count {
            self.current_song.tracks[i].loadNewTrack(trackManager: instruments[i].trackManager)
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
            loadTrack(track: instruments[instNum].trackManager, num: instNum)
        }
        
        saveSong()
        
    }
    

    func updateMeasureTimeline()->Bool{
        let recorded = !self.instrument.trackManager.firstInstance
        let ready: Bool = (recorded || recordEnabled)
        if(!playing || !ready){
            return false
        }
        
        self.instrument.trackManager.timeline.update()
        return true
    }
    
    func start(){
        //start audiokit output
        AudioKit.start()
    }
    func clearPreset(){
        //stop()
        instruments[selectedInstrument].trackManager.clear()
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
            instTracks.trackManager.clear()
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
        let note = instruments[selectedInstrument].instrument.note
        instruments[selectedInstrument].instrument.play(noteNumber: note, velocity: 127)
        instruments[selectedInstrument].instrument.stop(noteNumber: note)
    }
    
    func selectInstrument(_ number: Int){
        print("Selecting instrument \(number)")
        if(number < instruments.count){
            if(recordEnabled){
                instruments[selectedInstrument].deselect()
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
            let name = inst.instrument.name
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
        if !recordEnabled || !clickTrack.running {
            //print("Record not enabled or pre-record not finished, no add note allowed")
            return
        }
        noteAdded = true
        let duration = instrument.trackManager.minBeatDuration
        instruments[selectedInstrument].addNote(127, duration: duration)
        if !playing {
            print("record started play")
            play()
        }
    }
    
    //MARK: update quantize
    func updatePresetQuantize(enabled enable: Bool=true, resolution: Double=1.0, triplet_en: Bool = false){
        if(enable){
            quantizeEnabled = true
            quantizeResolution = resolution
            /* quantize should be track specific so don't update all track quantize
            for inst in instruments {
                inst.enableQuantize()
                inst.updateQuantize(resolution)
            }
            */
            
            //track specific update only
            instruments[selectedInstrument].enableQuantize()
            instruments[selectedInstrument].updateQuantize(resolution, triplet_en: triplet_en)
        }
        else{
            quantizeEnabled = false
            /*
            for inst in instruments {
                inst.disableQuantize()
            }
            */
            instruments[selectedInstrument].disableQuantize()
        }
    }
    
    //MARK: change measure count of a preset track
    func updatePresetMeasureCount(_ count: Int){
        print("updated inst \(selectedInstrument) measure count to \(count)")
        instruments[selectedInstrument].updateMeasureCount(count)
    }
    
    //MARK: set current preset to mute
    func mutePreset(){
        
        instruments[selectedInstrument].instrument.mute()
    }
    
    func unmutePreset(){
        instruments[selectedInstrument].instrument.unmute()
    }
    
    //MARK: Volume - update preset volume (percent 0 - 100%)
    func updatePresetVolume(_ percent: Double){
        //select volume 0-100% ( corresponds to midi velocity 0 - 127 )
        var vol = percent
        
        //make sure volume within range
        if(vol >= 100.0){vol = 100.0}
        if(vol < 0.0){vol = 0.0}
        
        //now all volume of notes heard for preset will be amplified or decreased by scale factor
        instruments[selectedInstrument].updateVolume(vol)
        
    }
    
    //MARK: Pan - update preset pan (-1 left, 0 center, 1 right and everything else in between)
    func updatePresetPan(_ pan: Double){
        if(pan != self.currentPan){
            instruments[selectedInstrument].updatePan(pan)
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
            instruments[selectedInstrument].updatePan(pan)
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
                instruments[instNum].instrument.mute()
            }
            else{
                instruments[instNum].instrument.unmute()
            }
        }
    }
    
    //MARK: unmute all presets
    func disableSoloPreset(){
        
        for instNum in 0 ..< instruments.count{
            instruments[instNum].instrument.unmute()
        }
    }
    
    func start_record(){
        
        if(instruments[selectedInstrument].trackManager.firstInstance){
            //only restart timer if new track otherwise timer should have already been started in the play function
            clickTrack.timer.start()
        }
        instruments[selectedInstrument].record()
        recordEnabled = true
        noteAdded = false
        //now addNote function will add notes to sequences track
    }
    
    
    func record(){
        if !playing {
            print("record cannot start before play")
            return
        }
        if(instruments[selectedInstrument].trackManager.firstInstance){
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
        //clickTrack.timer.stop()
        for inst in instruments{
            inst.recording = false
            inst.deselect()
        }
        
        saveSong()
        
    }
    
    func play(){
        print("Playing notes of instrument  \(selectedInstrument)")
        
        if(!clickTrack.enabled){
            clickTrack.enable() //run click track but mute it
        }
        clickTrack.reset()
        
        for inst in instruments{
            inst.instrument.reset()
            inst.trackManager.startRecordOffset = 0.0
            inst.trackManager.resetTrack()
        }
        playing = true
        //clickTrack.timer.start()
        clickTrack.start() //start global multitrack
        
    }
    
    func startPresetWithDefaultMeasureCount(){
        //tells preset to use the defaultMeasure count (global measure) instead of waiting for user to hit 'stop' record
        self.instrument.trackManager.startLoopFromDefaultMeasures()
        self.stop_record()
        self.delegate?.stopRecordFromSong()
        
    }
    
    func stop(){
        print("Stop playing instrument  \(selectedInstrument)")
        //recordEnabled = false
        //stop all recorded tracks
        clickTrack.stop()
        if(recordEnabled){
            for inst in instruments{
                inst.deselect()
            }
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
    }
    
    func setTimeSignature(_ newBeatsPerMeasure: Int, beatUnit: Int){
        if(!playing){
            clickTrack.timeSignature.beatsPerMeasure = clickTrack.timeSignature.getBeatsPerMeasure(bpm: newBeatsPerMeasure)
            clickTrack.timeSignature.beatUnit = clickTrack.timeSignature.getBeatUnit(beat_unit: beatUnit)
            clickTrack.reset(clearAll: true)
        }
        
    }
    
    
}
