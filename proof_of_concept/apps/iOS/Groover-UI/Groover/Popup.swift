//
//  popup.swift
//  Groover
//
//  Created by Alex Crane on 6/27/16.
//  Copyright © 2016 TCM. All rights reserved.
//

import UIKit



@IBDesignable
class Popup: UIView {
    //MARK: temp and time signature attributes
    var tempo = 60.0 //bpm (beats per minute)
    var timeSigNote = 4
    var timeSigBeats = 4 //time signature = timeSigBeats / timeSigNote --- example: 4 / 4 time signature
    
    //MARK: buttons / subviews
    var buttons = [UIButton]()
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
    
    override func drawRect(rect: CGRect) {
        //TODO: ?
    }
    
    func addButton(button: UIButton){
        //button.addTarget(self, action: #selector(PlayRecordControl.playRecordButtonTapped(_:)), forControlEvents: .TouchDown)
        buttons += [button]
        addSubview(button)
    }
    
    
    func addSubviews(){
        tempoLabel = UILabel()
        updateTempoString()
        timeSigLabel = UILabel()
        updateTimeSigString()
        addSubview(tempoLabel)
        addSubview(timeSigLabel)
        popupBlurView = PopupBlur()
        popupBlurView.updateState()
        addSubview(popupBlurView)
        
        //upper buttons
        upperLeftButton = Left()
        addButton(upperLeftButton)
        upperLeftButton.updateState()
        
        upperRightButton = Right()
        addButton(upperRightButton)
        upperRightButton.updateState()
        
        //lower buttons
        lowerLeftButton = Left()
        addButton(lowerLeftButton)
        lowerLeftButton.updateState()
        
        lowerRightButton = Right()
        addButton(lowerRightButton)
        lowerRightButton.updateState()
        
        
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
        tempoLabel.textColor = UIColor.whiteColor()
        tempoLabel.textAlignment = .Center
        timeSigLabel.frame = timeSigLabelFrame
        timeSigLabel.textColor = UIColor.whiteColor()
        timeSigLabel.textAlignment = .Center
        
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
        popupBlurView.backgroundColor = UIColor.clearColor()
        popupBlurView.updateState()
    }
    
    
    //MARK: Hide popup function
    func toggleHide(){
        hidden = !hidden //toggle true / false
        updateButtonStates()
    }
    
    func hide(){
        hidden = true
        updateButtonStates()
    }
    
    func show(){
        hidden = false
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

    
    
}
