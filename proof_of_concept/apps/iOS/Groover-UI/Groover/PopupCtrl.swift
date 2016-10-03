//
//  PopupCtrl.swift
//  Groover
//
//  Created by Joshua Thompson on 10/1/16.
//  Copyright © 2016 TCM. All rights reserved.
//

import UIKit

//
//  ParametersPopupCtrl.swift
//  Groover
//
//  Created by Joshua Thompson on 9/28/16.
//  Copyright © 2016 TCM. All rights reserved.
//

import UIKit

enum SettingsButtonTypes {
    case TEMPO_LEFT
    case TEMPO_RIGHT
    case TIMESIG_LEFT
    case TIMESIG_RIGHT
}

typealias SettingsButtonTypes_t = SettingsButtonTypes

protocol SettingsHandlerDelegate: class {
    // Right button pressed
    func tempoRightButtonTapped()
    
    // Left button pressed
    func tempoLeftButtonTapped()
    
    // Time sig left button pressed
    func timesigLeftButtonTapped()
    
    // Time sig right button pressed
    func timesigRightButtonTapped()
    
}

class TempoRightButton: Right {
    weak var delegate: SettingsHandlerDelegate?
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        isSelected = !isSelected
        delegate?.tempoRightButtonTapped()
    }
}

class TempoLeftButton: Left {
    weak var delegate: SettingsHandlerDelegate?
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        isSelected = !isSelected
        delegate?.tempoLeftButtonTapped()
    }
}

class TimeSigRightButton: Right {
    weak var delegate: SettingsHandlerDelegate?
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        isSelected = !isSelected
        delegate?.timesigRightButtonTapped()
    }
}

class TimeSigLeftButton: Left {
    weak var delegate: SettingsHandlerDelegate?
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        isSelected = !isSelected
        delegate?.timesigLeftButtonTapped()
    }
}


@IBDesignable
class PopupCtrl: Popup, SettingsHandlerDelegate {
    //MARK: temp and time signature attributes
    var tempo = 60.0 //bpm (beats per minute)
    var timeSigNote = 4
    var timeSigBeats = 4 //time signature = timeSigBeats / timeSigNote --- example: 4 / 4 time signature
    
    var tempoLeftButton: TempoLeftButton!
    var tempoRightButton: TempoRightButton!
    var timesigLeftButton: TimeSigLeftButton!
    var timesigRightButton: TimeSigRightButton!
    var tempoLabel: UILabel!
    var timesigLabel: UILabel!
    var buttonTypeSelected = SettingsButtonTypes_t.TEMPO_LEFT
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initView()
    }
    
    func initView(){
        isHidden = true
    }
    
    func initButtonsAndLabels(tempoRightButtonRef: TempoRightButton, tempoLeftButtonRef: TempoLeftButton, timesigRightButtonRef: TimeSigRightButton, timesigLeftButtonRef: TimeSigLeftButton, tempoLabelRef: UILabel, timesigLabelRef: UILabel){
        
        tempoLeftButton = tempoLeftButtonRef
        tempoLeftButton.delegate = self
        tempoRightButton = tempoRightButtonRef
        tempoRightButton.delegate = self
        
        timesigLeftButton = timesigLeftButtonRef
        timesigLeftButton.delegate = self
        timesigRightButton = timesigRightButtonRef
        timesigRightButton.delegate = self
        
        tempoLabel = tempoLabelRef        
        timesigLabel = timesigLabelRef
    }
    
    
    
    //MARK: Hide popup function
    func toggleHide(){
        if(isHidden){
            isHidden = false //toggle true / false
        }
        else{
            isHidden = true
        }
    }
    
    func hide(){
        isHidden = true
        tempoLeftButton.isHidden = true
        tempoRightButton.isHidden = true
        
        timesigLeftButton.isHidden = true
        timesigRightButton.isHidden = true
        
        tempoLabel.isHidden = true
        timesigLabel.isHidden = true
    }
    
    func show(){
        isHidden = false
        tempoLeftButton.isHidden = false
        tempoRightButton.isHidden = false
        
        timesigLeftButton.isHidden = false
        timesigRightButton.isHidden = false
        
        tempoLabel.isHidden = false        
        timesigLabel.isHidden = false
    }
    
    
    //MARK: Tempo generate text from tempo attribute
    func updateTempoString(){
        let tempoText = Int(tempo)
        tempoLabel.text = String(format: "\(tempoText) BPM")
    }
    
    //MARK: Time signature generate text from timeSigNote and timeSigBeats attributes
    func updateTimeSigString(){
        timesigLabel.text = String(format: "\(timeSigBeats) / \(timeSigNote)")
    }
    
    //MARK: increment / decrement tempo functions
    func incTempo(){
        tempo += 1
    }
    
    func decTempo(){
        tempo -= 1
        //don't let tempo get below 1 bpm
        if(tempo < 1){
            tempo = 1
        }
    }
    
    //MARK: increment / decrement time signature option
    func incTimeSignature(){
        //ex: timeSigNote = 5 then timeSigBeats = 5 so you get 5 / 5
        timeSigNote += 1
        timeSigBeats = timeSigNote
        
    }
    
    func decTimeSignature(){
        //ex: timeSigNote = 5 then timeSigBeats = 5 so you get 5 / 5
        timeSigNote -= 1
        //don't let time signature decrease passed 1 / 1
        if(timeSigNote < 1){
            timeSigNote = 1
        }
        timeSigBeats = timeSigNote
        
    }

    
    
    //MARK: time signature change callbacks
    func tempoLeftButtonTapped(){
        print("tempo left button tapped")
        decTempo()
        updateTempoString()
        buttonTypeSelected = .TEMPO_LEFT
        sendActions(for: .valueChanged) //this tells view controller that something changed
        
    }
    
    func tempoRightButtonTapped(){
        print("tempo right button tapped")
        incTempo()
        updateTempoString()
        buttonTypeSelected = .TEMPO_RIGHT
        sendActions(for: .valueChanged) //this tells view controller that something changed
        
    }
    
    func timesigLeftButtonTapped(){
        print("time signature left button tapped")
        buttonTypeSelected = .TIMESIG_LEFT
        sendActions(for: .valueChanged) //this tells view controller that something changed
        
    }
    
    
    func timesigRightButtonTapped(){
        print("time signature right button tapped")
        buttonTypeSelected = .TIMESIG_RIGHT
        sendActions(for: .valueChanged) //this tells view controller that something changed
        
    }
    
}
