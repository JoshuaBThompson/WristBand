//
//  Instruments.swift
//  MidiDevice_TCL_V0.0.0
//
//  Created by sofiebio on 5/7/16.
//  Copyright © 2016 wristband. All rights reserved.
//

import Foundation
import AudioKit

/****************Global*********************/
let GlobalDefaultMeasures = 4
let GlobalBeatDur = 0.01
enum InstrumentError: Error {
    case InvalidSongLoaded
}

/****************Quantize*******************/
class Quantize {
    var beatScale = 1.0
    var resolution = 1.0
    var triplet_en = false
    var divPerBeat = 1.0 //divisions per beat (beat resolution, ex: 64 divisions would be highest resolution and 1 is lowest)
    let maxDivisions = 64.0
    let minDivisions = 1.0
    var enabled: Bool = false
    
    //MARK: quantize a beat pos
    func quantizedBeat(_ beat: AKDuration)->AKDuration{
        let beats = beat.beats
        let divPos = beats * divPerBeat //position in beat divisions (based on quantized number / resolution set by user in UI: ex: 4 or 32)
        let divPosQuantized = round(divPos) //round to nearest division
        let beatsQuantized = (divPosQuantized / divPerBeat) //get beat position quantized
        
        let posQuantized = AKDuration(beats: beatsQuantized, tempo: beat.tempo)
        return posQuantized
        
    }
    
    //MARK: update the quantization beat divisions
    func update(_ newBeatDivision: Double, triplet_en: Bool = false, beat_scale: Double = 1.0){
        var div = newBeatDivision
        self.triplet_en = triplet_en
        self.resolution = div
        self.beatScale = beat_scale
        if(self.triplet_en){
            div = div * TripletResolution
        }
        //enforce max and min beat resolution
        if(div > maxDivisions){
            div = maxDivisions
        }
        else if(div < minDivisions){
            div = minDivisions
        }
        
        divPerBeat = div
    }
}

/***************Measure Manager*********/
/* Keeps track of current measure, current beat, loop counter, measure progress ...etc
   Call methods in this class to know where to put beats in loop for recording
*/


class LoopManager {
    //MARK: Attributes
    var _current_measure: Int = 0
    var _default_measures: Int = 4
    var _measures: Int = 1
    var _loop: Int = 0
    var _measure_progress: Double = 0.0
    var _beats_elapsed_offset: Double = 0.0
    var _start_offset: Double = 0.0
    var _beats_elapsed: Double = 0.0
    var _beats_elapsed_abs: Double = 0.0
    var _current_note: Int = 0
    var clickTrack: ClickTrack!
    var _recorded: Bool = false
    var loop_notes: Int = 0
    
    //MARK: Computed 
    var recorded: Bool {
        get{
            return _recorded
        }
        set(rec){
            _recorded = rec
        }
    }
    
    var measures: Int {
        get{
            return _measures
        }
        set(meas){
            _measures = meas
        }
    }
    
    var loop: Int {
        get {
            return _loop
        }
        set(lp){
            _loop = lp
        }
    }
    
    var default_measures: Int {
        get {
            return _default_measures
        }
        set (count){
            _default_measures = count
        }
    }
    
    var start_offset: Double {
        get {
            return _start_offset
        }
        set(offset){
            _start_offset = offset
        }
    }
    
    var beats_elapsed_offset: Double {
        get {
            return _beats_elapsed_offset
        }
        set(offset){
            _beats_elapsed_offset = offset
        }
    }
    
    var current_note: Int {
        get {
            return _current_note
        }
        set(note){
            _current_note = note
        }
    }
    
    var notes_per_loop: Int { return clickTrack.timeSignature.beatsPerMeasure * measures }
    
    var sec_per_measure: Double { return clickTrack.secPerMeasure }
    
    var beats_per_measure: Double { return clickTrack.beatLenPerMeasure }
    
    var beats_per_measure_pos: Double { return beats_per_measure - clickTrack.timeSignature.beatScale }
    
    var beats_per_loop: Double { return measures * beats_per_measure }
    
    var beats_per_loop_pos: Double { return (measures * beats_per_measure) - clickTrack.timeSignature.beatScale }
    
    var last_beat_in_loop: Double { return beats_per_loop - clickTrack.timeSignature.beatScale }
    
    var beats_elapsed: Double {
        let total_beats_elapsed = clickTrack.track.currentPosition.beats - start_offset - beats_elapsed_offset
        if(total_beats_elapsed < beats_per_loop){
            _beats_elapsed = total_beats_elapsed
            return _beats_elapsed
        }
        else{
            _beats_elapsed = total_beats_elapsed.truncatingRemainder(dividingBy: beats_per_loop)
            return _beats_elapsed
        }
    }
    
    var beats_elapsed_abs: Double {
        let beat_pos = clickTrack.track.currentPosition.beats
        let offset = start_offset
        
        if(offset > beat_pos){
            _beats_elapsed_abs = 0
            return _beats_elapsed_abs
        }
        else{
            _beats_elapsed_abs = beat_pos - offset
            return _beats_elapsed_abs
        }
    }
    
    var current_measure: Int {
        let abs_beats_elapsed = beats_elapsed_abs
        let first_loop_finished = (abs_beats_elapsed > beats_per_loop)
        if(!recorded && first_loop_finished){
            
            return Int(floor(beats_elapsed / beats_per_measure))
        }
        else if(!recorded) {
            return Int(floor(beats_elapsed / beats_per_measure))
        }
        else{
            return Int(floor(abs_beats_elapsed / (beats_per_measure)))
        }
    }
    
    var measures_elapsed_abs: Int {
        return Int(ceil(beats_elapsed_abs / beats_per_measure))
    }
    
    var measure_progress: Double {
        let measure_time = beats_elapsed.truncatingRemainder(dividingBy: beats_per_measure)
        let measure_progress = measure_time / beats_per_measure
        return measure_progress
    }
    
    //MARK: Init
    
    init(click_track: ClickTrack){
        self.clickTrack = click_track
        default_measures = clickTrack.instrument.default_measures
        measures = default_measures
    }
    
    //MARK: Functions
    func reset(){
        _current_note = 0
        _start_offset = 0
        _loop = 0
        _beats_elapsed_offset = 0
        loop_notes = 0
    }
    
    func resetPlay(){
        _current_note = 0
        _start_offset = 0
        _loop = 0
        _beats_elapsed_offset = 0
        loop_notes = 0
    }
    
}

/************ Instrument Note ******************/
struct InstrumentNote {
    var note: AKDuration!
    var velocity: MIDIVelocity!
    let duration = AKDuration(seconds: GlobalBeatDur)
    
    var beats: Double {
        return note.beats
    }
}


class InstrumentManager {
    //MARK: Attributes
    var enabled: Bool = true
    var playing: Bool = false
    var recording: Bool = false
    var recorded: Bool = false
    var measures: Int = 1
    var track_num: Int!
    var appended = false
    
    //MARK: Audiokit
    var midi: AKMIDI!
    var midi_instrument: MidiInstrument!
    var loop: LoopManager!
    var notes = [InstrumentNote]()
    var clickTrack: ClickTrack!
    var quantizer: Quantize!
    var timeline: LoopTimeline!
    
    //MARK: Computed
    
    var global_offset: Double { return loop.beats_elapsed_offset + loop.start_offset }
    
    var beats_per_loop: Double { return measures * beats_per_measure }
    
    var beats_elapsed: Double { return loop.beats_elapsed }
    
    var beats_elapsed_abs: Double { return loop.beats_elapsed_abs }
    
    var tempo: Double { return clickTrack.tempo.beatsPerMin }
    
    var beats_per_measure: Double { return loop.beats_per_measure }
    
    var global_beats_elapsed: Double { return clickTrack.track.currentPosition.beats }
    
    var track: AKMusicTrack { return clickTrack.track.tracks[track_num] }
    
    var default_measure_count_started: Bool { return clickTrack.instrument.defaultMeasureCountStarted }
    
    var default_measure_count_ended: Bool { return clickTrack.instrument.defaultMeasureCountEnded }
    
    var quantize_enabled: Bool {
        get {
            return quantizer.enabled
        }
        set(en){
            quantizer.enabled = en
        }
    }
    
    //MARK: Init
    init(click_track: ClickTrack, midi_instrument: MidiInstrument){
        quantizer = Quantize()
        clickTrack = click_track
        loop = LoopManager(click_track: clickTrack)
        measures = loop.default_measures
        //timeline bars count from viewcontroller measure views count
        timeline = LoopTimeline(loop_manager: loop, timeline_bars: 4)
        track_num = clickTrack.track.trackCount
        if(clickTrack.track.newTrack() == nil){
            print("failed to load track \(track_num)")
        }
        
        loadMidiInstrument(midi_instrument: midi_instrument)
        
    }
    
    func loadMidiInstrument(midi_instrument: MidiInstrument){
        midi = AKMIDI()
        self.midi_instrument = midi_instrument
        self.midi_instrument.instrument_manager = self
        self.midi_instrument.enableMIDI(midi.client, name: "Midi instrument \(track_num)")
        if(track_num < clickTrack.track.trackCount){
            clickTrack.track.tracks[track_num].setMIDIOutput(midi_instrument.midiIn)
        }
        else{
            print("failed to load midi instrumet - track num out of range")
        }
    }
    
    //MARK: Functions
    
    //MARK: Disable or Enable instrument
    func enable(){
        enabled = true
    }
    
    func disable(){
        enabled = false
    }
    
    //MARK: Add Note
    //Song.instrument.addNote()
    func addNote() {
        if((!recording && !clickTrack.instrument.preRollEnded) || !enabled){
            return
        }
        if(clickTrack.instrument.preRollEnded){
            addPrerollNote()
        }
        else{
            var position = AKDuration(beats: beats_elapsed_abs, tempo: tempo)
            if(recorded){
                position.beats = beats_elapsed
            }
            updateNotesList(position: position)
            if(appended){
                //if user make beat in pre recorded loop right at end of loop (after next set of notes already queued)
                //then append this note to the already queued track
                let offset_beats = global_offset + loop.beats_per_loop
                let note_num = notes.count - 1
                appendNotesFromOffset(start_note_num: note_num, offset: offset_beats)
                
            }
            
        }
    }
    
    func addPrerollNote(){
            //if receive beat between last preroll and first record beat then save it but quantize to first record beat
            if(notes.count > 0){
                return
            }
            let position = AKDuration(beats: 0.05, tempo: tempo) //just quantize to first beats
            updateNotesList(position: position)
            print("addPrerollNote - position \(position.beats)")
    }
    
    func updateNotesList(position: AKDuration){
        notes.append(InstrumentNote(note: position, velocity: 127))
        var sorted_notes = [InstrumentNote]()
        
        sorted_notes = notes.sorted {
            return $0.beats < $1.beats
        }
        notes = sorted_notes
    }
    
    //MARK: Start Recording
    //Song.instrument.record()
    func record(){
        recording = true
    }
    
    //MARK: Stop Recording
    //Song.instrument.stopRecord()
    
    func stopRecord(){
        if(!recording){
            return
        }
        
        recording = false
        
        if(!recorded){
            print("stopRecord!")
            recorded = true
            updateMeasuresFromBeatsElapsesAbs()
            appendNotesToNextLoop()
        }
    }
    
    func setStartRecordOffset(offset: Double){
        loop.start_offset = round(offset)
        
    }
    
    func updateMeasuresFromBeatsElapsesAbs(){
        let elapsed = beats_elapsed_abs
        let new_measure_count = Int(ceil(elapsed / beats_per_measure))
        updateMeasure(count: new_measure_count)
        loop.measures = measures
    }
    
    func updateMeasure(count: Int){
        measures = count
        loop.default_measures = measures
        if(!playing || !recorded){
            loop.measures = measures
        }
    }
    
    func updateLoopAfterQuantize(){
        //If quantize en then find last note played and clear remaining
        if(loop.current_note < notes.count){
            clearNotesFrom(note_num: loop.current_note)
            //Then append remaining quantized notes
            appendNotesFromOffset(start_note_num: loop.current_note, offset: global_offset)
        }
        else if(appended){
            clearRemainingTrack()
            //Then append remaining quantized notes
            appendNotesToNextLoop()
        }
    }
    
    //call when click track starts at 0 beats (this will update instrument measure count appropriately)
    func updateLoopFromClickTrack(){
        if(!recorded){
            return
        }

        let elapsed = global_beats_elapsed - global_offset
        if(elapsed >= loop.beats_per_loop){
            loop.current_note = 0
            loop.beats_elapsed_offset += loop.beats_per_loop
            loop.measures = measures
            
            loop.loop += 1
            appended = false
            
            //check if stop record event
            if(recording && default_measure_count_ended){
                stopRecordAfterDefaultMeasureEnded()
            }
        }
    }
    
    func stopRecordAfterDefaultMeasureEnded(){
        clickTrack.instrument.resetDefaultMeasureCounter()
        clickTrack.song.stopRecordFromSong()
    }
    
    func updateNotesFromClickTrack(){
        if(!recorded && !default_measure_count_started){
            return
        }
        
        appended = true
        loop.loop_notes += clickTrack.timeSignature.beatsPerMeasure
        if(loop.loop_notes >= loop.notes_per_loop){
            loop.loop_notes = 0
            appendNotesToNextLoop()
        }
    }
    
    func startLoopFromDefaultMeasures(){
        if(!recorded){
            recorded = true
            measures = loop.default_measures
            loop.measures = measures
        }
    }
    
    func appendNotesToNextLoop(){
        let offset_beats = global_offset + loop.beats_per_loop
        appendNotesFromOffset(offset: offset_beats)
    }
    
    func appendNotesFromOffset(start_note_num: Int=0, offset: Double){
        var i = 0
        for note in notes {
            if(i >= start_note_num){
                var new_note = AKDuration(beats: offset + note.beats, tempo: tempo)
                if(quantize_enabled){
                    new_note = quantizer.quantizedBeat(new_note)
                }
                
                if(note.beats <= beats_per_loop){
                    if(quantize_enabled){
                        print("applying quantized note \(new_note.beats)")
                    }
                    insertNote(note: InstrumentNote(note: new_note, velocity: note.velocity))
                }
            }
            i += 1
        }
    }
    
    func insertNote(note: InstrumentNote){
        track.add(noteNumber: midi_instrument.midi_note, velocity: note.velocity, position: note.note, duration: note.duration)
    }
    
    //MARK: Stop Playing
    //Song.instrument.stop()
    
    func stop(){
        playing = false
    }
    
    //MARK: Start Play
    //Song.instrument.play()
    
    func play(){
        appended = false
        resetPlay()
        playing = true
        appendNotesFromOffset(offset: 0)
    }
    
    func resetPlay(){
        midi_instrument.reset()
        loop.resetPlay()
        loop.measures = measures
        clearTrack()
    }
    
    
    //MARK: Clear track beats
    func clearTrack(){
        if(track.length != 0){
            let len = track.length
            //erase only extra beats that are not part of original record
            let start = AKDuration(beats: 0, tempo: tempo)
            let end = AKDuration(beats: len+1, tempo: tempo)
            track.clearRange(start: start, duration: end)
            
        }
    }
    
    func clearNotesFrom(note_num: Int){
        if(note_num >= notes.count){
            return
        }
        
        let offset = global_offset + notes[note_num].beats
        let len = track.length
        let start = AKDuration(beats: offset, tempo: tempo)
        let end = AKDuration(beats: len + 1, tempo: tempo)
        print("clear: from \(start.beats) to \(end.beats)")
        track.clearRange(start: start, duration: end)
    }
    
    func clearRemainingTrack(){
        let len = track.length
        let start = AKDuration(beats: 0, tempo: tempo)
        let end = AKDuration(beats: len + 1, tempo: tempo)
        print("clear: from \(start.beats) to \(end.beats)")
        track.clearRange(start: start, duration: end)
    }
    
    func clear(){
        appended = false
        recorded = false
        loop.reset()
        notes.removeAll()
        clearTrack()
        midi_instrument.reset()
    }
    
}

/****************Midi Instrument **********/

class MidiInstrument: AKMIDIInstrument {
    //MARK: Attributes
    var sound_map: SoundMapInfo!
    var midi_note: MIDINoteNumber = 60
    var sampler = AKSampler()
    var instrument_manager: InstrumentManager!
    var volume: Double = 1.0
    var muted: Bool = false
    var max_scaled_vol = 1.0
    var min_scaled_vol = 0.6
    var min_zero_vol = 0.03
    var max_vol = 1.0
    var min_vol = 0.0
    
    //MARK: Computed
    var panner: AKSampler {
        return sampler
    }
    
    var volume_scaled: Double {
        //convert 0 - 100% to 70 - 100% volume
        if(volume <= min_zero_vol){
            return 0.0
        }
        else{
            return volume * (max_scaled_vol - min_scaled_vol)/(max_vol - min_vol) + min_scaled_vol
        }
    }
    
    //MARK: Init
    override init(){
        super.init()
        panner.pan = 0
        reset()
    }
    
    //MARK: Functions
    func reset(){
        volume = 1.0
        muted = false
    }
    
    func rawPlay(_ noteNumber: MIDINoteNumber, velocity: MIDIVelocity){
        if(!muted){
            sampler.volume = volume_scaled
            sampler.play()
        }
        
    }
    /// Start playback of a particular voice with MIDI style note and velocity
    ///
    /// - parameter voice: Voice to start
    /// - parameter note: MIDI Note Number
    /// - parameter velocity: MIDI Velocity (0-127)
    ///
    override func play(noteNumber: MIDINoteNumber, velocity: MIDIVelocity) {
        update()
        if(!muted){
            sampler.volume = volume_scaled
            sampler.play()
        }
    }
    
    func update(){
        //update note counter
        instrument_manager?.loop.current_note += 1
    }
    
}


/****************ClickTrack Instrument
 Desc: This instrument is used by click track
 *****************/

class ClickTrackInstrument: MidiInstrument{
    /// Create the synth ClickTrack instrument
    ///
    /// - parameter voiceCount: Number of voices (usually two is plenty for drums)
    ///
    var loop_count = 0
    var beat = 0
    var pos: Double = 0
    var preRoll = false
    var preRollEnded = false
    var clickTrack: ClickTrack!
    var preRollSampler = AKSampler()
    var mixer: AKMixer!
    var track: AKSequencer!
    var totalBeats: Double = 0
    var defaultMeasureCountEnded = false
    var defaultMeasureCountStarted = false
    var defaultMeasureCounter = 0
    var _default_measures = GlobalDefaultMeasures
    var newRecordEnabled = false
    var highSampler = AKSampler()
    var highPrerollSampler = AKSampler()
    
    var timeSignature: TimeSignature {
        return clickTrack.timeSignature
    }
    
    var beats_per_measure: Int {
        return timeSignature.beatsPerMeasure
    }
    
    var beat_len_per_measure: Double {
        return timeSignature.beatLenPerMeasure
    }
    
    var default_measures: Int {
        get {
            return _default_measures
        }
        set(count){
            _default_measures = count
        }
    }
    
    var instrument_default_measures: Int {
        return clickTrack.song.instrument.loop.default_measures
    }
    
    
    init(clickTrackRef: ClickTrack!) {
        super.init()
        clickTrack = clickTrackRef
        midi_note = 60
        muted = true
        loadSamplers()
        self.avAudioNode = mixer.avAudioNode //sampler.avAudioNode
        
    }
    
    func loadSamplers(){
        do {
            try preRollSampler.loadWav("Sounds_clicks/AlertClick-1-low")
        
            try highPrerollSampler.loadWav("Sounds_clicks/AlertClick-1-hi")
            try highSampler.loadWav("Sounds_clicks/MainClick-1-hi")
            try sampler.loadWav("Sounds_clicks/MainClick-1-low")
            
        } catch {
            print("failed to load sampler files")
        }
        
        
        mixer = AKMixer()
        mixer.connect(preRollSampler)
        mixer.connect(sampler)
        mixer.connect(highSampler)
            
    }
    
    
    override func reset(){
        beat = 0
        preRollEnded = false
        preRoll = false
        loop_count = 0
        totalBeats = 0
        newRecordEnabled = false
        self.resetDefaultMeasureCounter()
        pos = 0
    }
    
    //this tells click track to start pre roll sound and then tell instruments to start recording on last beat
    func set_record(){
        preRoll = true
    }
    
    func resetDefaultMeasureCounter(){
        defaultMeasureCountEnded = false
        defaultMeasureCountStarted = false
        defaultMeasureCounter  = 0
    }
    
    func startDefaultMeasureCounter(){
        resetDefaultMeasureCounter()
        if(!newRecordEnabled){
            defaultMeasureCountStarted = false
        }
        else{
            defaultMeasureCountStarted = true
        }
    }
    
    func updateDefaultMeasureCounter(){
        if(!newRecordEnabled){
            defaultMeasureCountEnded = false
            defaultMeasureCounter = 0
            return
            
        }
        
        defaultMeasureCounter += 1
        if(defaultMeasureCounter >= instrument_default_measures){
            defaultMeasureCountEnded = true
            defaultMeasureCountStarted = false
        }
    }
    
    func updateBeatAndPos(){
        beat+=1
        pos += (1 * timeSignature.beatScale) //ex: if 1/8 time sig then scale = 1/2 so that 1/2 * quarter note = eigth note (1/8)
    }
    
    /// Start playback of a particular voice with MIDI style note and velocity
    ///
    /// - parameter voice: Voice to start
    /// - parameter note: MIDI Note Number
    /// - parameter velocity: MIDI Velocity (0-127)
    ///
    override func play(noteNumber: MIDINoteNumber, velocity: MIDIVelocity) {
        
        if(beat == 0){
            updateInstrumentLoops()
            
            if(defaultMeasureCountStarted){
                updateDefaultMeasureCounter()
            }
            
            loop_count += 1
        }
        
        updateBeatAndPos()
        
        if(pos.truncatingRemainder(dividingBy: Double(beats_per_measure)) == 0){
        }
        
        let volume = Double(velocity) / 127.0
        if(preRoll && beat <= beats_per_measure){
            if(beat == beats_per_measure){
                preRoll = false
                preRollEnded = true
                startDefaultMeasureCounter()
            }
            if(beat == 1){
                //highPrerollSampler.volume = 127
                //highPrerollSampler.play()
                preRollSampler.volume = volume
                preRollSampler.play()
            }
            else{
                preRollSampler.volume = volume
                preRollSampler.play()
            }
        }
        else if(!self.muted){
            if(preRollEnded){
                clickTrack.song.start_record()
                clickTrack.song.instrument.setStartRecordOffset(offset: clickTrack.track.currentPosition.beats)
                preRollEnded = false
            }
            if(beat == 1){
                highSampler.volume = volume
                highSampler.play()
            }
            else{
                sampler.volume = volume
                sampler.play()
            }
        }
        else if(preRollEnded){
            clickTrack.song.start_record()
            clickTrack.song.instrument.setStartRecordOffset(offset: clickTrack.track.currentPosition.beats)
            preRollEnded = false
        }
        
        
        if(beat==beats_per_measure){
            if(defaultMeasureCounter >= instrument_default_measures){
                endInstRecordFromDefaultMeasures()
            }
            clickTrack.appendTrack(offset: loop_count * beats_per_measure)
            updateInstrumentNotes()
            beat=0
        }
    }
    
    func endInstRecordFromDefaultMeasures(){
        clickTrack.song.startPresetWithDefaultMeasureCount()
    }
    
    func updateInstrumentLoops(){
        //update start_offsets and measure count for each instrument
        clickTrack.updateInstrumentLoops()
    }
    
    func updateInstrumentNotes(){
        //append new notes to instrument tracks
        clickTrack.updateInstrumentNotes()
    }
}


//Time Signature
struct TimeSignature {
    var maxBaseBeatUnit = 16
    var maxBeatsPerMeasure = 32
    var baseBeatUnit = 4 //quater note is base beat unit
    var beatsPerMeasure = 4//4 //upper - ex: 4 quarter notes in a measure for a (4/4th)
    var beatUnit = 4 //lower - ex: quarter note (4/4th)
    
    var beatScale: Double {
        //ex: for 8/8th time sig 1/8 note = (1/2) * quarter note = 4/8 * quarter note = baseBeatUnit/beatUnit * quarter note
        return Double(baseBeatUnit) / Double(beatUnit)
    }
    
    var beatLenPerMeasure: Double {
        return Double(beatsPerMeasure) * beatScale
        //return Double(beatUnit) * beatScale
    }
    
    func getBeatUnit(beat_unit: Int)->Int{
        if(maxBaseBeatUnit < beat_unit){
            return maxBaseBeatUnit
        }
        else{
            return beat_unit
        }
    }
    
    func getBeatsPerMeasure(bpm: Int)->Int{
        if(maxBeatsPerMeasure < bpm){
            return maxBeatsPerMeasure
        }
        else{
            return bpm
        }
    }
    
}


//Tempo
class Tempo {
    let maxBeatsPerMin = 200.0
    let minBeatsPerMin = 1.0
    var beatsPerMin = Double(120.0) //default
    let secPerMin = Double(60.0)
    var beatsPerSec: Double { return beatsPerMin / secPerMin }
    
    func set_tempo(bpm: Double){
        if(bpm > self.maxBeatsPerMin){
            self.beatsPerMin = self.maxBeatsPerMin
        }
        else if(bpm < self.minBeatsPerMin){
            self.beatsPerMin = self.minBeatsPerMin
        }
        else {
            self.beatsPerMin = bpm
        }
    }
    
}



//ClickTrack
class ClickTrack: AKNode{
    //MARK: Attributes
    var midi: AKMIDI!
    var track: AKSequencer!
    var instrument: ClickTrackInstrument!
    var tempo: Tempo!
    var timeSignature: TimeSignature!
    var _enabled = false
    var recording = false
    var song: Song!
    
    //MARK: Computed
    var beatsPerMeasure: Int { return timeSignature.beatsPerMeasure }
    var beatLenPerMeasure: Double {return timeSignature.beatLenPerMeasure }
    var secPerMeasure: Double {return timeSignature.beatScale * Double(timeSignature.beatsPerMeasure) / tempo.beatsPerSec }
    var secPerClick: Double { return secPerMeasure / Double(timeSignature.beatsPerMeasure) }
    var clickPerSec: Double { return 1/secPerClick }
    var beep: AKOperation!
    var trig: AKOperation!
    var beeps: AKOperation!
    var _running = false
    var running: Bool { return _running}
    var enabled: Bool { return _enabled }
    var muted: Bool { return instrument.muted}
    
    
    //MARK: Init
    init(songRef: Song, clickTempo: Tempo, clickTimeSignature: TimeSignature){
        super.init()
        song = songRef
        midi = AKMIDI()
        track = AKSequencer()
        instrument = ClickTrackInstrument(clickTrackRef: self)
        tempo = clickTempo
        timeSignature = clickTimeSignature
        initInstrumentTrack()
        self.avAudioNode = instrument.avAudioNode
    }
    
    
    //MARK: Functions
    func initInstrumentTrack(){
        instrument.enableMIDI(midi.client, name: "midi click track instrument")
        init_track_notes()
    }
    
    func init_track_notes(){
        if(track.trackCount != 0){
            //this will erase all the other instrument tracks as well so be careful
            track.tracks.removeAll()
        }
        if(track.newTrack() != nil){
            track.tracks[0].setMIDIOutput(instrument.midiIn)
            track.setTempo(tempo.beatsPerMin)
            instrument.track = track
            resetTrack()
        }
    }
    
    func reset(clearAll: Bool = false){
        if((track) != nil){
            instrument.reset()
            resetTrack(clearAll: clearAll)
        }
    }
    
    func resetTrack(clearAll: Bool = false){
        track.stop()
        track.disableLooping()
        if(track.tracks[0].length != 0 && !clearAll){
            let start = AKDuration(beats: beatLenPerMeasure, tempo: tempo.beatsPerMin)
            clearTrack(start: start)
            track.setLength(AKDuration(beats: 1000))
        }
        else{
            let start = AKDuration(beats: 0, tempo: tempo.beatsPerMin)
            clearTrack(start: start)
            track.setLength(AKDuration(beats: 1000))
            appendTrack(offset: 0.0)
        }
        
    }
    
    func clearTrack(start: AKDuration){
        let len = track.tracks[0].length
        //erase only extra beats that are not part of original record
        let end = AKDuration(beats: len+1, tempo: tempo.beatsPerMin)
        track.tracks[0].clearRange(start: start, duration: end)
        track.setLength(AKDuration(beats: 1000))
    }
    
    func appendTrack(offset: Double){
        let timeSigBeats = timeSignature.beatsPerMeasure
        let timeSigScale = timeSignature.beatScale //ex: if 1/8 notes then scale = 1/2 since 1/2 * quarter note = eigth note
        
        for i in 0 ..< timeSigBeats {
            if(i < timeSigBeats){
                let beat_pos = AKDuration(beats: Double(i * timeSigScale) + offset)
                var velocity = 127
                if(i == 0){
                    velocity = 127 //first beat in measure is loudest
                }
                track.tracks[0].add(noteNumber: 60, velocity: MIDIVelocity(velocity), position: beat_pos, duration: AKDuration(seconds: GlobalBeatDur))
            }
        }
    }
    
    func update(){
        track.setTempo(tempo.beatsPerMin)
    }
    
    func updateInstrumentLoops(){
        self.song.updateLoopFromClickTrack()
    }
    
    func updateInstrumentNotes(){
        self.song.updateNotesFromClickTrack()
    }
    
    func mute(){
        instrument.muted = true
    }
    
    func unmute(){
        instrument.muted = false
    }
    
    
    //MARK: Enable / Disable used by start() to determine if it should play the track or not
    func enable(){
        _enabled = true
    }
    
    func disable(){
        _enabled = false
    }
    
    
    //MARK: overriden functions
    /// Tells whether the node is processing (ie. started, playing, or active)
    var isStarted: Bool {
        return running
    }
    
    
    /// Function to start, play, or activate the node, all do the same thing
    func start_preroll(){
        instrument.set_record()
        enable()
        start()
    }
    
    func start() {
        if(_enabled){
            if(!running){
                track.enableLooping()
                track.play()
                _running = true
            }
            
        }
        else{
            stop()
        }
    }
    
    /// Function to stop or bypass the node, both are equivalent
    func stop() {
        track.stop()
        track.disableLooping()
        track.rewind()
        instrument.reset()
        _running = false
    }
    
}


/****************Timeline*****************/
class LoopTimeline {
    //MARK: Attributes
    var loop: LoopManager!
    var bar_count: Int = 0
    var measure_count: Int = 0
    var bar_num = 0
    var prev_bar_num = 0
    var count = 0
    var bars_progress = [Double]()
    var ready_to_clear = false
    
    //MARK: Computed variables
    var current_progress: Double {
        return bars_progress[bar_num]
    }
    
    var bars_remaining: Int {
        
        return self.loop.measures - self.loop.current_measure
    }
    
    var last_bar_num: Int {
        return (self.loop.measures - 1) % bar_count
    }
    
    //MARK: Init
    init(loop_manager: LoopManager, timeline_bars: Int){
        self.bar_count = timeline_bars
        self.loop = loop_manager
        
        
        //init bars with 0 % progress
        for _ in 0 ..< self.bar_count {
            self.bars_progress.append(0.0)
        }
    }
    
    //MARK: Functions
    func update(){
        let current_track_measure = self.loop.current_measure
        let current_measure_progress = self.loop.measure_progress
        self.measure_count = current_track_measure
        self.bar_num = self.getBarNumFromMeasure(measure_num: current_track_measure)
        bars_progress[bar_num] = current_measure_progress
        if(bar_num == 0 && prev_bar_num != 0){
            ready_to_clear = true
        }
        else{
            ready_to_clear = false
        }
    }
    
    func getBarNumFromMeasure(measure_num: Int)->Int{
        let next_bar_num = measure_num % bar_count //ex: 3 % 4 = 3 and 4 % 4 = 0
        if(next_bar_num != bar_num){
            prev_bar_num = bar_num
        }
        return next_bar_num
    }
}

