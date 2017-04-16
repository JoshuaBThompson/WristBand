//
//  SongDatabase.swift
//  Groover
//
//  Created by Joshua Thompson on 10/14/16.
//  Copyright © 2016 TCM. All rights reserved.
//

import Foundation
import AudioKit

//SongDatabase: Responsible for storing songs created by user
//              Uses iOS persistent data to store data


//Song saved data properties struct
struct SongPropertyKey {
    static let nameKey = "name"
    static let tracksKey = "tracks"
    static let tempoKey = "tempo"
    static let measuresKey = "measures"
    static let timeSigBeatsKey = "time_sig_beats"
    static let timeSigNoteKey = "time_sig_note"
}

struct SongTrackPropertyKey {
    static let trackBeatsKey = "trackBeats"
    static let trackTemposKey = "trackTempos"
    static let trackNoteVelocityKey = "trackNoteVelocity"
    static let trackNoteDurationKey = "trackNoteDuration"
    static let trackPanKey = "trackPan"
    static let trackVolumeKey = "trackVolume"
    static let trackMeasuresKey = "trackMeasures"
}

class SongTrack: NSObject, NSCoding {
    var name: String!
    var track = [AKDuration]()
    var beats: [Double]!
    var tempos: [Double]!
    var velocity: [Int]!
    var duration: [Double]!
    var pan: Double!
    var volume: Double!
    var measures: Int!
    
    
    init(beats: [Double] = [Double](), tempos: [Double] = [Double](), velocity: [Int] = [Int](), duration: [Double] = [Double](),
         pan: Double = 0, volume: Double = 100, measures: Int = 1){
        super.init()
        self.beats = beats
        self.tempos = tempos
        self.velocity = velocity
        self.duration = duration
        self.pan = pan
        self.volume = volume
        self.measures = measures
        
    }
    
    //MARK: NSCoding methods
    func encode(with aCoder: NSCoder) {
        aCoder.encode(beats, forKey: SongTrackPropertyKey.trackBeatsKey)
        aCoder.encode(tempos, forKey: SongTrackPropertyKey.trackTemposKey)
        aCoder.encode(velocity, forKey: SongTrackPropertyKey.trackNoteVelocityKey)
        aCoder.encode(duration, forKey: SongTrackPropertyKey.trackNoteDurationKey)
        aCoder.encode(pan, forKey: SongTrackPropertyKey.trackPanKey)
        aCoder.encode(volume, forKey: SongTrackPropertyKey.trackVolumeKey)
        aCoder.encode(measures, forKey: SongTrackPropertyKey.trackMeasuresKey)
        
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        //grab saved data
        var saved_beats = aDecoder.decodeObject(forKey: SongTrackPropertyKey.trackBeatsKey) as! [Double]!
        var saved_tempos = aDecoder.decodeObject(forKey: SongTrackPropertyKey.trackTemposKey) as! [Double]!
        var saved_velocity = aDecoder.decodeObject(forKey: SongTrackPropertyKey.trackNoteVelocityKey) as! [Int]!
        var saved_duration = aDecoder.decodeObject(forKey: SongTrackPropertyKey.trackNoteDurationKey) as! [Double]!
        var saved_pan = aDecoder.decodeObject(forKey: SongTrackPropertyKey.trackPanKey) as! Double!
        var saved_volume = aDecoder.decodeObject(forKey: SongTrackPropertyKey.trackVolumeKey) as! Double!
        var saved_measures = aDecoder.decodeObject(forKey: SongTrackPropertyKey.trackMeasuresKey) as! Int!

        if(saved_beats == nil){
            saved_beats = [Double]()
        }
        
        
        if(saved_tempos == nil){
            saved_tempos = [Double]()
        }
        
        
        if(saved_velocity == nil){
            saved_velocity = [Int]()
        }
        
        if(saved_duration == nil){
            saved_duration = [Double]()
        }
        
        if(saved_pan == nil){
            saved_pan = Double(0.0)
        }
        
        if(saved_volume == nil){
            saved_volume = Double(0.0)
        }
        
        if(saved_measures == nil){
            saved_measures = Int(1)
        }
        
        
        self.init(beats: saved_beats!, tempos: saved_tempos!, velocity: saved_velocity!, duration: saved_duration!,
                  pan: saved_pan!, volume: saved_volume!, measures: saved_measures!)
    }
    
    func loadSavedTrack(){
        
        for i in 0 ..< beats.count {
            let beat = beats[i]
            let tempo = tempos[i]
            let note = AKDuration(beats: beat, tempo: tempo)
            track.append(note)
        }
    }
    
    func loadNewTrack(trackManager: TrackManager){
        beats = [Double]()
        tempos = [Double]()
        velocity = [Int]()
        duration = [Double]()
        pan = trackManager.instrument.panner.pan
        volume = trackManager.instrument.volumePercent
        measures = trackManager.loopManager.measures
        
        let velNotes = trackManager.velNotes
        let durNotes = trackManager.durNotes
        var i = 0
        for note in trackManager.trackNotes {
            beats.append(note.beats)
            tempos.append(note.tempo)
            velocity.append(velNotes[i])
            duration.append(durNotes[i])
            i += 1
        }
    }
}

class SongDatabase: NSObject, NSCoding {
    var save = false
    var name: String!
    var global_measures: Int!
    var tempo: Int!
    var time_sig_beats: Int!
    var time_sig_note: Int!
    var tracks: [SongTrack]!
    
    static let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.appendingPathComponent("song_database")
    
    init!(name: String="Song", measures: Int = 4, tempo: Int = 60, time_sig_beats: Int = 4, time_sig_note: Int = 4, tracks: [SongTrack] = [SongTrack]()){
        self.name = name
        self.tracks = tracks
        self.tempo = tempo
        self.global_measures = measures
        self.time_sig_note = time_sig_note
        self.time_sig_beats = time_sig_beats
    }
    
    //MARK: NSCoding methods
    func encode(with aCoder: NSCoder) {
        aCoder.encode(name, forKey: SongPropertyKey.nameKey)
        aCoder.encode(tempo, forKey: SongPropertyKey.tempoKey)
        aCoder.encode(global_measures, forKey: SongPropertyKey.measuresKey)
        aCoder.encode(time_sig_beats, forKey: SongPropertyKey.timeSigBeatsKey)
        aCoder.encode(time_sig_note, forKey: SongPropertyKey.timeSigNoteKey)
        aCoder.encode(tracks, forKey: SongPropertyKey.tracksKey)
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        //grab saved data
        var saved_name = aDecoder.decodeObject(forKey: SongPropertyKey.nameKey) as! String!
        var saved_tempo = aDecoder.decodeObject(forKey: SongPropertyKey.tempoKey) as! Int!
        var saved_measures = aDecoder.decodeObject(forKey: SongPropertyKey.measuresKey) as! Int!
        var saved_time_sig_beats = aDecoder.decodeObject(forKey: SongPropertyKey.timeSigBeatsKey) as! Int!
        var saved_time_sig_note = aDecoder.decodeObject(forKey: SongPropertyKey.timeSigNoteKey) as! Int!
        var saved_tracks = aDecoder.decodeObject(forKey: SongPropertyKey.tracksKey) as! [SongTrack]!
        if(saved_name == nil){
            saved_name = "Song"
        }
        if(saved_measures == nil){
            saved_measures = 4
        }
        if(saved_time_sig_note == nil){
            saved_time_sig_note = 4
        }
        if(saved_time_sig_beats == nil){
            saved_time_sig_beats = 4
        }
        if(saved_tempo == nil){
            saved_tempo = 60
        }
        if(saved_tracks == nil){
            saved_tracks = [SongTrack]()
        }
        
        self.init(name: saved_name!, measures: saved_measures!, tempo: saved_tempo!, time_sig_beats: saved_time_sig_beats!, time_sig_note: saved_time_sig_note!, tracks: saved_tracks!)
    }
    
    
    //MARK: save data
    func saveSong(){
        print("Song database file path: \(SongDatabase.ArchiveURL.path)")
        let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(self, toFile: SongDatabase.ArchiveURL.path)
        if !isSuccessfulSave {
        print("Failed to save song...")
        }
    }
    
    
    
}
