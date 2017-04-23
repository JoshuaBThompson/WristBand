
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
    //MARK: Properties
    
    //MARK: Quantize
    var quantizeButtons = [QuantizeButtonProtocol]()
    var quantizeButtonManager: QuantizeManager!
    
    //MARK: Song / instruments
    var song: Song!
    var selectedSong = String()
    
    //MARK: Beat detection
    let motionManager = CMMotionManager()
    let queue = OperationQueue.main
    var timeIntervalMillis: UInt = 12 //25
    var beatDetected = false
    var beatDetectedCount = 0
    var riseNum: Int = 0
    var fallNum: Int = 0
    var risingBeatFilter = RisingBeatFilter()
    var fallingBeatFilter = FallingBeatFilter()
    
    //MARK: Knob
    var currentPosition = 0
    
    //MARK: Timeline
    var measureViews = [MeasureCtrl]()
    var measureLabels = [UILabel]()
    var measureTimelineTimer: Timer!
    var measureTimelineManager: MeasureTimelineManager!
    
    //MARK: Events
    var eventTimer: Timer!
    var stop_record_button_event = false
    var start_record_button_event = false
    var delete_track_event = false
    var measure_update_event = false
    var events_started = false
    
    
    //MARK: Timeline UI
    @IBOutlet weak var measureView1: MeasureCtrl!
    @IBOutlet weak var measureView2: MeasureCtrl!
    @IBOutlet weak var measureView3: MeasureCtrl!
    @IBOutlet weak var measureView4: MeasureCtrl!
    
    @IBOutlet weak var measureView1Label: UILabel!
    @IBOutlet weak var measureView2Label: UILabel!
    @IBOutlet weak var measureView4Label: UILabel!
    @IBOutlet weak var measureView3Label: UILabel!
    
    //MARK: Instrument position indicator UI
    @IBOutlet weak var positionIndicator: PositionIndicator!
    @IBOutlet weak var instrumentViewWrap: UIView!
    @IBOutlet weak var instrumentNameLabel: UILabel!
    
    //MARK: Knob UI
    @IBOutlet weak var knob: KnobCtrl!
    
    //MARK: Parameters UI
    @IBOutlet weak var parametersButton: ParametersButtonCtrl!

    //MARK: Play / Record UI
    @IBOutlet weak var playButton: PlayCtrl!
    @IBOutlet weak var recordButton: RecordCtrl!
    
    //MARK: Quantize UI
    @IBOutlet weak var quarterQuantizeButton: QuarterCtrl!
    @IBOutlet weak var eighthQuantizeButton: EighthCtrl!
    @IBOutlet weak var sixteenthQuantizeButton: SixteenthCtrl!
    @IBOutlet weak var thirtysecondQuantizeButton: ThirtysecondCtrl!
    @IBOutlet weak var tripletQuantizeButton: TripletCtrl!
    
    //MARK: Functions
    
    //MARK: load view
    override func viewDidLoad() {
        super.viewDidLoad()
        
        GlobalAttributes.viewController = self
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage =  UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        
        //Song
        initSong()
        
        //Knob
        initKnobCtrl()
        
        //Quantize
        initQuantizeCtrls()
        
        //Play / Record
        initPlayRecordCtrl()
        
        //Position Indicator
        initPositionIndicator()
        
        //Timeline
        initMeasureTimeline()
        
        //Motion / beat filter
        initBeatFilter()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if(song.instruments.count > 0){
            selectSound(currentPosition)
            instrumentNameLabel.text = song.selectedInstrumentName
        }
        if(!events_started){
            //only call these once
            startMeasureTimelineThread()
            startEventHandler()
            events_started = true
        }
    }
    
    //MARK: Beat filter
    func initBeatFilter(){
        //init motion events handler
        motionManager.startAccelerometerUpdates()
        if motionManager.isAccelerometerAvailable {
            motionManager.accelerometerUpdateInterval = TimeInterval(Double(timeIntervalMillis)/1000.0)
            motionManager.startAccelerometerUpdates(to: queue, withHandler: beatHandler)
        }
    }
    
    func beatHandler(_ data: CMAccelerometerData?, error: Error?){
        
        let valx_f: Double = (data!.acceleration.x)*100.0
        let valx = Int16(valx_f)
        
        if fallingBeatFilter.isBeat(x: valx){
            fallNum += 1
            if(fallNum >= 2 || (riseNum == 0)){
                song.addNote() //make drum sound and add to track if recording!
                knob.updateClickRingActive(active: true)
                beatDetected = true
                riseNum = 0
            }
        }
            
        else if risingBeatFilter.isBeat(x: valx) {
            riseNum += 1
            if(riseNum >= 2 || (fallNum == 0)){
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
    
    
    
    //MARK: Song / instrument
    func initSong(){
        song = GlobalAttributes.song
        song.delegate = self
        song.start()
        song.toggleClickTrackMute()
    }
    
    
    //MARK: Quantize handling
    func initQuantizeCtrls(){
        
        //init callbacks
        quarterQuantizeButton.addTarget(self, action: #selector(ViewController.handleQuatizeButtonSelected(_:)), for: .valueChanged)
        eighthQuantizeButton.addTarget(self, action: #selector(ViewController.handleQuatizeButtonSelected(_:)), for: .valueChanged)
        sixteenthQuantizeButton.addTarget(self, action: #selector(ViewController.handleQuatizeButtonSelected(_:)), for: .valueChanged)
        thirtysecondQuantizeButton.addTarget(self, action: #selector(ViewController.handleQuatizeButtonSelected(_:)), for: .valueChanged)
        tripletQuantizeButton.addTarget(self, action: #selector(ViewController.handleQuatizeButtonSelected(_:)), for: .
        valueChanged)

        //Init manager and button array
        quantizeButtons.append(quarterQuantizeButton)
        quantizeButtons.append(eighthQuantizeButton)
        quantizeButtons.append(sixteenthQuantizeButton)
        quantizeButtons.append(thirtysecondQuantizeButton)
        quantizeButtons.append(tripletQuantizeButton)

        quantizeButtonManager = QuantizeManager(quantize_buttons_list: quantizeButtons)
    }
    
    func handleQuatizeButtonSelected(_ quantizeButton: QuantizeButtonProtocol){
        
        //process quantize button event and update resolution and active state
        quantizeButtonManager.processQuantizeEvent(quantizeButton: quantizeButton)
        
        let quantize_active = quantizeButtonManager.active
        let quantize_resolution = quantizeButtonManager.resolution
        let triplet_en = quantizeButtonManager.tripletActive
        
        //now update current instrument quantize state
        song.updatePresetQuantize(enabled: quantize_active, resolution: quantize_resolution, triplet_en: triplet_en)
        
    }
    
    //MARK: Play/Record handling
    func initPlayRecordCtrl(){
        //Set Play button value change callbacks
        playButton.addTarget(self, action: #selector(ViewController.handlePlayButtonSelected), for: .valueChanged)
        
        //Set Record button value change callbacks
        recordButton.addTarget(self, action: #selector(ViewController.handleRecordButtonSelected), for: .valueChanged)
    }
    
    func handlePlayButtonSelected(){
        
        playButton.isSelected = !playButton.isSelected
        if(playButton.isSelected){
            //If play set then set song play
            song.stop() //disable recording first
            song.play()
        }
        else{
            //If not playing then stop record and stop song play
            song.stop_record()
            song.stop()
            recordButton.isSelected = false //toggle record button
            self.measureTimelineManager.showInactive()
            recordButton.setStopped()
        }
    }
    
    func handleRecordButtonSelected(){
        if(playButton.isSelected){
            //If record set then set song record
            recordButton.isSelected = !recordButton.isSelected
        }
        //record if on and is playing
        if(recordButton.isSelected && playButton.isSelected){
            song.record()
            recordButton.setPreroll()
        }
        else{
            song.stop_record()
            recordButton.setStopped()
        }
    }
    
    //MARK: Position indicator handling
    func initPositionIndicator(){
        hidePositionIndicator()
    }
    
    func hidePositionIndicator(){
        
         parametersButton.show()
         positionIndicator.hide()
         instrumentViewWrap.backgroundColor = UIColor.clear
    }
    
    func showPositionIndicator(){
         parametersButton.hide()
         positionIndicator.show()
         instrumentViewWrap.backgroundColor = UIColor.black
    }
    
    //MARK: Timeline handling
    
    func initMeasureTimeline(){
        //put measure views in array
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
        
        //updates measure view and label states based on current instrument and measure progress
        measureTimelineManager = MeasureTimelineManager(measure_views: measureViews, measure_labels: measureLabels)
    }
    
    //continuously checks to see what % of the current instrument measure count has elapsed
    //used to update the groover measure timeline bar progress
    func startMeasureTimelineThread(){
        measureTimelineTimer = Timer.scheduledTimer(timeInterval: 0.05, target: self, selector: #selector(measureTimelineHandler), userInfo: nil, repeats: true)
        
    }
    
    func measureTimelineHandler(){
        //check if timeline update should be updated or note
        let is_ready = measureTimelineManager.isReadyForUpdate()
        if(is_ready){
            measureTimelineManager.updateViews()
        }
    }
    
    //MARK: Events handling
    func startEventHandler(){
        eventTimer = Timer.scheduledTimer(timeInterval: 0.25, target: self, selector: #selector(eventHandler), userInfo: nil, repeats: true)
    }
    
    func eventHandler(){
        if(stop_record_button_event){
            stop_record_button_event = false
            recordButton.setStopped()
            self.recordButton.isSelected = false
        }
        else if(delete_track_event){
            delete_track_event = false
            self.measureTimelineManager.showInactive()
        }
        else if(start_record_button_event){
            start_record_button_event = false
            recordButton.setRecording()
        }
        else if(measure_update_event){
            if(!song.playing){
                self.measureTimelineManager.showInactive()
            }
            measure_update_event = false
        }
        
        knob.activated = (!recordButton.isSelected || song.instrument.recorded) && (!song.instrument.recording)
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
    

    //MARK: stop record callback delegate
    func stopRecordFromSong(){
        stop_record_button_event = true
    }
    
    func updateTimelineAfterDelete(){
        delete_track_event = true
    }
    
    func startRecordFromSong(){
        start_record_button_event = true
    }
    
    func updateMeasureCount(){
        measure_update_event = true
    }
    
    
    //MARK: Knob handling
    func initKnobCtrl(){
        //Set knob value change callbacks
        knob.addTarget(self, action: #selector(ViewController.handleKnobPositionChange(_:)), for: .valueChanged)
        knob.addTarget(self, action: #selector(ViewController.handleKnobCenterPressed(_:)), for: .editingChanged)
        knob.addTarget(self, action: #selector(ViewController.handleKnobStarted), for: .editingDidBegin)
        knob.addTarget(self, action: #selector(ViewController.handleKnobStopped), for: .editingDidEnd)
    }
    
    
    func handleKnobPositionChange(_ knobControl: KnobCtrl){
        let newPosition = knob.newDetent
        if(!newPosition){
            return
        }
        
        let wasRecording = song.recordEnabled
        positionIndicator.setPosition(knobControl.detent)
        selectSound(knobControl.detent)
        
        if(!song.recordEnabled && wasRecording){
            recordButton.isSelected = false
        }
        
        self.measureTimelineManager.showInactive()
        
        updateQuantizeButtonsFromInstrument()
    }
    
    func selectSound(_ position: Int){
        currentPosition = position
        song.selectInstrumentByAssignedPosition(position)
        instrumentNameLabel.text = song.selectedInstrumentName
    }
    
    func handleKnobCenterPressed(_ knobControl: Knob){
        song.toggleClickTrackMute()
        
        //temporary hack when not using iPhone (using simulator) to allow for beat generation
        song.addNote() //Used for testing in sim mode to simulate motion generated beat
        knob.updateClickRingActive(active: true)
        beatDetected = true
    }
    
    func handleKnobStopped(){
        //If knob stopped turning then hide position indicator
        hidePositionIndicator()
    }
    
    func handleKnobStarted(){
        //If knob starts to turn then show position indicator
        showPositionIndicator()
    }
    
    //MARK: Segue to next view
    @IBAction func unwindToGroove(segue: UIStoryboardSegue) {}
    
    
}

