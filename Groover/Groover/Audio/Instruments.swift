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
    
    //MARK: quantize to next beat pos
    func quantizeToNextBeat(_ beat: AKDuration)->AKDuration{
        let beats = beat.beats
        let tempDivPerBeat = 1.0
        let divPos = beats * tempDivPerBeat //position in beat divisions (based on quantized number / resolution set by user in UI: ex: 4 or 32)
        let divPosQuantized = ceil(divPos) //round to next beat
        let beatsQuantized = divPosQuantized / divPerBeat //get beat position quantized
        
        let posQuantized = AKDuration(beats: beatsQuantized, tempo: beat.tempo)
        return posQuantized
    }
    
    //MARK: quantize a beat pos
    func quantizedBeat(_ beat: AKDuration)->AKDuration{
        let beats = beat.beats * beatScale
        let divPos = beats * divPerBeat //position in beat divisions (based on quantized number / resolution set by user in UI: ex: 4 or 32)
        let divPosQuantized = round(divPos) //round to nearest division
        let beatsQuantized = (divPosQuantized / divPerBeat) / beatScale//get beat position quantized
        
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
        _default_measures = clickTrack.instrument.defaultMeasures
        return _default_measures
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
            if(_current_note >= notes_per_loop){
                _current_note = 0
            }
        }
    }
    
    var notes_per_loop: Int { return clickTrack.timeSignature.beatsPerMeasure * measures }
    
    var sec_per_measure: Double { return clickTrack.secPerMeasure }
    
    var beats_per_measure: Double { return clickTrack.beatLenPerMeasure }
    
    var beats_per_measure_pos: Double { return beats_per_measure - clickTrack.timeSignature.beatScale }
    
    var beats_per_loop: Double { return measures * beats_per_measure }
    
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
        measures = default_measures
    }
    
    //MARK: Functions
    func reset(){
        _current_note = 0
        _measures = default_measures
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
    let duration = AKDuration(seconds: 0.1)
    
    var beats: Double {
        return note.beats
    }
}


class InstrumentManager {
    //MARK: Attributes
    var playing: Bool = false
    var recording: Bool = false
    var recorded: Bool = false
    var measures: Int = 1
    var volume: Int = 127
    var track_num: Int!
    
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
        midi = AKMIDI()
        clickTrack = click_track
        loop = LoopManager(click_track: clickTrack)
        measures = loop.default_measures
        //timeline bars count from viewcontroller measure views count
        timeline = LoopTimeline(loop_manager: loop, timeline_bars: 4)
        track_num = clickTrack.track.trackCount
        self.midi_instrument = midi_instrument
        self.midi_instrument.instrument_manager = self
        self.midi_instrument.enableMIDI(midi.client, name: "Midi instrument \(track_num)")
        if(clickTrack.track.newTrack() != nil){
            clickTrack.track.tracks[track_num].setMIDIOutput(midi_instrument.midiIn)
        }
    }
    
    //MARK: Functions
    //MARK: Add Note
    //Song.instrument.addNote()
    func addNote() {
        if(!recording){
            return
        }
        
        var position = AKDuration(beats: beats_elapsed_abs, tempo: tempo)
        if(recorded){
            position.beats = beats_elapsed
        }
        updateNotesList(position: position)
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
        measures = new_measure_count
        loop.measures = measures
    }
    
    func updateLoopAfterQuantize(){
        //If quantize en then find last note played and clear remaining
        if((loop.current_note < notes.count) && quantize_enabled){
            clearNotesFrom(note_num: loop.current_note)
            //Then append remaining quantized notes
            appendNotesFromOffset(start_note_num: loop.current_note, offset: global_offset)
        }
    }
    
    //call when click track starts at 0 beats (this will update instrument measure count appropriately)
    func updateLoopFromClickTrack(){
        if(!recorded){
            return
        }
        let elapsed = global_beats_elapsed - global_offset
        if(elapsed > loop.beats_per_loop){
            loop.beats_elapsed_offset += loop.beats_per_loop
            loop.measures = measures
            loop.loop += 1
        }
    }
    
    func updateNotesFromClickTrack(){
        if(!recorded){
            return
        }
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
            appendNotesToNextLoop()
        }
    }
    
    func appendNotesToNextLoop(){
        let offset_beats = global_offset + loop.beats_per_loop
        print("appendNotesToNextLoop \(offset_beats)")
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
        stopRecord()
        clearTrack()
    }
    
    //MARK: Start Play
    //Song.instrument.play()
    
    func play(){
        resetPlay()
        playing = true
        appendNotesFromOffset(offset: 0)
    }
    
    func resetPlay(){
        midi_instrument.reset()
        loop.resetPlay()
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
        track.clearRange(start: start, duration: end)
    }
    
    func clear(){
        recorded = false
        measures = loop.default_measures
        loop.reset()
        notes.removeAll()
        clearTrack()
        midi_instrument.reset()
    }
    
}

/****************Midi Instrument **********/

class MidiInstrument: AKMIDIInstrument {
    //MARK: Attributes
    var midi_note: MIDINoteNumber = 60
    var panner: AKPanner!
    var sampler = AKSampler()
    var instrument_manager: InstrumentManager!
    var volume: Double = 1.0
    var muted: Bool = false
    
    //MARK: Init
    override init(){
        super.init()
        panner = AKPanner(sampler, pan: 0)
        reset()
    }
    
    //MARK: Functions
    func reset(){
        volume = 1.0
        muted = false
    }
    
    func rawPlay(_ noteNumber: MIDINoteNumber, velocity: MIDIVelocity){
        if(!muted){
            sampler.volume = volume
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
            sampler.volume = volume
            sampler.play()
        }
    }
    
    func update(){
        //update note counter
        instrument_manager?.loop.current_note += 1
    }
    
}

/****************Base class of synth instruments
 ****************/

class SynthInstrument: AKMIDIInstrument{
    var note: Int = 60
    var muted = false
    var volumePercent: Double = 100.0
    var instrumentName = "Synth Instrument"
    var sampler = AKSampler()
    var preset = 0
    var reset_en = false
    var instTrack: InstrumentTrack!
    var panner: AKPanner!
    
    //looping
    //var ignore = false  // use to ignore specific beat
    var real_pos: Double = 0
    var note_num: Int = 0
    var loop_count: Int = 0
    var _total_dur: Double = 0
    var _maxNoteCount: Int = 0
    var quantizeHandled = true
    var prevBeat: AKDuration!
    var currentBeat: AKDuration!
    var loop_finished = false
    var nextMeasureCount = 0
    var measureUpdateEvent = false
    var recordUpdateEvent = false
    var eventNoteNum = MIDINoteNumber(2)
    var nextStartOffset: Double = 0
    var prevStart = 0.0
    var next_start_pos = 0.0
    var _start_offset = 0.0
    
    
    var quantizeEnabled: Bool {
        return instTrack.trackManager.quantizeEnable
    }
    
    var total_dur: Double {
        _total_dur = Double(instTrack.loopLength)
        return _total_dur
    }
    
    var start_offset: Double {
        return instTrack.trackManager.loopManager.start_offset
    }
    
    var maxNoteCount: Int {
        if(instTrack.trackManager.recordSet){
            return _maxNoteCount
        }
        _maxNoteCount = instTrack.maxNoteCount
        return _maxNoteCount
        
    }
    
    var maxNoteNum: Int {
        if(maxNoteCount >= 1){
            return maxNoteCount-1
        }
        else{
            return 0
        }
    }
    
    var maxBeatPos: Double {
        if(maxNoteCount >= 1){
            return instTrack.trackManager.trackNotes[maxNoteCount-1].beats
        }
        else{
            return 0
        }
    }
    
    var beatPos: Double {
        return instTrack.trackManager.trackNotes[note_num].beats
    }
    var loopStartPos: Double {
        return instTrack.trackManager.getStartOfCurrentLoop()
    }
    
    var realPos: Double {
        
        return loopStartPos + beatPos
    }
    
    var realMaxPos: Double {
        return loopStartPos + maxBeatPos
    }
    
    var beatTempo: Double {
        return instTrack.trackManager.trackNotes[note_num].tempo
    }
    
    var globalTempo: Double {
        return instTrack.trackManager.clickTrack.tempo.beatsPerMin
    }
    
    
    var volumeScale: Double {
        return volumePercent/100.0
    }
    /// Create the synth snare instrument
    ///
    /// - parameter voiceCount: Number of voices (usually two is plenty for drums)
    ///
    override init(){
        super.init()
        panner = AKPanner(sampler, pan: 0)
        reset()
    }
    
    func reset(){
        note_num = 0
        real_pos = 0
        loop_count = 0
        _maxNoteCount = 0
        _total_dur = 0
        quantizeHandled = true
        prevBeat = nil
        currentBeat = nil
        loop_finished = false
        next_start_pos = 0
    }
    
    func updateMaxNoteCount(){
        _maxNoteCount = instTrack.maxNoteCount
    }
    
    func updateNextStartPos(){
        
        next_start_pos += total_dur
        print("update next_start_pos to \(next_start_pos)")
    }
    
    func updateNoteNumAndOffset(){
        loop_finished = false
        prevBeat = AKDuration(beats: realPos, tempo: globalTempo)
        if(quantizeHandled && quantizeEnabled){
            prevBeat = instTrack.trackManager.quantizer.quantizedBeat(prevBeat)
        }
        if(note_num == 0){
            print("note_num == 0")
            updateNextStartPos()
        }
        note_num += 1
        
        if(note_num >= maxNoteCount){
            note_num = 0
            loop_count += 1
        }
        
        currentBeat = AKDuration(beats: realPos, tempo: globalTempo)
    }
    
    func handleQuantize(){
        if(quantizeEnabled && note_num != maxNoteNum && !quantizeHandled){
            print("handle enables quantize beat at \(note_num)")
            let nextQuantizedBeatInRange = isNextQuantizedInRange()
                if(nextQuantizedBeatInRange){
                    clearRemainingBeatsInCurrentLoop()
                    appendRemainingQuantizedBeatsInCurrentLoop()
                    quantizeHandled = true
                }
            
        }
        else if(!quantizeEnabled && note_num != maxNoteNum && !quantizeHandled){
            print("handle disable quantize beat at \(note_num)")
            let nextUnquantizedBeatInRange = isNextUnquantizedInRange()
            if(nextUnquantizedBeatInRange){
                clearRemainingBeatsInCurrentLoop()
                appendRemainingBeatsInCurrentLoop()
                quantizeHandled = true
            }
            
        }
    }
    
    
    func clearRemainingBeatsInCurrentLoop(){
        let currentBeat = AKDuration(beats: realPos, tempo: globalTempo)
        let len = instTrack.trackManager.trackLength
        let currentMaxBeat = AKDuration(beats: len, tempo: globalTempo)//AKDuration(beats: realMaxPos, tempo: tempo)
        instTrack.trackManager.clearTrackRange(start: currentBeat, end: currentMaxBeat)
    }
    
    func appendRemainingQuantizedBeatsInCurrentLoop(){
        instTrack.trackManager.appendTrackFromNoteNum(offset: loopStartPos, noteNum: note_num)
    }
    
    func appendRemainingBeatsInCurrentLoop(){
        instTrack.trackManager.appendTrackFromNoteNum(offset: loopStartPos, noteNum: note_num)
    }
    
    func isNextQuantizedInRange()->Bool{
        
        let nextQuantizedBeat = instTrack.trackManager.quantizer.quantizedBeat(currentBeat)
        return (nextQuantizedBeat.beats > prevBeat.beats)
        
    }
    
    func isNextUnquantizedInRange()->Bool{
        
        return (prevBeat.beats < currentBeat.beats)
        
    }
    
    func addNote(){
        if(instTrack.trackManager.trackNotes.count==0 || instTrack.trackManager.firstInstance){
            return
        }
 
        
        updateNoteNumAndOffset() //get the current note number in the loop and the total duration offset
        print("track \(instTrack.trackManager.trackNum) playing note \(note_num) at realBeatPos \(realPos)")
        if(loop_count >= 1){
            appendTrack()
        }
        else{
            handleQuantize()
        }
        
    }
    
    func appendTrack(){
        let current_beat = instTrack.clickTrack.track.currentPosition.beats
        let start_pos = instTrack.trackManager.getRealPosFromNextRelativePos(pos: 0)
        print("current beat \(current_beat)")
        print("start_pos \(start_pos)")
        print("next_start_pos \(next_start_pos)")
        print("offset \(start_offset)")
        print("prevStart \(prevStart)")
        print("prevStartDiff \(start_pos - prevStart)")
        prevStart = start_pos
        updateMaxNoteCount()
        instTrack.trackManager.appendTrack(offset: self.next_start_pos + self.start_offset)
        loop_count = 0
        loop_finished = true
    }
    
    func rawPlay(_ noteNumber: MIDINoteNumber, velocity: MIDIVelocity){
        if(!muted){
            let volume = volumeScale * Double(velocity)/127.0
            sampler.volume = volume
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
        print("Midi Note \(noteNumber)")
        if(noteNumber.hashValue == eventNoteNum.hashValue){
            let b = instTrack.trackManager.clickTrack.track.currentPosition.beats
            print("event! \(b)")
            instTrack.trackManager.applyUpdateMeasureCount(count: nextMeasureCount)
            return
        }
        else if(noteNumber.hashValue == eventNoteNum.hashValue + 1){
            recordUpdateEvent = false
            instTrack.trackManager.resetTrack(clearAll: true)
            print("new track at next_start_pos \(next_start_pos)")
            instTrack.trackManager.appendTrack(offset: self.next_start_pos + self.start_offset)
        }
        /*
        else if(ignore){
            ignore = false  //ignore specific beat and then reset ignore
            addNote()
        }
        */
        else if(!muted){
            let volume = volumeScale * Double(velocity)/127.0
            sampler.volume = volume
            sampler.play()
            addNote()
        }
        
    }
    
    /// Stop playback of a particular voice
    ///
    /// - parameter voice: Voice to stop
    /// - parameter note: MIDI Note Number
    ///
    override func stop(noteNumber: MIDINoteNumber) {
        //do something
    }
    
    //update volume scale: ex real volume = velocity * scale
    func updateVolume(_ percent: Double){
        volumePercent = percent
    }
    
    func updatePan(_ pan: Double){
        //-1 is completely left pan, 0 is center and 1 is compeletely right pan
        
        //pan range limits
        var newPan = pan
        if(newPan > 1.0){newPan = 1.0}
        else if(newPan < -1.0){newPan = -1.0}
        
        panner.pan = newPan
    }
    
    //mute
    func mute(){
        muted = true
    }
    
    func unmute(){
        muted = false
    }
}

/****************ClickTrack Instrument
 Desc: This instrument is used by click track
 *****************/

class ClickTrackInstrument: SynthInstrument{
    /// Create the synth ClickTrack instrument
    ///
    /// - parameter voiceCount: Number of voices (usually two is plenty for drums)
    ///
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
    var defaultMeasures = GlobalDefaultMeasures
    var newRecordEnabled = false
    var highSampler = AKSampler()
    var highPrerollSampler = AKSampler()
    
    var timeSignature: TimeSignature {
        return clickTrack.timeSignature
    }
    
    var beatsPerMeasure: Int {
        return timeSignature.beatsPerMeasure
    }
    
    var beatLenPerMeasure: Double {
        return timeSignature.beatLenPerMeasure
    }
    
    
    init(clickTrackRef: ClickTrack!) {
        super.init()
        clickTrack = clickTrackRef
        note = 60
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
        
        if(defaultMeasureCounter >= defaultMeasures){
            defaultMeasureCountEnded = true
            defaultMeasureCountStarted = false
        }
        else{
            defaultMeasureCounter += 1
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
        
        if(pos.truncatingRemainder(dividingBy: Double(beatLenPerMeasure)) == 0){
        }
        
        let volume = Double(velocity) / 127.0
        if(preRoll && beat <= beatsPerMeasure){
            if(beat == beatsPerMeasure){
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
                highSampler.volume = 127
                highSampler.play()
            }
            else{
                sampler.volume = 127
                sampler.play()
            }
        }
        else if(preRollEnded){
            clickTrack.song.start_record()
            clickTrack.song.instrument.setStartRecordOffset(offset: clickTrack.track.currentPosition.beats)
            preRollEnded = false
        }
        
        
        if(defaultMeasureCountEnded){
            clickTrack.song.startPresetWithDefaultMeasureCount()
            defaultMeasureCountEnded = false
        }
        
        if(beat==beatsPerMeasure){
            clickTrack.appendTrack(offset: loop_count * beatLenPerMeasure)
            updateInstrumentNotes()
            beat=0
        }
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
    var beatsPerMin = Double(60.0) //60.0
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
                var velocity = 110
                if(i == 0){
                    velocity = 127 //first beat in measure is loudest
                }
                track.tracks[0].add(noteNumber: 60, velocity: MIDIVelocity(velocity), position: beat_pos, duration: AKDuration(seconds: 0.1))
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

/* InstrumentTrack
 * Desc:
 *      - Each instrument (like kick preset 1) will have one of these
 *      - Controls the measure count of each track and is responsible for adding notes to track at the right time according to the tempo and time signature
 */

class InstrumentTrack {
    var trackManager: TrackManager!
    var instrument: SynthInstrument!
    var _maxNoteCount: Int = 0
    var clickTrack: ClickTrack!
    var loopLength: Double {
        return trackManager.loopManager.beats_per_loop
    }
    var volume: Double {
        return instrument.volumePercent
    }
    
    var pan: Double {
        return instrument.panner.pan
    }
    
    var maxNoteCount: Int {
        let beatCount = trackManager.trackNotes.count
        
        if(beatCount==0){
            _maxNoteCount = 0
        }
        else if(trackManager.trackNotes[beatCount-1].beats > Double(loopLength)){
            _maxNoteCount =  getMaxNoteNum()
        }
        else{
            _maxNoteCount = beatCount
        }
        
        return _maxNoteCount
    }
    
    init(clickTrack: ClickTrack, presetInst: SynthInstrument){
        self.clickTrack = clickTrack
        instrument = presetInst //custom synth instrument
        instrument.instTrack = self
        trackManager = TrackManager(midiInstrument: instrument, clickTrackRef: clickTrack)
    }
    
    func addNote(_ velocity: Int, duration: Double){
        trackManager.addNote(velocity, duration: duration)
    }
    
    func deselect(){
        trackManager.deselect() //run deselect routines - for ex: checks if should update measure count (if first time track is recorded)
    }
    
    
    //MARK: update volume of instrument by changing scale factor 0 - 100%
    func updateVolume(_ percent: Double){
        instrument.updateVolume(percent)
    }
    
    //MARK: update pan (-1 is all left, 0 is center and 1 is all right)
    func updatePan(_ pan: Double){
        instrument.updatePan(pan)
    }
    
    //MARK: update quantized number using resolution of the beat (ex: beat divided into 16 pieces)
    func updateQuantize(_ res: Double, triplet_en: Bool = false){
        //res is the resolution of the beat: ex: 16
        trackManager.quantizer.update(res, triplet_en: triplet_en, beat_scale: clickTrack.timeSignature.beatScale)
    }
    
    func enableQuantize(){
        trackManager.quantizeEnable = true
        trackManager.instrument.quantizeHandled = false
    }
    
    func disableQuantize(){
        trackManager.quantizeEnable = false
        trackManager.instrument.quantizeHandled = false
    }
    
    func record(){
        trackManager.recordSet = true
    }
    
    func getMaxNoteNum()->Int{
        var maxNum = trackManager.trackNotes.count-1
        let maxBeatLength = Double(loopLength)
        for noteNum in 0 ..< trackManager.trackNotes.count{
            if(trackManager.trackNotes[noteNum].beats > maxBeatLength){
                maxNum = noteNum
                return maxNum
            }
        }
        
        return maxNum
    }
    
    func updateMeasureCount(_ count: Int){
        /*
        if(!trackManager.track.isPlaying){
            //clear non original beats from track with prev measure count
            trackManager.resetTrack()
            trackManager.updateMeasureCount(count)
            
        }
         */
        trackManager.updateMeasureCount(count)
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
        prev_bar_num = bar_num
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
        let bar_num = measure_num % bar_count //ex: 3 % 4 = 3 and 4 % 4 = 0
        return bar_num
    }
}

/****************Measure Timeline Manager ***************/

class MeasureTimeline {
    var trackManager: TrackManager!
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
    
    init(track_manager_ref: TrackManager, timeline_bars: Int){
        self.bar_count = timeline_bars
        self.trackManager = track_manager_ref
        
        
        //init bars with 0 % progress
        for _ in 0 ..< self.bar_count {
            self.bars_progress.append(0.0)
        }
    }
    
    //MARK: Update timeline properties based on track state
    func update(){
        let current_track_measure = self.trackManager.loopManager.current_measure
        let current_measure_progress = self.trackManager.loopManager.measure_progress
        prev_bar_num = bar_num
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
        let bar_num = measure_num % bar_count //ex: 3 % 4 = 3 and 4 % 4 = 0
        return bar_num
    }
}

/****************Single instrument track manager ********/
class TrackManager{
    //MARK: Attributes
    var trackNum: Int!
    var track: AKSequencer!
    var quantizeEnable = false
    var quantizer = Quantize()
    var midi: AKMIDI!
    var trackNotes = [AKDuration]()
    var velNotes = [Int]()
    var durNotes = [Double]()
    var noteCount = 0
    var firstInstance = true
    var instrument: SynthInstrument!
    var clickTrack: ClickTrack!
    //var timer: SongTimer!
    var timeline: MeasureTimeline!
    var recordSet = false
    var recorded = false
    var loopManager: LoopManager!
    
    //MARK: Computed
    
    var trackLength: Double {
        return track.tracks[trackNum].length
    }
    
    var isNewRecord: Bool {
        return (((trackNotes.count >= 1) || recordSet) && firstInstance)
    }
    
    //MARK: Initialize
    
    init(midiInstrument: SynthInstrument, clickTrackRef: ClickTrack){
        midi = AKMIDI()
        instrument = midiInstrument
        clickTrack = clickTrackRef
        loopManager = LoopManager(click_track: clickTrack)
        track = clickTrack.track
        instrument.enableMIDI(midi.client, name: "Synth inst preset")
        trackNum = track.trackCount
        if(track.newTrack() != nil){
            track.tracks[trackNum].setMIDIOutput(instrument.midiIn)
        }
        else{
            print("Could not make track \(trackNum)")
        }
        timeline = MeasureTimeline(track_manager_ref: self, timeline_bars: 4)
        
    }
    
    func setStartRecordOffset(offset: Double){
        loopManager.start_offset = round(offset)
        
    }
    
    //MARK: init a track
    func resetTrack(clearAll: Bool = false){
        loopManager.beats_elapsed_offset = 0
        
        if(!clearAll){
            if(track.tracks[trackNum].length != 0){
                let len = track.tracks[trackNum].length
                let start = AKDuration(beats: 0, tempo: clickTrack.tempo.beatsPerMin)
                let end = AKDuration(beats: len+1, tempo: clickTrack.tempo.beatsPerMin)
                clearTrackRange(start: start, end: end)
                appendTrack(offset: 0)
            }
        }
        else{
            if(track.tracks[trackNum].length != 0){
                let len = track.tracks[trackNum].length
                //erase only extra beats that are not part of original record
                let start = AKDuration(beats: 0, tempo: clickTrack.tempo.beatsPerMin)
                let end = AKDuration(beats: len+1, tempo: clickTrack.tempo.beatsPerMin)
                clearTrackRange(start: start, end: end)
            
            }
        }
        
    }
    
    
    func clearTrackRange(start: AKDuration, end: AKDuration){
        track.tracks[trackNum].clearRange(start: start, duration: end)
    }
    
    
    //MARK: Functions
    func addMeasureUpdateEvent(count: Int){
        //get 0 position of next loop
        if(instrument.measureUpdateEvent){
            instrument.nextMeasureCount = count
        }
        else{
            print("addMeasureUpdateEvent")
            let start_pos = getRealPosFromNextRelativePos(pos: Double(0))
            let pos = AKDuration(beats: start_pos, tempo: clickTrack.tempo.beatsPerMin)
            instrument.measureUpdateEvent = true
            instrument.nextStartOffset = start_pos
            instrument.nextMeasureCount = count
            track.tracks[trackNum].add(noteNumber: 2, velocity: 127, position: pos, duration: AKDuration(seconds: 0.0))
        }
        
    }
    
    func addRecordUpdateEvent(){
        if(instrument.recordUpdateEvent){
           return
        }
        print("addRecordUpdateEvent")
        let start_pos = self.instrument.next_start_pos + self.instrument.start_offset
        let pos = AKDuration(beats: start_pos, tempo: clickTrack.tempo.beatsPerMin)
        instrument.recordUpdateEvent = true
        track.tracks[trackNum].add(noteNumber: 3, velocity: 127, position: pos, duration: AKDuration(seconds: 0.0))
        

        
        
    }
    
    func getRealPosFromNextRelativePos(pos: Double)->Double{
        let beats_remaining_till_next_loop  = loopManager.beats_per_loop - loopManager.beats_elapsed
        let start_offset = loopManager.start_offset
        let beats_elapsed_abs = loopManager.beats_elapsed_abs
        let next_real_loop_pos = round(start_offset + beats_elapsed_abs + beats_remaining_till_next_loop)
        return next_real_loop_pos + pos
    }
    
    func getStartOfCurrentLoop()->Double {
        return loopManager.start_offset + loopManager.beats_elapsed_abs - loopManager.beats_elapsed
    }
    
    func insertNote(_ velocity: Int, position: AKDuration, duration: Double){
        var pos = position
        let note = instrument.note
        
        if(quantizeEnable && !firstInstance){
            instrument.quantizeHandled = true
            pos = quantizer.quantizedBeat(pos)
            print("inst \(trackNum) quantized pos \(pos.beats)")
        }
        print("insertNote at \(pos.beats)")
        track.tracks[trackNum].add(noteNumber: MIDINoteNumber(note), velocity: MIDIVelocity(velocity), position: pos, duration: AKDuration(seconds: duration))
    }
    
    func addNote(_ velocity: Int, duration: Double){
        let elapsed = loopManager.beats_elapsed
        let absElapsed = loopManager.beats_elapsed_abs
        
        if(clickTrack.instrument.preRollEnded){
            //if receive beat between last preroll and first record beat then save it but quantize to first record beat
            if(trackNotes.count > 0){
                return
            }
            let position = AKDuration(beats: 0, tempo: clickTrack.tempo.beatsPerMin)
            addNoteToList(velocity, position: position, duration: duration)
            let noteNum = trackNotes.count - 1
            let default_measures = loopManager.default_measures
            let beats_per_measure = loopManager.beats_per_measure
            let offset = (self.clickTrack.instrument.loop_count + default_measures) * beats_per_measure
            appendNoteFromOffset(offset: offset, noteNum: noteNum )
        }
        else if(!firstInstance){
            let position = AKDuration(beats: elapsed, tempo: clickTrack.tempo.beatsPerMin)
            if(trackNotes.count == 0){
                addNoteToList(velocity, position: position, duration: duration)
                let next_offset = instrument.next_start_pos + instrument.start_offset
                instrument.updateMaxNoteCount()
                appendNoteFromOffset(offset: next_offset, noteNum: trackNotes.count - 1)
            }
            else if(position.beats > (trackNotes.last?.beats)!){
                addNoteToList(velocity, position: position, duration: duration)
                let next_offset = instrument.next_start_pos + instrument.start_offset
                instrument.updateMaxNoteCount()
                appendNoteFromOffset(offset: next_offset, noteNum: trackNotes.count - 1)
            }
            else{
                addNoteToList(velocity, position: position, duration: duration)
            }
            
        }
        else{
            let absPosition = AKDuration(beats: absElapsed, tempo: clickTrack.tempo.beatsPerMin)
            addNoteToList(velocity, position: absPosition, duration: duration)
        }
        
    }
    
    func addNoteToList(_ velocity: Int, position: AKDuration, duration: Double){
        noteCount += 1
        trackNotes.append(position)
        velNotes.append(velocity)
        durNotes.append(duration)
        var sortedNotes = [AKDuration]()
        
        sortedNotes = trackNotes.sorted {
            return $0.beats < $1.beats
        }
        trackNotes = sortedNotes
    }
    
    
    //MARK: Start loop after default measure reached
    func startLoopFromDefaultMeasures(){
        if(isNewRecord){
            recorded = true
            updateMeasureCount(loopManager.default_measures)
            instrument.updateNextStartPos()
            firstInstance = false
        }
    }
    
    //MARK: deselect instrument track - do anything that needs to be done after user stops using this track
    func deselect(){
        if(isNewRecord){
            let count = loopManager.measures_elapsed_abs
            updateMeasureCount(count)
            instrument.updateNextStartPos()
            let loop_count = clickTrack.instrument.loop_count
            
            continueTrackFromStopRecord(loop_count: loop_count)
            self.clickTrack.instrument.resetDefaultMeasureCounter()
            recordSet = false
            recorded = true
        }

    }
    
    func updateMeasureCount(_ count: Int){
        if(count < 1){
            print("Could not updated measure count")
            return
        }
        if(firstInstance || !track.isPlaying){
            loopManager.measures = count
        }
        else if(!instrument.measureUpdateEvent){
            addMeasureUpdateEvent(count: count)
        }
        else if(instrument.measureUpdateEvent){
            addMeasureUpdateEvent(count: count)
        }
    }
    
    func applyUpdateMeasureCount(count: Int){
        if(instrument.measureUpdateEvent){
            let prev_end_loop_pos = instrument.nextStartOffset
            instrument.measureUpdateEvent = false
            resetTrack(clearAll: true)
            loopManager.measures = instrument.nextMeasureCount
            //loopManager.beats_elapsed_offset = loopManager.beats_elapsed_abs
            appendTrack(offset: prev_end_loop_pos)
        }
    }
    
    //After user stops recording for a specific track, the start appending the track to the loop so it continues playing
    func continueTrackFromStopRecord(loop_count: Int){
        firstInstance = false //first instance measure count update complete
        if(trackNotes.count==0){ return }
        let beats_per_measure = loopManager.beats_per_measure
        let beatOffset = Double(loop_count * beats_per_measure)
        appendTrack(offset: Double(beatOffset))
    }
    
    func appendTrack(offset: Double){
        print("append \(trackNotes.count) to track \(trackNum) with offset \(offset)!")
        
        for note in trackNotes {
            if(note.beats <= Double(loopManager.beats_per_loop)){
                let position = AKDuration(beats: note.beats + offset)
                insertNote(127, position: position, duration: 0.1)
            }
            
        }
    }
    
    func appendTrackFromNoteNum(offset: Double, noteNum: Int){
        if(noteNum < trackNotes.count){
            for i in noteNum ..< trackNotes.count {
                if(trackNotes[i].beats <= Double(loopManager.beats_per_loop)){
                    let position = AKDuration(beats: trackNotes[i].beats + offset)
                    insertNote(127, position: position, duration: 0.1)
                }
            }
        }
    }
    
    func appendNoteFromOffset(offset: Double, noteNum: Int){
        if(noteNum >= trackNotes.count){
            return
        }
        let position = AKDuration(beats: trackNotes[noteNum].beats + offset)
        insertNote(127, position: position, duration: 0.1)
    }

    func clear(){
        recordSet = false
        recorded = false
        loopManager.reset()
        noteCount = 0
        trackNotes.removeAll()
        velNotes.removeAll()
        durNotes.removeAll()
        firstInstance = true
        resetTrack(clearAll: true)
        instrument.reset()
    }
    
}







