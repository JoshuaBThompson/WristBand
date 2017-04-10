//
//  ViewControllerCleanup.swift
//  Groover
//
//  Created by Joshua Thompson on 4/8/17.
//  Copyright © 2017 TCM. All rights reserved.
//

import UIKit

class ViewControllerCleanup: UIViewController {
    //MARK: Attributes
    
    //Quantize
    var quantizeButtonManager: QuantizeManager!
    var quantizeButtons: [QuantizeButtonProtocol]!
    
    //Song
    var song: Song!
    
    //Measure Timeline
    var measureTimelineManager: MeasureTimelineManager!
    var measureViews = [MeasureCtrl]()
    var measureLabels = [UILabel]()
    var measureTimelineTimer: Timer!
    
    //MARK: UI Elements
    
    //MARK: Computed Attributes
    
    //MARK: Init

    override func viewDidLoad() {
        super.viewDidLoad()
        
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

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: Functions
    
    //MARK: Song / instrument
    func initSong(){
        song = GlobalAttributes.song
    }
    
    //MARK: Knob handling
    
    func initKnobCtrl(){
        //Set knob value change callbacks
    }
    
    func handleKnobCenterPressed(){
        //If center of knob tapped then toggle click track
    }
    
    func handleKnobStarted(){
        //If knob starts to turn then show position indicator
        //showPositionIndicator()
        //parametersButton.hide()
    }
    
    func handleKnobPositionChange(){
        //Get new position number
        //Update instrument selected from position number
        /*
        let newPosition = knob.newDetent
        let wasRecording = song.recordEnabled
        if(newPosition){
            
            instrumentViewWrap.backgroundColor = UIColor.black
            positionIndicator.show()
            positionIndicator.setPosition(knobControl.detent)
            selectSound(knobControl.detent)
            if(!song.recordEnabled && wasRecording){
                recordButton.isSelected = false
            }
            else{
                updateButtonStatesAfterKnobTurn()
            }
            showInactiveTimeline()
            updateQuantizeButtonsFromInstrument()
            */
            
    }
    
    func handleKnobStopped(){
        //If knob stopped turning then hide position indicator
        hidePositionIndicator()
    }
    
    
    
    //MARK: Play/Record handling
    
    func initPlayRecordCtrl(){
        //Set Play button value change callbacks
        
        //Set Record button value change callbacks
    }
    
    func handlePlayButtonSelected(){
        //If play set then set song play
        
        //If not playing then stop record and stop song play
    }
    
    func handleRecordButtonSelected(){
        //If record set then set song record
        
        //If not record then stop song record
    }
    
    //MARK: Quantize handling
    func initQuantizeCtrls(){
        //Set quantize callbacks
        //quarterQuantizeButton.addTarget(self, action: #selector(ViewController.quantizeButtonSelected(_:)), for: .valueChanged)
        
        //Init manager and button array
        /*
         quarterQuantizeButton.addTarget(self, action: #selector(ViewController.handleQuantizeButtonSelected(_:)), for: .valueChanged)
         eighthQuantizeButton.addTarget(self, action: #selector(ViewController.handleQuantizeButtonSelected(_:)), for: .valueChanged)
         sixteenthQuantizeButton.addTarget(self, action: #selector(ViewController.handleQuantizeButtonSelected(_:)), for: .valueChanged)
         thirtysecondQuantizeButton.addTarget(self, action: #selector(ViewController.handleQuantizeButtonSelected(_:)), for: .valueChanged)
         tripletQuantizeButton.addTarget(self, action: #selector(ViewController.handleQuantizeButtonSelected(_:)), for: .valueChanged)
         quantizeButtons.append(quarterQuantizeButton)
         quantizeButtons.append(eighthQuantizeButton)
         quantizeButtons.append(sixteenthQuantizeButton)
         quantizeButtons.append(thirtysecondQuantizeButton)
         quantizeButtons.append(tripletQuantizeButton)
        */
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
    
    //MARK: Timeline handling
    
    func initMeasureTimeline(){
        //put measure views in array
        /*
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
        */
        
        //updates measure view and label states based on current instrument and measure progress
        measureTimelineManager = MeasureTimelineManager(measure_views: measureViews, measure_labels: measureLabels)
        
        //setup timer thread to update timeline graphics
        startMeasureTimelineThread()
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
            measureTimelineManager.updateMeasureTimeline()
        }
    }
    
    //MARK: Position indicator handling
    func initPositionIndicator(){
        hidePositionIndicator()
    }
    
    func hidePositionIndicator(){
        
        
    }
    
    func showPositionIndicator(){
        
    }
    
    //MARK: Beat detection handling
    

}
