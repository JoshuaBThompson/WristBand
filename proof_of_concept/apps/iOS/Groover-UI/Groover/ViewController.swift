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
    var timeIntervalMillis: UInt = 25 //25
    var quantizeButtons = [QuantizeButtonProtocol]()
    var riseNum: Int = 0
    var fallNum: Int = 0
    var selectedSong = String()
    var risingBeatFilter = RisingBeatFilter()
    var fallingBeatFilter = FallingBeatFilter()
    var beatDetected = false
    var beatDetectedCount = 0
    var prevKnobDetent: Int = 0
    
    //MARK: outlets
    
    @IBOutlet weak var measureView1: Measure!
    @IBOutlet weak var instrumentViewWrap: UIView!
    @IBOutlet weak var instrumentNameLabel: UILabel!
    
    @IBOutlet weak var knob: KnobCtrl!
    
    @IBOutlet weak var parametersButton: ParametersButtonCtrl!
    
    @IBOutlet weak var positionIndicator: PositionIndicator!
    //@IBOutlet weak var parametersPopup: ParametersPopupCtrl!
    
    @IBOutlet weak var playButton: PlayCtrl!
    @IBOutlet weak var recordButton: RecordCtrl!
    

    @IBOutlet weak var quarterQuantizeButton: QuarterCtrl!
    @IBOutlet weak var eighthQuantizeButton: EighthCtrl!
    @IBOutlet weak var sixteenthQuantizeButton: SixteenthCtrl!
    @IBOutlet weak var thirtysecondQuantizeButton: ThirtysecondCtrl!
    @IBOutlet weak var tripletQuantizeButton: TripletCtrl!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage =  UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        // Do any additional setup after loading the view, typically from a nib.s
        
        //Connect view controller functions to buttons events
        
        //Play / Record
        
        playButton.addTarget(self, action: #selector(ViewController.playRecordButtonSelected(_:)), for: .valueChanged)
        recordButton.addTarget(self, action: #selector(ViewController.playRecordButtonSelected(_:)), for: .valueChanged)
        
        //Knob
        
        knob.addTarget(self, action: #selector(ViewController.knobAngleChanged(_:)), for: .valueChanged)
        knob.addTarget(self, action: #selector(ViewController.innerKnobTapped(_:)), for: .editingChanged)
        knob.addTarget(self, action: #selector(ViewController.hidePositionIndicator), for: .editingDidEnd)
        
        //Quantize
        
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
        
        song = GlobalAttributes.song
        
        song.start()
        
        motionManager.startAccelerometerUpdates()
        if motionManager.isAccelerometerAvailable {
            motionManager.accelerometerUpdateInterval = TimeInterval(Double(timeIntervalMillis)/1000.0)
            motionManager.startAccelerometerUpdates(to: queue, withHandler: beatHandler)
            
        }
        prevKnobDetent = knob.detent
    
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        instrumentNameLabel.text = song.selectedInstrumentName
        //animateMeasureView()
        //testAnimate()
    }
    
    func animateMeasureView(){
    
        UIView.animate(withDuration: 12.0, delay: 0.0, options: .repeat, animations: {
            self.measureView1.updateMeasureProgress(progress_prcnt: 10)
            self.measureView1.setNeedsDisplay()
            
        }, completion: nil)
    }
    
    func testAnimate(){
        
        UIView.animate(withDuration: 0.5, delay: 0.0, options: [UIViewAnimationOptions.repeat, UIViewAnimationOptions.curveEaseOut], animations: {
            if(self.recordButton.backgroundColor == UIColor.red){
                self.recordButton.backgroundColor = UIColor.blue
            }
            else{
                self.recordButton.backgroundColor = UIColor.red
            }
            self.view.layoutIfNeeded()
        }, completion: nil)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override var prefersStatusBarHidden : Bool {
        return true
    }
    
    
    //MARK: Button event handlers
    
    
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
    
    
    //MARK: Hide position indicator
    func hidePositionIndicator(){
        parametersButton.show()
        positionIndicator.hide()
        instrumentViewWrap.backgroundColor = UIColor.clear
        //parametersButton.show()
        
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
                song.stop_record()
                song.stop()
                recordButton.isSelected = false //toggle record button
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
        
        let position = knob.detent
        let wasRecording = song.recordEnabled
        if(prevKnobDetent != position){
            parametersButton.hide()
            instrumentViewWrap.backgroundColor = UIColor.black
            positionIndicator.show()
            positionIndicator.setPosition(knobControl.detent)
        }
        prevKnobDetent = position
        
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
        instrumentNameLabel.text = song.selectedInstrumentName
    }
    
    func innerKnobTapped(_ knobControl: Knob){
        print("Inner knob tapped")
        song.toggleClickTrackMute()
        
        //temporary hack when not using iPhone (using simulator) to allow for beat generation
        song.addNote() //Used for testing in sim mode to simulate motion generated beat
        knob.updateClickRingActive(active: true)
        beatDetected = true
        updateButtonStatesAfterNoteAdded()
    }

    //MARK: Motion Sensor Functions
    func beatHandler(_ data: CMAccelerometerData?, error: Error?){
        
        //let valx = Int32(16383.0 * (data!.acceleration.x))
        let valx_f: Double = (data!.acceleration.x)*100.0
        let valx = Int16(valx_f)
        
        if fallingBeatFilter.isBeat(x: valx){
            fallNum += 1
            if(fallNum >= 2 || (riseNum == 0)){
                print("Fall Note \(fallNum)")
                song.addNote() //make drum sound and add to track if recording!
                knob.updateClickRingActive(active: true)
                beatDetected = true
                riseNum = 0
                
            }
            
        }
            
        else if risingBeatFilter.isBeat(x: valx) {
            riseNum += 1
            if(riseNum >= 2 || (fallNum == 0)){
                print("Rise Note \(riseNum)")
                song.addNote() //make drum sound and add to track if recording!
                knob.updateClickRingActive(active: true)
                beatDetected = true
                fallNum = 0
                
            }
        
        }
        
        if(beatDetected){
            beatDetectedCount += 1
            if(beatDetectedCount >= 10){
                knob.updateClickRingActive(active: false)
                beatDetected = false
                beatDetectedCount = 0
            }
        }
        
        //let valy_f: Double = (data!.acceleration.y)*100.0
        //let valy = Int16(valy_f)
        
        //let valz_f: Double = (data!.acceleration.z)*100.0
        //let valz = Int16(valz_f)
        
        
        /*
        sensor?.updateState(with: valx, andY: valy, andZ: valz, andMillisElapsed: timeIntervalMillis);
        sensor?.printXList();
        sensor?.handleMidiEvents();
        if(sensor?.beat)!{
            let eventStatus = Int((sensor?.getEventStatus())!)
            if eventStatus != 0x80{
                testNum += 1
                print("Note \(testNum)")
                song.addNote() //make drum sound and add to track if recording!
//                updateButtonStatesAfterNoteAdded()
            }
            
        }
        */
        
    }
    
    @IBAction func unwindToGroove(segue: UIStoryboardSegue) {}
    
    
}

