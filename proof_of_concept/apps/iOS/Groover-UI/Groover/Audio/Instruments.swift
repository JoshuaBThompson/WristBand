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

/****************Quantize*******************/
class Quantize {
    var divPerBeat = 1.0 //divisions per beat (beat resolution, ex: 64 divisions would be highest resolution and 1 is lowest)
    let maxDivisions = 64.0
    let minDivisions = 1.0
    
    //MARK: quantize a beat pos
    func quantizedBeat(_ beat: AKDuration)->AKDuration{
        let beats = beat.beats
        let divPos = beats * divPerBeat //position in beat divisions (based on quantized number / resolution set by user in UI: ex: 4 or 32)
        let divPosQuantized = round(divPos) //round to nearest division
        let beatsQuantized = divPosQuantized / divPerBeat //get beat position quantized
        
        let posQuantized = AKDuration(beats: beatsQuantized, tempo: beat.tempo)
        return posQuantized
        
    }
    
    //MARK: update the quantization beat divisions
    func update(_ newBeatDivision: Double){
        var div = newBeatDivision
        
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


/****************Base class of synth instruments
 ****************/

class SynthInstrument: AKMIDIInstrument{
    var note: Int = 0
    var muted = false
    var volumePercent: Double = 100.0
    var instrumentName = "Synth Instrument"
    var sampler = AKSampler()
    var preset = 0
    var reset_en = false
    var instTrack: InstrumentTrack!
    var panner: AKPanner!
    var beatOffset: Double = 0
    
    //looping
    var ignore = false  // use to ignore specific beat
    var real_pos: Double = 0
    var note_num: Int = 0
    var loop_count: Int = 0
    var _total_dur: Double = 0
    var _maxNoteCount: Int = 0
    var total_dur_offset: Double = 0
    var measureUpdateReady = false
    var measureUpdateEn = false
    var quantizeHandled = true
    var prevBeat: AKDuration!
    var currentBeat: AKDuration!
    
    
    var quantizeEnabled: Bool {
        return instTrack.trackManager.quantizeEnable
    }
    
    var total_dur: Double {
        _total_dur = Double(instTrack.loopLength)
        return _total_dur
    }
    
    var maxNoteCount: Int {
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
    
    var realPos: Double {
        return total_dur_offset + beatPos + beatOffset
    }
    
    var realMaxPos: Double {
        return total_dur_offset + maxBeatPos + beatOffset
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
    }
    
    func reset(){
        note_num = 0
        real_pos = 0
        loop_count = 0
        total_dur_offset = 0
        _maxNoteCount = 0
        _total_dur = 0
        beatOffset = 0
        measureUpdateReady = false
        measureUpdateEn = false
        quantizeHandled = true
        prevBeat = nil
        currentBeat = nil
    }
    
    func incTotalDurOffset(){
        total_dur_offset = total_dur_offset + total_dur
    }
    
    func updateNoteNumAndOffset(){
        prevBeat = AKDuration(beats: realPos, tempo: globalTempo)
        if(quantizeHandled && quantizeEnabled){
            prevBeat = instTrack.trackManager.quantizer.quantizedBeat(prevBeat)
        }
        
        note_num += 1
        
        if(note_num >= maxNoteCount){
            
            note_num = 0
            if(measureUpdateReady && !measureUpdateEn){
                measureUpdateEn = true
            }
            else if(measureUpdateEn){
                measureUpdateReady = false
                measureUpdateEn = false
            }
            loop_count += 1
            incTotalDurOffset()
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
        instTrack.trackManager.appendTrackFromNoteNum(offset: total_dur_offset + beatOffset, noteNum: note_num)
    }
    
    func appendRemainingBeatsInCurrentLoop(){
        instTrack.trackManager.appendTrackFromNoteNum(offset: total_dur_offset + beatOffset, noteNum: note_num)
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
            instTrack.trackManager.appendTrack(offset: total_dur_offset + beatOffset) //offset in beats
            loop_count = 0
        }
        else{
            handleQuantize()
        }
        
    }
    
    func rawPlay(_ noteNumber: MIDINoteNumber, velocity: MIDIVelocity){
        if(!muted){
            let volume = volumeScale * velocity/127.0
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
        
        if(ignore){
            ignore = false  //ignore specific beat and then reset ignore
        }
        else if(!muted){
            let volume = volumeScale * velocity/127.0
            sampler.volume = volume
            sampler.play()
        }
        addNote()
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
    var startRecordOffset = 0.0
    
    
    init(clickTrackRef: ClickTrack!) {
        super.init()
        clickTrack = clickTrackRef
        note = 60
        muted = true
        preRollSampler.loadWav("Sounds_clicks/AlertClick-1-low")
        sampler.loadWav("Sounds_clicks/MainClick-1-low")
        mixer = AKMixer()
        mixer.connect(preRollSampler)
        mixer.connect(sampler)
        self.avAudioNode = mixer.avAudioNode //sampler.avAudioNode
        
    }
    
    
    override func reset(){
        beat = 0
        preRollEnded = false
        preRoll = false
        loop_count = 0
        totalBeats = 0
        defaultMeasureCountEnded = false
        defaultMeasureCountStarted = false
        defaultMeasureCounter  = 0
        startRecordOffset = 0.0
        pos = 0
    }
    
    //this tells click track to start pre roll sound and then tell instruments to start recording on last beat
    func set_record(){
        preRoll = true
    }
    
    func startDefaultMeasureCounter(){
        defaultMeasureCountStarted = true
    }
    
    func updateDefaultMeasureCounter(){
        if(defaultMeasureCounter >= defaultMeasures){
            defaultMeasureCountEnded = true
            defaultMeasureCountStarted = false
        }
        else{
            defaultMeasureCounter += 1
        }
    }
    
    /// Start playback of a particular voice with MIDI style note and velocity
    ///
    /// - parameter voice: Voice to start
    /// - parameter note: MIDI Note Number
    /// - parameter velocity: MIDI Velocity (0-127)
    ///
    override func play(noteNumber: MIDINoteNumber, velocity: MIDIVelocity) {
        if(beat == 0){
            if(defaultMeasureCountStarted){
                updateDefaultMeasureCounter()
            }
            loop_count += 1
        }
        beat+=1
        pos += 1
        var vel = 100
        if(pos.truncatingRemainder(dividingBy: 4) == 0){
            vel = 127
        }
        
        var volume = velocity/127.0
        if(preRoll && beat <= 4){
            volume = 127
            if(beat == 4){
                preRoll = false
                preRollEnded = true
                startDefaultMeasureCounter()
            }
            preRollSampler.volume = volume
            preRollSampler.play()
            print("preroll \(beat)")
        }
        else if(!self.muted){
            if(preRollEnded){
                clickTrack.song.start_record()
                startRecordOffset = clickTrack.track.currentPosition.beats
                preRollEnded = false
            }
            
            sampler.volume = volume
            sampler.play()
        }
        else if(preRollEnded){
            clickTrack.song.start_record()
            startRecordOffset = clickTrack.track.currentPosition.beats
            preRollEnded = false
        }
        
        if(defaultMeasureCountEnded){
            clickTrack.song.startPresetWithDefaultMeasureCount()
            defaultMeasureCountEnded = false
        }
        
        
        if(loop_count >= 2 || beat==4){
            track.tracks[0].add(noteNumber: 60, velocity: vel, position: AKDuration(beats: Double(pos)), duration: AKDuration(seconds: 0.1))
            //print("click track beat \(beat) at pos \(pos)")
        }
        if(beat==4){
            beat=0
        }
    }
}



//Timer
class SongTimer {
    
    var startTime:CFAbsoluteTime
    var endTime:CFAbsoluteTime?
    
    init() {
        startTime = CFAbsoluteTimeGetCurrent()
    }
    
    func start(){
        startTime = CFAbsoluteTimeGetCurrent()
    }
    
    func stop() -> CFAbsoluteTime {
        endTime = CFAbsoluteTimeGetCurrent()
        
        return duration!
    }
    
    var duration:CFAbsoluteTime? {
        if let endTime = endTime {
            return endTime - startTime
        } else {
            return nil
        }
    }
}

//Time Signature
struct TimeSignature {
    var baseSecPerMeasure: Double = 4.0
    var beatsPerMeasure = 4 //upper - ex: 4 quarter notes in a measure for a (4/4th)
    var beatUnit = 4 //lower - ex: quarter note (4/4th)
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
    var timer = SongTimer()
    var midi: AKMIDI!
    var track: AKSequencer!
    var instrument: ClickTrackInstrument!
    var tempo: Tempo!
    var timeSignature: TimeSignature!
    var _enabled = false
    var recording = false
    var song: Song!
    
    //computed
    var secPerMeasure: Double {return (Double(timeSignature.beatsPerMeasure) / tempo.beatsPerSec) * 4/Double(timeSignature.beatUnit) }
    var secPerClick: Double { return secPerMeasure / Double(timeSignature.beatsPerMeasure) }
    var clickPerSec: Double { return 1/secPerClick }
    var beep: AKOperation!
    var trig: AKOperation!
    var beeps: AKOperation!
    var _running = false
    var running: Bool { return _running}
    var enabled: Bool { return _enabled }
    var muted: Bool { return instrument.muted}
    
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
    
    func initInstrumentTrack(){
        instrument.enableMIDI(midi.client, name: "click track midi in")
        init_track_notes()
    }
    
    func init_track_notes(){
        if(track.trackCount != 0){
            //this will erase all the other instrument tracks as well
            track.tracks.removeAll()
        }
        if(track.newTrack() != nil){
            track.tracks[0].setMIDIOutput(instrument.midiIn)
            track.setTempo(tempo.beatsPerMin)
            instrument.track = track
            resetTrack()
        }
        
    }
    
    func reset(){
        if(!enabled){
            return
        }
        
        if((track) != nil){
            resetTrack()
            track.rewind()
            track.enableLooping()
            track.play()
        }
    }
    
    func resetTrack(){
        track.stop()
        track.disableLooping()
        if(track.tracks[0].length != 0){
            let len = track.tracks[0].length
            //erase only extra beats that are not part of original record
            let start = AKDuration(beats: Double(timeSignature.beatsPerMeasure), tempo: tempo.beatsPerMin)
            let end = AKDuration(beats: len+1, tempo: tempo.beatsPerMin)
            track.tracks[0].clearRange(start: start, duration: end)
            track.setLength(AKDuration(beats: 1000))
        }
        else{
            //track.setLength(AKDuration(beats: Double(timeSignature.beatsPerMeasure), tempo: tempo.beatsPerMin))
            track.setLength(AKDuration(beats: 1000))
            //track.setLength(AKDuration(beats: 0))
            track.tracks[0].add(noteNumber: 60, velocity: 127, position: AKDuration(beats: 0), duration: AKDuration(seconds: 0.1))
            track.tracks[0].add(noteNumber: 60, velocity: 127, position: AKDuration(beats: 1), duration: AKDuration(seconds: 0.1))
            track.tracks[0].add(noteNumber: 60, velocity: 127, position: AKDuration(beats: 2), duration: AKDuration(seconds: 0.1))
            track.tracks[0].add(noteNumber: 60, velocity: 127, position: AKDuration(beats: 3), duration: AKDuration(seconds: 0.1))
        }
        
    }
    
    
    func update(){
        //tempo.beatsPerMin is updated in Song.swift
        track.setTempo(tempo.beatsPerMin)
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
    var recording = false
    var loopLength: Int {
        return trackManager.measureCount * trackManager.beatsPerMeasure
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
    func updateQuantize(_ res: Double){
        //res is the resolution of the beat: ex: 16
        trackManager.quantizer.update(res)
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
        recording = true
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
        if(!trackManager.track.isPlaying){
            //clear non original beats from track with prev measure count
            trackManager.resetTrack()
        }
        trackManager.updateMeasureCount(count)
        
        //if playing tell track to wait unitl loop finishes before updating measure count
        if(trackManager.track.isPlaying){
            instrument.measureUpdateReady = true //tells instrument to update measure count in looping after next loop is ready, but not during current loop
        }
    }
    
}


/****************Measure Timeline Manager ***************/

class MeasureTimeline {
    var trackManager: TrackManager!
    var bar_count: Int = 0
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
        let current_track_measure = self.trackManager.getCurrentMeasureNum()
        let current_measure_progress = self.trackManager.getMeasureProgress()
        print("current measure \(current_track_measure)")
        prev_bar_num = bar_num
        self.bar_num = self.getBarNumFromMeasure(measure_num: current_track_measure)
        bars_progress[bar_num] = current_measure_progress
        //print("bar_num \(bar_num) progress \(current_measure_progress) track_num \(current_track_measure)")
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
    let minBeatDuration = 0.1
    var trackNum: Int!
    var track: AKSequencer!
    var quantizeEnable = false
    var quantizer = Quantize()
    var midi: AKMIDI!
    var trackNotes = [AKDuration]()
    var velNotes = [Int]()
    var durNotes = [Double]()
    var noteCount = 0
    var measureCount = 1 //default measure count
    var firstInstance = true //informs if this is the first time the track is being filled so we can define the initial measure count / duration
    var instrument: SynthInstrument!
    var clickTrack: ClickTrack!
    var timer: SongTimer!
    var ignore_count = 0
    var timeline: MeasureTimeline!
    
    //MARK: Computed
    var defaultMeasureCount: Int {
        if(clickTrack != nil){
            return clickTrack.instrument.defaultMeasures
        }
        else{
            return GlobalDefaultMeasures
        }
    }
    
    var trackLength: Double {
        return track.tracks[trackNum].length
    }
    var secPerMeasure: Double { return clickTrack.secPerMeasure }
    var beatsPerMeasure: Int { return clickTrack.timeSignature.beatsPerMeasure }
    var totalBeats: Int { return measureCount * beatsPerMeasure}
    var totalDuration: Double {
        
        return secPerMeasure * Double(measureCount)
    }
    
    var timeElapsedAbs: Double {
        let timeElapsedSec = timer.stop()
        return timeElapsedSec
    }
    
    var isNewRecord: Bool {
        return (trackNotes.count >= 1 && firstInstance)
    }
    
    var timeElapsed: Double {
        //this gets called when a beat is added to the track
        let timeElapsedSec = timer.stop() //gets the global click track time that is shared with the song / all instruments
        var time = 0.0
        if timeElapsedSec < totalDuration {
            time = timeElapsedSec
        }
        else{
            time = fmod(timeElapsedSec, totalDuration)
        }
        
        return time
    }
    
    var beatsElapsed: Double {
        let total_beats_elapsed = clickTrack.track.currentPosition.beats - clickTrack.instrument.startRecordOffset
        if(total_beats_elapsed < Double(totalBeats)){
            return total_beats_elapsed
        }
        else{
            return total_beats_elapsed.truncatingRemainder(dividingBy: Double(totalBeats))
        }
    }
    
    //MARK: Initialize
    
    init(midiInstrument: SynthInstrument, clickTrackRef: ClickTrack){
        midi = AKMIDI()
        measureCount = defaultMeasureCount
        instrument = midiInstrument
        clickTrack = clickTrackRef
        track = clickTrack.track
        timer = clickTrack.timer
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
    
    //MARK: init a track
    func resetTrack(clearAll: Bool = false){
        if(!clearAll){
            if(track.tracks[trackNum].length != 0){
                let len = track.tracks[trackNum].length
                //erase only extra beats that are not part of original record
                print("clearing totalBeats \(totalBeats) to len \(len)")
                //let start = AKDuration(beats: Double(totalBeats), tempo: clickTrack.tempo.beatsPerMin)
                let start = AKDuration(beats: 0, tempo: clickTrack.tempo.beatsPerMin)
                let end = AKDuration(beats: len+1, tempo: clickTrack.tempo.beatsPerMin)
                track.tracks[trackNum].clearRange(start: start, duration: end)
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
    
    func insertNote(_ velocity: Int, position: AKDuration, duration: Double){
        var pos = position
        let note = instrument.note
        
        if(quantizeEnable && !firstInstance){
            instrument.quantizeHandled = true
            pos = quantizer.quantizedBeat(pos)
            print("quantized pos \(pos.beats)")
        }
        
        print("track \(trackNum) insert note at \(position.beats)")
        track.tracks[trackNum].add(noteNumber: note, velocity: velocity, position: pos, duration: AKDuration(seconds: duration))
    }
    
    func addNote(_ velocity: Int, duration: Double){
        let elapsed = timeElapsed
        let absElapsed = timeElapsedAbs
        
        if(!firstInstance){
            let position = AKDuration(seconds: elapsed, tempo: clickTrack.tempo.beatsPerMin)
            addNoteToList(velocity, position: position, duration: duration)
            insertNote(velocity, position: position, duration: duration)
        }
        else{
            print("first instance beat")
            let absPosition = AKDuration(seconds: absElapsed, tempo: clickTrack.tempo.beatsPerMin)
            addNoteToList(velocity, position: absPosition, duration: duration)
            insertNote(velocity, position: absPosition, duration: duration)
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
        //now updates notes list
        trackNotes = sortedNotes
        //print("adding note \(noteCount) to track \(trackNum) at pos \(position.beats)")
    }
    
    //MARK: Get total measure count from time elapsed and sec per measure
    func getMeasureCountFromTimeElapsed()->Int {
        return Int(ceil(timeElapsedAbs / secPerMeasure))
    }
    
    func getCurrentMeasureNum() -> Int {
        let beats_elapsed = track.currentPosition.beats
        let beat_offset = clickTrack.instrument.startRecordOffset
        let abs_beats_elapsed = beats_elapsed - beat_offset
        let first_loop_finished = (abs_beats_elapsed > totalDuration)
        if(!firstInstance && first_loop_finished){
            print("!abs_beats \(abs_beats_elapsed) total \(totalDuration) beats elapsed \(beatsElapsed)")
            return Int(floor((beatsElapsed) / beatsPerMeasure))//Int(floor(self.timeElapsed / secPerMeasure))
        }
        else {
            print("abs_beats \(abs_beats_elapsed) total \(totalDuration)")
            return Int(floor(abs_beats_elapsed / beatsPerMeasure))//Int(floor(timeElapsedAbs / secPerMeasure))
        }
    }
    
    func getMeasureProgress()->Double {
        let measure_time: Double!
        let beats_elapsed = track.currentPosition.beats
        let tempo = clickTrack.track.tempo
        if(!firstInstance){
            
            //measure_time = timeElapsed.truncatingRemainder(dividingBy: secPerMeasure)
            measure_time = beats_elapsed.truncatingRemainder(dividingBy: Double(beatsPerMeasure))
        }
        else {
             //measure_time = timeElapsedAbs.truncatingRemainder(dividingBy: secPerMeasure)
             measure_time = beats_elapsed.truncatingRemainder(dividingBy: Double(beatsPerMeasure))
        }
        print("current pos \(track.currentPosition.beats)")
        print("measure time \(measure_time)")
        print("beats per measure \(beatsPerMeasure)")
        print("tempo \(tempo)")
        //let measure_progress = measure_time / secPerMeasure
        let measure_progress = measure_time / beatsPerMeasure
        print("measure progress \(measure_progress)")
        return measure_progress
    }

    
    //MARK: Start loop after default measure reached
    func startLoopFromDefaultMeasures(){
        if(isNewRecord){
            print("Starting loop from default measures")
            //If this is the first time the track is being created then update measure count after instrument record stopped / deselected
            //measure count = roundUp(timeElapsed (sec) / secPerMeasure) roundUp = ceil math function
            //for ex: if timeElapsed = 9 sec and sec per measure = 4 then measure count = ceil(9/4) = 2.25 = 3 measure counts
            
            updateMeasureCount(self.defaultMeasureCount)
            let loop_count = clickTrack.instrument.loop_count - 1
            continueTrackFromStopRecord(loop_count: loop_count)
        }
    }
    
    //MARK: deselect instrument track - do anything that needs to be done after user stops using this track
    func deselect(){
        if(isNewRecord){
            
            //If this is the first time the track is being created then update measure count after instrument record stopped / deselected
            //measure count = roundUp(timeElapsed (sec) / secPerMeasure) roundUp = ceil math function
            //for ex: if timeElapsed = 9 sec and sec per measure = 4 then measure count = ceil(9/4) = 2.25 = 3 measure counts
            
            let count = getMeasureCountFromTimeElapsed()
            updateMeasureCount(count)
            let loop_count = clickTrack.instrument.loop_count
            continueTrackFromStopRecord(loop_count: loop_count)
        }

    }
    
    func updateMeasureCount(_ count: Int){
        //hack - audiokit v3.2 since updating length of track doesn't work correctly, need to make new track each time new recording
        if(count < 1){
            print("Could not updated measure count")
            return
        }
        print("updated measure count to \(count)")
        measureCount = count
    }
    
    //After user stops recording for a specific track, the start appending the track to the loop so it continues playing
    func continueTrackFromStopRecord(loop_count: Int){
        if(trackNotes.count==0){return}
        firstInstance = false //first instance measure count update complete
        let beatOffset = Double(loop_count * clickTrack.timeSignature.beatsPerMeasure)
        instrument.beatOffset = beatOffset
        appendTrack(offset: Double(beatOffset))
    }
    
    func appendTrack(offset: Double){
        print("append \(trackNotes.count) to track \(trackNum) with offset \(offset)!")
        
        for note in trackNotes {
            if(note.beats <= Double(totalBeats)){
                let position = AKDuration(beats: note.beats + offset)
                insertNote(127, position: position, duration: 0.1)
            }
            
        }
    }
    
    func appendTrackFromNoteNum(offset: Double, noteNum: Int){
        if(noteNum < trackNotes.count){
            for i in noteNum ..< trackNotes.count {
                if(trackNotes[i].beats <= Double(totalBeats)){
                    let position = AKDuration(beats: trackNotes[i].beats + offset)
                    insertNote(127, position: position, duration: 0.1)
                }
            }
        }
    }

    func clear(){
        noteCount = 0
        trackNotes.removeAll()
        velNotes.removeAll()
        durNotes.removeAll()
        firstInstance = true
        measureCount = defaultMeasureCount
        resetTrack(clearAll: true)
        instrument.reset()
    }
    
}







