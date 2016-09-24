//
//  ViewController.swift
//  Groover
//
//  Created by Alex Crane on 7/3/16.
//  Copyright © 2016 TCM. All rights reserved.
//

import UIKit
import CoreMotion

class ViewController: UIViewController {
    //MARK: properties
    var song: Song!
    var audioMidiSetupEn = true
    let sensor = MidiSensorWrapper()
    let motionManager = CMMotionManager()
    let queue = OperationQueue.main
    var timeIntervalMillis: UInt = 25
    
    //MARK: outlets
    
    @IBOutlet weak var hamburgerButton: HamburgerIcon!
    @IBOutlet weak var settingsButton: SettingsIcon!
    @IBOutlet weak var parametersButton: ParametersButton!
    @IBOutlet weak var popup: Popup!
    @IBOutlet weak var positionIndicator: PositionIndicator!
    @IBOutlet weak var knob: KnobCtrl!
    @IBOutlet weak var positionLabel: UILabel!
    @IBOutlet weak var parametersPopup: ParametersPopup!
    @IBOutlet weak var quantizeControl: QuantizeControl!
    @IBOutlet weak var playButton: PlayCtrl!
    @IBOutlet weak var recordButton: RecordCtrl!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //Connect view controller functions to buttons events
        playButton.addTarget(self, action: #selector(ViewController.playRecordButtonSelected(_:)), for: .valueChanged)
        recordButton.addTarget(self, action: #selector(ViewController.playRecordButtonSelected(_:)), for: .valueChanged)
        hamburgerButton.addTarget(self, action: #selector(ViewController.hamburgerButtonSelected), for: .valueChanged)
        knob.addTarget(self, action: #selector(ViewController.knobAngleChanged(_:)), for: .valueChanged)
        knob.addTarget(self, action: #selector(ViewController.innerKnobTapped(_:)), for: .editingChanged)
        knob.addTarget(self, action: #selector(ViewController.hidePositionIndicator), for: .editingDidEnd)
        parametersButton.addTarget(self, action: #selector(ViewController.parametersButtonSelected), for: .valueChanged)
        parametersPopup.addTarget(self, action: #selector(ViewController.parametersOptionSelected), for: .valueChanged)
        popup.addTarget(self, action: #selector(ViewController.popupButtonSelected), for: .valueChanged)
        quantizeControl.addTarget(self, action: #selector(ViewController.quantizeButtonSelected), for: .valueChanged)
        song = Song()
        positionLabel.text = song.selectedInstrumentName
        song.start()
        
        motionManager.startAccelerometerUpdates()
        if motionManager.isAccelerometerAvailable {
            motionManager.accelerometerUpdateInterval = TimeInterval(Double(timeIntervalMillis)/1000.0)
            motionManager.startAccelerometerUpdates(to: queue, withHandler: beatHandler as! CMAccelerometerHandler)
            
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override var prefersStatusBarHidden : Bool {
        return true
    }
    
    //MARK: Button event handlers
    
    
    //MARK: hamburger / settings button
    func hamburgerButtonSelected(){
        print("hamburger button selected")
        popup.toggleHide()
    }
    
    //MARK: Quantize buttons
    func quantizeButtonSelected(){
        let selected = quantizeControl.currentButton.isSelected
        var resolution = quantizeControl.currentButton.resolution
        if(quantizeControl.tripletButton.isSelected){
            resolution = resolution * quantizeControl.tripletButton.resolution //ex: if quarter not selected and triplet then resolution = 1*3
            print("resolution \(resolution)")
        }
        song.updatePresetQuantize(enabled: selected, resolution: resolution)
    }
    
    //MARK: Parameter option selected
    func parametersOptionSelected(){
        var buttonType = ParametersButtonTypes.clear
        buttonType = parametersPopup.selectedButton.type
        let selected = parametersPopup.selectedButton.isSelected
        
        switch buttonType {
        case .clear:
            song.clearPreset()
            print("song clear preset!")
        case .solo:
            if(selected){
                song.enableSoloPreset()
            }
            else{
                song.disableSoloPreset()
            }
            print("song solo preset!")
        case .mute:
            if(selected){
                song.mutePreset()
                print("mute preset!")
            }
            else{
                song.unmutePreset()
                print("unmute preset!")
            }
            
        case .measure_LEFT:
            print("measure change decrease to \(parametersPopup.measures)!")
        
        case .measure_RIGHT:
            print("measure change increase to \(parametersPopup.measures)!")
        }
    }
    
    //MARK: Parameter button function
    func parametersButtonSelected(){
        //hide or show popup
        if(parametersPopup.isHidden){
            parametersPopup.show()
            //update measure count based on selected instrument
            parametersPopup.setMeasure(song.presetMeasureCount)
        }
        else{
            parametersPopup.hide()
            //also see if user updated measure count and if so change preset track measure count
            let currentMeasures = song.presetMeasureCount
            let newMeasures = parametersPopup.measures
            let updated = parametersPopup.measuresUpdated
            if(newMeasures != currentMeasures && updated){
                song.updatePresetMeasureCount(newMeasures)
                parametersPopup.measuresUpdated = false //clear for next use
            }
            
            
        }
    }
    
    //MARK: Hide position indicator
    func hidePositionIndicator(){
        positionIndicator.hide()
        parametersButton.show()
    }
    
    //MARK: popup buttons handler
    func popupButtonSelected(){
        var buttonType = PopupButtonTypes.upper_LEFT
        buttonType = popup.currentButton.type
        
        switch buttonType {
        case .upper_LEFT:
            song.setTempo(popup.tempo)
            print("update tempo dec")
            break
        case .upper_RIGHT:
            song.setTempo(popup.tempo)
            print("update tempo inc")
            break
        case .lower_LEFT:
            //song.instruments[song.selectedInstrument].decPresetVolume()
            //print("dec volume to \(song.instruments[song.selectedInstrument].presetVolume)")
            song.decPresetPan()
            print("dec Pan to \(song.instruments[song.selectedInstrument].pan)")
            break
        case .lower_RIGHT:
            //song.instruments[song.selectedInstrument].incPresetVolume()
            //print("inc volume to \(song.instruments[song.selectedInstrument].presetVolume)")
            song.incPresetPan()
            print("inc Pan to \(song.instruments[song.selectedInstrument].pan)")
            break
        }
    }
    
    //MARK: play button event handler
    func playRecordButtonSelected(_ playRecordButton: UIButton){
        if(playRecordButton == playButton){
            playButton.isSelected = !playButton.isSelected
            if(playButton.isSelected){
                song.stop() //disable recording first
                song.play()
            }
            else{
                song.stop()
            }
        }
        else if(playRecordButton == recordButton){
            if(playButton.isSelected){
                recordButton.isSelected = !recordButton.isSelected
            }
            //record if on and is playing
            if(recordButton.isSelected && playButton.isSelected){
                song.record()
                print("start record")
            }
            else{
                song.stop_record()
            }
        }
        
    }
    
    //MARK: Knob event handlers
    func knobAngleChanged(_ knobControl: KnobCtrl){
        positionIndicator.show()
        parametersButton.hide()
        print("knob angle changed to \(knobControl.angle)!")
        print("knob detentNum \(knob.detent)")
        positionIndicator.setPosition(knobControl.detent)
        let position = positionIndicator.currentPos //ex: 0 or 1 or 2 or 3...17
        let wasRecording = song.recordEnabled
        selectSound(position)
        if(!song.recordEnabled && wasRecording){
            recordButton.isSelected = false
        }
        else{
            updateButtonStatesAfterKnobTurn()
        }
        
    }
    
    //MARK: Update button states from knob turn
    func updateButtonStatesAfterKnobTurn(){
        //TODO: ?
        print("update after knob turned called")
    }
    
    //MARK: Update button after note added
    func updateButtonStatesAfterNoteAdded(){
        print("update after note added called")
    }
    
    
    
    func selectSound(_ position: Int){
        song.selectInstrument(position)
        positionLabel.text = song.selectedInstrumentName
    }
    
    func innerKnobTapped(_ knobControl: Knob){
        print("Inner knob tapped")
        song.toggleClickTrackMute()
        
        //temporary hack when not using iPhone (using simulator) to allow for beat generation
        song.addNote() //Used for testing in sim mode to simulate motion generated beat
        updateButtonStatesAfterNoteAdded()
    }
    
    //MARK: Motion Sensor Functions
    func beatHandler(_ data: CMAccelerometerData?, error: NSError?){
        let valx = Int32(16383.0 * (data!.acceleration.x))
        let valy = Int32(16383.0 * (data!.acceleration.y))
        let valz = Int32(16383.0 * (data!.acceleration.z))
        
        sensor?.updateState(with: valx, andY: valy, andZ: valz, andMillisElapsed: timeIntervalMillis);
        sensor?.handleMidiEvents();
        if(sensor?.beat)!{
            let eventStatus = Int((sensor?.getEventStatus())!)
            if eventStatus != 0x80{
                song.addNote() //make drum sound and add to track if recording!
                updateButtonStatesAfterNoteAdded()
            }
            
        }
        
    }
    
    
}

