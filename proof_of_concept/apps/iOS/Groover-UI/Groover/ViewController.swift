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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

/*import UIKit
import CoreMotion

class ViewController: UIViewController {
    //MARK: properties
    var song: Song!
    var audioMidiSetupEn = true
    let sensor = MidiSensorWrapper()
    let motionManager = CMMotionManager()
    let queue = OperationQueue.main
    var timeIntervalMillis: UInt = 25
    var quantizeButtons = [QuantizeButtonProtocol]()
    
    //MARK: outlets
    
    @IBOutlet weak var hamburgerButton: HamburgerIconCtrl!
    @IBOutlet weak var settingsButton: SettingsIconCtrl!
    @IBOutlet weak var parametersButton: ParametersButtonCtrl!
    @IBOutlet weak var popup: PopupCtrl!
    @IBOutlet weak var positionIndicator: PositionIndicator!
    @IBOutlet weak var knob: KnobCtrl!
    @IBOutlet weak var positionLabel: UILabel!
    @IBOutlet weak var parametersPopup: ParametersPopupCtrl!
    @IBOutlet weak var playButton: PlayCtrl!
    @IBOutlet weak var recordButton: RecordCtrl!
    @IBOutlet weak var quarterQuantizeButton: QuarterCtrl!
    @IBOutlet weak var eighthQuantizeButton: EighthCtrl!
    @IBOutlet weak var sixteenthQuantizeButton: SixteenthCtrl!
    @IBOutlet weak var thirtysecondQuantizeButton: ThirtysecondCtrl!
    @IBOutlet weak var tripletQuantizeButton: TripletCtrl!
    
    //MARK: parameters popup elements
    @IBOutlet weak var muteButton: MuteButton!
    @IBOutlet weak var clearButton: ClearButton!
    @IBOutlet weak var soloButton: SoloButton!
    @IBOutlet weak var measureCountLabel: UILabel!
    @IBOutlet weak var measuresLabel: UILabel!
    @IBOutlet weak var rightMeasureButton: MeasureRightButton!
    @IBOutlet weak var leftMeasureButton: MeasureLeftButton!
    
    //MARK: settings popup elements
    
    @IBOutlet weak var tempoRightButton: TempoRightButton!
    @IBOutlet weak var tempoLeftButton: TempoLeftButton!
    @IBOutlet weak var timesigRightButton: TimeSigRightButton!
    @IBOutlet weak var timesigLeftButton: TimeSigLeftButton!
    @IBOutlet weak var tempoLabel: UILabel!
    @IBOutlet weak var timesigLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //Init settings popup with buttons and labels from main storyboard
        popup.initButtonsAndLabels(tempoRightButtonRef: tempoRightButton, tempoLeftButtonRef: tempoLeftButton, timesigRightButtonRef: timesigRightButton, timesigLeftButtonRef: timesigLeftButton, tempoLabelRef: tempoLabel, timesigLabelRef: timesigLabel)
        //Init parameters popup with buttons and labels from main storyboard
        parametersPopup.initButtonsAndLabels(clearButtonRef: clearButton, soloButtonRef: soloButton, muteButtonRef: muteButton, rightButtonRef: rightMeasureButton, leftButtonRef: leftMeasureButton, measureTitleRef: measuresLabel, measureLabelRef: measureCountLabel)
        
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
        quarterQuantizeButton.addTarget(self, action: #selector(ViewController.quantizeButtonSelected(_:)), for: .valueChanged)
        eighthQuantizeButton.addTarget(self, action: #selector(ViewController.quantizeButtonSelected(_:)), for: .valueChanged)
        sixteenthQuantizeButton.addTarget(self, action: #selector(ViewController.quantizeButtonSelected(_:)), for: .valueChanged)
        thirtysecondQuantizeButton.addTarget(self, action: #selector(ViewController.quantizeButtonSelected(_:)), for: .valueChanged)
        tripletQuantizeButton.addTarget(self, action: #selector(ViewController.quantizeButtonSelected(_:)), for: .valueChanged)
        
        quantizeButtons.append(quarterQuantizeButton)
        quantizeButtons.append(eighthQuantizeButton)
        quantizeButtons.append(sixteenthQuantizeButton)
        quantizeButtons.append(thirtysecondQuantizeButton)
        quantizeButtons.append(tripletQuantizeButton)
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
    func quantizeButtonSelected(_ quantizeButton: QuantizeButtonProtocol){
        print("quantizebuttonselected")
        var selected: Bool = false
        var resolution: Double = 0
        
        if(quantizeButton.resolution != TripletResolution){
            resolution = quantizeButton.resolution
            selected = quantizeButton.on
        }
        
        for button in quantizeButtons {
            if(button.resolution != quantizeButton.resolution && quantizeButton.resolution != TripletResolution && button.resolution != TripletResolution){
                button.on = false
            }
            
            else if(button.resolution != TripletResolution && quantizeButton.resolution == TripletResolution){
                if(button.on){
                    selected = true
                    resolution = button.resolution
                    print("quantize test for \(resolution)")
                }
            }
        }
        
        print("Triplet Quantize is \(tripletQuantizeButton.isSelected)")
        if(tripletQuantizeButton.isSelected){
            resolution = resolution * tripletQuantizeButton.resolution //ex: if quarter not selected and triplet then resolution = 1*3
            print("resolution \(resolution)")
        }
        print("updated quantize sel \(selected) res \(resolution)")
        song.updatePresetQuantize(enabled: selected, resolution: resolution)
        
    }
    
    //MARK: Parameter option selected
    func parametersOptionSelected(){
        var buttonType = ParametersButtonTypes.CLEAR
        buttonType = parametersPopup.buttonTypeSelected
        
        switch buttonType {
        case .CLEAR:
            song.clearPreset()
            print("song clear preset!")
        case .SOLO:
            if(parametersPopup.soloButton.isSelected){
                song.enableSoloPreset()
            }
            else{
                song.disableSoloPreset()
            }
            print("song solo preset!")
        case .MUTE:
            if(parametersPopup.muteButton.isSelected){
                song.mutePreset()
                print("mute preset!")
            }
            else{
                song.unmutePreset()
                print("unmute preset!")
            }
            
        case .MEASURE_LEFT:
            print("measure change decrease to \(parametersPopup.measures)!")
        
        case .MEASURE_RIGHT:
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
        var buttonType = SettingsButtonTypes.TEMPO_LEFT
        buttonType = popup.buttonTypeSelected
        
        switch buttonType {
        case .TEMPO_LEFT:
            song.setTempo(popup.tempo)
            print("update tempo dec")
            break
        case .TEMPO_RIGHT:
            song.setTempo(popup.tempo)
            print("update tempo inc")
            break
        case .TIMESIG_LEFT:
            //song.instruments[song.selectedInstrument].decPresetVolume()
            //print("dec volume to \(song.instruments[song.selectedInstrument].presetVolume)")
            song.decPresetPan()
            print("dec Pan to \(song.instruments[song.selectedInstrument].pan)")
            break
        case .TIMESIG_RIGHT:
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
//                updateButtonStatesAfterNoteAdded()
            }
            
        }
        
    }
    
    
}*/

