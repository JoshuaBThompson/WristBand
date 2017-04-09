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
    
    
    //MARK: UI Elements
    
    //MARK: Computed Attributes
    
    //MARK: Init

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Song
        initSong()
        
        //Quantize
        initQuantizeCtrls()
        

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
        hidePositionIndicator()
    }
    
    func handleKnobPositionChange(){
        //Get new position number
        //Update instrument selected from position number
    }
    
    func handleKnobStopped(){
        //If knob stopped turning then hide position indicator
        showPositionIndicator()
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
    
    //MARK: Track parameters handling
    
    //MARK: Song Settings handling
    
    //MARK: Sound Library handling
    
    //MARK: Timeline handling
    
    //MARK: Position indicator handling
    
    func hidePositionIndicator(){
        
        
    }
    
    func showPositionIndicator(){
        
    }
    
    //MARK: Beat detection handling
    

}
