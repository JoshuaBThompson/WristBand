//
//  popup.swift
//  Groover
//
//  Created by Alex Crane on 6/27/16.
//  Copyright © 2016 TCM. All rights reserved.
//

import UIKit



@IBDesignable
class Popup: UIControl {
    //MARK: temp and time signature attributes
    var tempo = 60.0 //bpm (beats per minute)
    var timeSigNote = 4
    var timeSigBeats = 4 //time signature = timeSigBeats / timeSigNote --- example: 4 / 4 time signature
    
    //MARK: buttons / subviews
    var buttons = [PopupButton]()
    var currentButton: PopupButton!
    var upperLeftButton: Left!
    var lowerLeftButton: Left!
    var upperRightButton: Right!
    var lowerRightButton: Right!
    var popupBlurView: PopupBlur!
    var tempoLabel: UILabel!
    var timeSigLabel: UILabel!
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initView()
    }
    
    func initView(){
        addSubviews()
        hide()
    }
    
    override func draw(_ rect: CGRect) {
        //TODO: ?
    }
    
    func addButton(_ button: PopupButton){
        //button.addTarget(self, action: #selector(PlayRecordControl.playRecordButtonTapped(_:)), forControlEvents: .TouchDown)
        buttons += [button]
        addSubview(button)
    }
    
    
    func addSubviews(){
        
        //popup blur
        popupBlurView = PopupBlur()
        popupBlurView.updateState()
        addSubview(popupBlurView)
        
        //upper buttons
        upperLeftButton = Left()
        upperLeftButton.type = .upper_LEFT
        upperLeftButton.addTarget(self, action: #selector(Popup.upperLeftButtonTapped), for: .touchDown)
        addButton(upperLeftButton)
        upperLeftButton.updateState()
        
        upperRightButton = Right()
        upperRightButton.type = .upper_RIGHT
        upperRightButton.addTarget(self, action: #selector(Popup.upperRightButtonTapped), for: .touchDown)
        addButton(upperRightButton)
        upperRightButton.updateState()
        
        //lower buttons
        lowerLeftButton = Left()
        lowerLeftButton.type = .lower_LEFT
        lowerLeftButton.addTarget(self, action: #selector(Popup.lowerLeftButtonTapped), for: .touchDown)
        addButton(lowerLeftButton)
        lowerLeftButton.updateState()
        
        lowerRightButton = Right()
        lowerRightButton.type = .lower_RIGHT
        lowerRightButton.addTarget(self, action: #selector(Popup.lowerRightButtonTapped), for: .touchDown)
        addButton(lowerRightButton)
        lowerRightButton.updateState()
        
        //temp and time signature labels
        tempoLabel = UILabel()
        updateTempoString()
        timeSigLabel = UILabel()
        updateTimeSigString()
        addSubview(tempoLabel)
        addSubview(timeSigLabel)
        
        //button.adjustsImageWhenHighlighted = false
    }
    
    override func layoutSubviews() {
        // Set the button's width and height to a square the size of the frame's height.
        let buttonSize = 50
        var buttonFrame = CGRect(x: 44, y: 44, width: buttonSize, height: buttonSize)
        let tempoLabelFrame = CGRect(x: 100, y: 100, width: 100, height: 50)
        let timeSigLabelFrame = CGRect(x: 100, y: 225, width: 100, height: 50)
        
        //labels
        tempoLabel.frame = tempoLabelFrame
        tempoLabel.textColor = UIColor.white
        tempoLabel.textAlignment = .center
        timeSigLabel.frame = timeSigLabelFrame
        timeSigLabel.textColor = UIColor.white
        timeSigLabel.textAlignment = .center
        
        //upper buttons
        buttonFrame.origin.x = CGFloat(34)
        buttonFrame.origin.y = CGFloat(124)
        upperLeftButton.frame = buttonFrame
        upperLeftButton.updateState()
        
        buttonFrame.origin.x = CGFloat(250)
        buttonFrame.origin.y = CGFloat(124)
        upperRightButton.frame = buttonFrame
        upperRightButton.updateState()
        
        
        //lower buttons
        buttonFrame.origin.x = CGFloat(34)
        buttonFrame.origin.y = CGFloat(250)
        lowerLeftButton.frame = buttonFrame
        lowerLeftButton.updateState()
        
        buttonFrame.origin.x = CGFloat(250)
        buttonFrame.origin.y = CGFloat(250)
        lowerRightButton.frame = buttonFrame
        lowerRightButton.updateState()
        
        
        let popupFrame = CGRect(x: 0, y: 0, width: frame.width, height: frame.height)//frame
        popupBlurView.frame = popupFrame
        popupBlurView.backgroundColor = UIColor.clear
        popupBlurView.updateState()
    }
    
    
    //MARK: Hide popup function
    func toggleHide(){
        isHidden = !isHidden //toggle true / false
        updateButtonStates()
    }
    
    func hide(){
        isHidden = true
        updateButtonStates()
    }
    
    func show(){
        isHidden = false
    }
    
    //MARK: Update buttons
    
    func updateButtonStates(){
        //TODO: ?
    }
    
    //MARK: Tempo generate text from tempo attribute
    func updateTempoString(){
        tempoLabel.text = String(format: "\(tempo) bpm")
    }
    
    //MARK: Time signature generate text from timeSigNote and timeSigBeats attributes
    func updateTimeSigString(){
        timeSigLabel.text = String(format: "\(timeSigBeats) / \(timeSigNote)")
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
    
    //MARK: upper buttons tapped functions
    func upperLeftButtonTapped(){
        print("upper left button tapped")
        decTempo()
        updateTempoString()
        currentButton = upperLeftButton
        sendActions(for: .valueChanged) //this tells view controller that something changed
        
    }
    
    func upperRightButtonTapped(){
        print("upper right button tapped")
        incTempo()
        updateTempoString()
        currentButton = upperRightButton
        sendActions(for: .valueChanged) //this tells view controller that something changed
    }
    
    //MARK: lower buttons tapped functions
    func lowerLeftButtonTapped(){
        print("lower left button tapped")
        decTimeSignature()
        updateTimeSigString()
        currentButton = lowerLeftButton
        sendActions(for: .valueChanged) //this tells view controller that something changed
    }
    
    func lowerRightButtonTapped(){
        print("lower right button tapped")
        incTimeSignature()
        updateTimeSigString()
        currentButton = lowerRightButton
        sendActions(for: .valueChanged) //this tells view controller that something changed
    }

    
    
}
