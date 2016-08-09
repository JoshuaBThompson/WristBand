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
    let queue = NSOperationQueue.mainQueue()
    var timeIntervalMillis: UInt = 25
    
    //MARK: outlets
    
    @IBOutlet weak var hamburgerButton: HamburgerIcon!
    @IBOutlet weak var settingsButton: SettingsIcon!
    @IBOutlet weak var parametersButton: ParametersButton!
    @IBOutlet weak var popup: Popup!
    @IBOutlet weak var positionIndicator: PositionIndicator!
    @IBOutlet weak var knob: Knob!
    @IBOutlet weak var playRecordControl: PlayRecordControl!
    @IBOutlet weak var positionLabel: UILabel!
    @IBOutlet weak var parametersPopup: ParametersPopup!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //Connect view controller functions to buttons events
        hamburgerButton.addTarget(self, action: #selector(ViewController.hamburgerButtonSelected), forControlEvents: .ValueChanged)
        knob.addTarget(self, action: #selector(ViewController.knobAngleChanged(_:)), forControlEvents: .ValueChanged)
        knob.addTarget(self, action: #selector(ViewController.innerKnobTapped(_:)), forControlEvents: .EditingChanged)
        knob.addTarget(self, action: #selector(ViewController.hidePositionIndicator), forControlEvents: .EditingDidEnd)
        playRecordControl.addTarget(self, action: #selector(ViewController.playRecordButtonSelected(_:)), forControlEvents: .ValueChanged)
        parametersButton.addTarget(self, action: #selector(ViewController.parametersButtonSelected), forControlEvents: .ValueChanged)
        popup.addTarget(self, action: #selector(ViewController.popupButtonSelected), forControlEvents: .ValueChanged)
        song = Song()
        positionLabel.text = song.selectedInstrumentName
        song.start()
        
        motionManager.startAccelerometerUpdates()
        if motionManager.accelerometerAvailable {
            motionManager.accelerometerUpdateInterval = NSTimeInterval(Double(timeIntervalMillis)/1000.0)
            motionManager.startAccelerometerUpdatesToQueue(queue, withHandler: beatHandler)
            
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    //MARK: Button event handlers
    
    func hamburgerButtonSelected(){
        print("hamburger button selected")
        popup.toggleHide()
    }
    
    //MARK: Parameter button function
    func parametersButtonSelected(){
        //hide or show popup
        if(parametersPopup.hidden){
            parametersPopup.show()
        }
        else{
            parametersPopup.hide()
        }
    }
    
    //MARK: Hide position indicator
    func hidePositionIndicator(){
        positionIndicator.hide()
        parametersButton.show()
    }
    
    //MARK: popup buttons handler
    func popupButtonSelected(){
        var buttonType = PopupButtonTypes.UPPER_LEFT
        buttonType = popup.currentButton.type
        
        switch buttonType {
        case .UPPER_LEFT:
            song.setTempo(popup.tempo)
            print("update tempo dec")
            break
        case .UPPER_RIGHT:
            song.setTempo(popup.tempo)
            print("update tempo inc")
            break
        case .LOWER_LEFT:
            break
        case .LOWER_RIGHT:
            break
        }
    }
    
    //MARK: play button event handler
    func playRecordButtonSelected(playRecordButton: PlayRecordControl){
        switch playRecordButton.currentButtonType {
        case .PLAY:
            if(playRecordButton.playButton.on){
                song.stop() //disable recording first
                song.play()
            }
            else{
                song.stop()
            }
            
        case .CLEAR:
            //clear track
            if(song.recordEnabled){
                print("clear current instrument song")
                song.clearPreset()
            }
            
        case .RECORD:
            //record if on and is playing
            if(playRecordButton.recordButton.on && playRecordButton.playButton.on){
                song.record()
                print("start record and enable clear")
            }
            else{
                song.stop_record()
            }
            
        }
        
    }
    
    //MARK: Knob event handlers
    func knobAngleChanged(knobControl: Knob){
        positionIndicator.show()
        parametersButton.hide()
        print("knob angle changed to \(knobControl.angle)!")
        print("knob detentNum \(knob.detent)")
        positionIndicator.setPosition(knobControl.detent)
        let position = positionIndicator.currentPos //ex: 0 or 1 or 2 or 3...17
        let wasRecording = song.recordEnabled
        selectSound(position)
        if(!song.recordEnabled && wasRecording){
            playRecordControl.manualDeselectButton(.RECORD)
        }
        else{
            updateButtonStatesAfterKnobTurn()
        }
        
    }
    
    //MARK: Update button states from knob turn
    func updateButtonStatesAfterKnobTurn(){
        //knob turned so check if recording
        //if recording then make the clear button visible again only if turned to diff instrument
        //to give user chance to clear track again
        print("update after knob turned called")
        updateClearButton()
    }
    
    //MARK: Update button after note added
    func updateButtonStatesAfterNoteAdded(){
        print("update after note added called")
        updateClearButton(true)
    }
    
    //MARK: Set clear button if appropriate
    func updateClearButton(noteAdded: Bool=false){
        let newInstrument = (song.selectedInstrument != song.prevSelectedInstrument)
        let newPreset = (song.selectedPreset != song.prevSelectedPreset)
        let empty = song.instrument.trackEmpty
        let recording = song.recordEnabled
        let clear = (newInstrument && newPreset && empty && recording)
        if(song.recordEnabled && noteAdded){
            playRecordControl.manualSelectButton(.CLEAR)
            return
        }
        else if(clear){
            print("manual select clear")
            playRecordControl.manualSelectButton(.CLEAR)
        }
        else{
            print("manual deselect clear")
            playRecordControl.manualDeselectButton(.CLEAR)
        }

    }
    
    
    func selectSound(position: Int){
        song.selectInstrumentFromPreset(position)
        positionLabel.text = song.selectedInstrumentName
    }
    
    func innerKnobTapped(knobControl: Knob){
        print("Inner knob tapped")
        song.toggleClickTrackMute()
        
        //temporary hack when not using iPhone (using simulator) to allow for beat generation
        song.addNote() //Used for testing in sim mode to simulate motion generated beat
        updateButtonStatesAfterNoteAdded()
    }
    
    //MARK: Motion Sensor Functions
    func beatHandler(data: CMAccelerometerData?, error: NSError?){
        let valx = Int32(16383.0 * (data!.acceleration.x))
        let valy = Int32(16383.0 * (data!.acceleration.y))
        let valz = Int32(16383.0 * (data!.acceleration.z))
        
        sensor.updateStateWith(valx, andY: valy, andZ: valz, andMillisElapsed: timeIntervalMillis);
        sensor.handleMidiEvents();
        if(sensor.beat){
            let eventStatus = Int(sensor.getEventStatus())
            if eventStatus != 0x80{
                song.addNote() //make drum sound and add to track if recording!
                updateButtonStatesAfterNoteAdded()
            }
            
        }
        
    }
    
    
}

