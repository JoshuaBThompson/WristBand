//
//  ViewController.swift
//  Groover
//
//  Created by Alex Crane on 7/3/16.
//  Copyright © 2016 TCM. All rights reserved.
//

/*
 * AudioKit v3.5.4 -- for xcode 8.3
 */


import UIKit
import CoreMotion

class ViewController: UIViewController, SongCallbacks {
    //MARK: properties
    var song: Song!
    var audioMidiSetupEn = true
    let motionManager = CMMotionManager()
    let queue = OperationQueue.main
    var timeIntervalMillis: UInt = 15 //25
    var quantizeButtons = [QuantizeButtonProtocol]()
    var riseNum: Int = 0
    var fallNum: Int = 0
    var selectedSong = String()
    var risingBeatFilter = RisingBeatFilter()
    var fallingBeatFilter = FallingBeatFilter()
    var beatDetected = false
    var beatDetectedCount = 0
    var prevKnobDetent: Int = 0
    var measureTimer: Timer!
    var buttonEventTimer: Timer!
    var timeline_needs_clear = false
    var measureViews = [MeasureCtrl]()
    var measureLabels = [UILabel]()
    var currentPosition = 0
    
    //Events
    var stopRecordButtonEvent = false
    var startRecordButtonEvent = false
    var deleteTrackEvent = false
    
    //MARK: outlets
    
    @IBOutlet weak var testView: UIView!
    @IBOutlet weak var measureView1: MeasureCtrl!
    @IBOutlet weak var measureView2: MeasureCtrl!
    @IBOutlet weak var measureView3: MeasureCtrl!
    @IBOutlet weak var measureView4: MeasureCtrl!
    
    @IBOutlet weak var measureView1Label: UILabel!
    @IBOutlet weak var measureView2Label: UILabel!
    @IBOutlet weak var measureView4Label: UILabel!
    @IBOutlet weak var measureView3Label: UILabel!
    
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
        
        GlobalAttributes.viewController = self
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
        song.delegate = self
        
        song.start()
        
        motionManager.startAccelerometerUpdates()
        if motionManager.isAccelerometerAvailable {
            motionManager.accelerometerUpdateInterval = TimeInterval(Double(timeIntervalMillis)/1000.0)
            motionManager.startAccelerometerUpdates(to: queue, withHandler: beatHandler)
            
        }
        prevKnobDetent = knob.detent
        measureViews.append(measureView1)
        measureViews.append(measureView2)
        measureViews.append(measureView3)
        measureViews.append(measureView4)
        
        measureLabels.append(measureView1Label)
        measureLabels.append(measureView2Label)
        measureLabels.append(measureView3Label)
        measureLabels.append(measureView4Label)
        
        for label in measureLabels {
            label.text = ""
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if(song.instruments.count > 0){
            selectSound(currentPosition)
        }
        instrumentNameLabel.text = song.selectedInstrumentName
        startMeasureTimelineThread()
        startButtonEventHandler()
    }
    
    //continuously checks to see what % of the current instrument measure count has elapsed
    //used to update the groover measure timeline bar progress
    func startMeasureTimelineThread(){
        measureTimer = Timer.scheduledTimer(timeInterval: 0.05, target: self, selector: #selector(measureTimerHandler), userInfo: nil, repeats: true)
        
    }
    
    func startButtonEventHandler(){
        buttonEventTimer = Timer.scheduledTimer(timeInterval: 0.25, target: self, selector: #selector(buttonEventHandler), userInfo: nil, repeats: true)
    }
    
    
    func buttonEventHandler(){
        if(stopRecordButtonEvent){
            stopRecordButtonEvent = false
            recordButton.setStopped()
            self.recordButton.isSelected = false
        }
        else if(deleteTrackEvent){
            deleteTrackEvent = false
            self.showInactiveTimeline()
        }
        else if(startRecordButtonEvent){
            startRecordButtonEvent = false
            recordButton.setRecording()
        }
        
        knob.activated = (!recordButton.isSelected || song.instrument.recorded)
    }
    
    func measureTimerHandler(){
        if(!song.playing){
            //print("meaasureTimeerHandler - not playing")
            //clearTimelineIfNeedsClear()
        return
        }

        let ready = song.updateMeasureTimeline()
        if(!ready){
            //print("meaasureTimeerHandler - not ready")
            //clearTimelineIfNeedsClear()
            return
        }
        
        let bar_progress = song.timeline.current_progress
        let measure_count = song.timeline.measure_count + 1
        let bar_num = song.timeline.bar_num
        let prev_bar_num = song.timeline.prev_bar_num
        
        let ready_to_clear = song.timeline.ready_to_clear
        if(ready_to_clear){
            clearTimelineProgress()
        }
        measureViews[bar_num].exists = true
        measureViews[bar_num].active = true
        measureViews[bar_num].updateMeasureProgress(progress_prcnt: CGFloat(bar_progress))
    
        
        let label_num_str = "\(measure_count)"
        if(label_num_str != measureLabels[bar_num].text){
            measureLabels[bar_num].text = label_num_str
        }

        if(prev_bar_num < bar_num || ((bar_num == 0) && (prev_bar_num > 0))){
            //fill in prev bar num to 100% just in case
            measureViews[prev_bar_num].updateMeasureProgress(progress_prcnt: CGFloat(1.0))
            measureViews[prev_bar_num].active = false
        }
        timeline_needs_clear = true //used when song is stopped, check if this is set and clear again
        
    }
    
    func clearTimelineProgress(){
        for measure_view in measureViews {
            measure_view.clearProgress()
        }
        
    }
    func showInactiveTimeline(){
        let count = song.instrument.loop.measures
        let recorded = song.instrument.recorded
        
        clearTimeline()
        if(!recorded){
            return
        }
        print("show active timeline count \(count)")
        
        for i in 0..<count {
            if(i >= measureViews.count){
                break
            }
            else{
                measureViews[i].exists = true
                let label_num_str = "\(i + 1)"
                if(label_num_str != measureLabels[i].text){
                    measureLabels[i].text = label_num_str
                }
            }
        }
    }
    
    func clearTimelineIfNeedsClear(){
        if(timeline_needs_clear){
            clearTimeline()
        }
    }
    
    func clearTimeline(){
        clearTimelineProgress()
        timeline_needs_clear = false
        
        for measure_view in measureViews {
            measure_view.active = false
            measure_view.exists = false
        }
        
        for label in measureLabels {
            label.text = ""
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override var prefersStatusBarHidden : Bool {
        return true
    }
    
    
    //MARK: Update Quantize Button from selected instrument state
    func updateQuantizeButtonsFromInstrument(){
         let resolution = song.instrument.quantizer.resolution
         let triplet_en = song.instrument.quantizer.triplet_en
         let quantize_en = song.instrument.quantize_enabled
     
        for button in quantizeButtons {
            if(button.resolution == resolution){
                button.on = quantize_en
            }
            else if(button.resolution != TripletResolution){
                button.on = false
            }
            if(button.resolution == TripletResolution){
                button.on = triplet_en
            }
        }
        
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
        
        /*
        print("Triplet Quantize is \(tripletQuantizeButton.isSelected)")
        if(tripletQuantizeButton.isSelected){
            resolution = resolution * tripletQuantizeButton.resolution //ex: if quarter not selected and triplet then resolution = 1*3
            print("resolution \(resolution)")
        }
        */
        print("updated quantize sel \(selected) res \(resolution)")
        song.updatePresetQuantize(enabled: selected, resolution: resolution, triplet_en: tripletQuantizeButton.isSelected)
        
        
    }
    
    
    //MARK: Hide position indicator
    func hidePositionIndicator(){
        parametersButton.show()
        positionIndicator.hide()
        instrumentViewWrap.backgroundColor = UIColor.clear
        
    }

    //MARK: stop record callback delegate
    func stopRecordFromSong(){
        stopRecordButtonEvent = true
    }
    
    func updateTimelineAfterDelete(){
        deleteTrackEvent = true
    }
    
    func startRecordFromSong(){
        startRecordButtonEvent = true
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
                showInactiveTimeline()
                recordButton.setStopped()
            }
        }
        else if(playRecordButton == recordButton){
            if(playButton.isSelected){
                recordButton.isSelected = !recordButton.isSelected
            }
            //record if on and is playing
            if(recordButton.isSelected && playButton.isSelected){
                song.record()
                recordButton.setPreroll()
                print("start record")
            }
            else{
                song.stop_record()
                recordButton.setStopped()
            }
        }
        
        
        
    }
    
    //MARK: Knob event handlers
    func knobAngleChanged(_ knobControl: KnobCtrl){
        
        let position = knob.detent
        let wasRecording = song.recordEnabled
        let newSelected = (prevKnobDetent != position)
        if(newSelected){
            parametersButton.hide()
            instrumentViewWrap.backgroundColor = UIColor.black
            positionIndicator.show()
            positionIndicator.setPosition(knobControl.detent)
        }
        prevKnobDetent = position
        if(newSelected){
            selectSound(position)
            if(!song.recordEnabled && wasRecording){
                recordButton.isSelected = false
            }
            else{
                updateButtonStatesAfterKnobTurn()
            }
            showInactiveTimeline()
            updateQuantizeButtonsFromInstrument()
            
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
        //song.selectInstrument(position)
        currentPosition = position
        song.selectInstrumentByAssignedPosition(position)
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
        //let orientation = UIDevice.current.orientation.rawValue
        
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
        
    }
    
    @IBAction func unwindToGroove(segue: UIStoryboardSegue) {}
    
    
}

