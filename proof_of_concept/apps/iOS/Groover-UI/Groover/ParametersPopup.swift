//
//  ParametersPopup.swift
//  Groover
//
//  Created by Alex Crane on 7/19/16.
//  Copyright © 2016 TCM. All rights reserved.
//

import UIKit

//@IBDesignable
class ParametersPopup: UIControl {
    var clearButton: ParameterOptionsButton!
    var soloButton: ParameterOptionsButton!
    var muteButton: ParameterOptionsButton!
    var measureRightButton: ParameterOptionsButton!
    var measureLeftButton: ParameterOptionsButton!
    var measures = 0
    var measureTitleLabel: UILabel!
    var measureLabel: UILabel!
    var selectedButton: ParameterOptionsButton!
    var buttons = [ParameterOptionsButton]()
    
    override func drawRect(rect: CGRect) {
        UIGroover.drawParametersPopupCanvas()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initView()
    }
    
    func initView(){
        hidden = true
        addSubviews()
    }
    
    //MARK: add button views and buttons
    
    func addButton(button: ParameterOptionsButton){
        buttons.append(button)
        button.addTarget(self, action: #selector(ParametersPopup.buttonTapped(_:)), forControlEvents: .TouchDown)
        addSubview(button)
    }
    
    func addSubviews(){
        //Measure buttons
        measureLabel = UILabel()
        measureTitleLabel = UILabel()
        addSubview(measureLabel)
        addSubview(measureTitleLabel)
        measureLeftButton = ParametersMeasureLeft()
        measureLeftButton.type = .MEASURE_LEFT
        measureLeftButton.addTarget(self, action: #selector(ParametersPopup.measureLeftButtonTapped), forControlEvents: .TouchDown)
        addButton(measureLeftButton)
        
        measureRightButton = ParametersMeasureRight()
        measureRightButton.type = .MEASURE_RIGHT
        measureRightButton.addTarget(self, action: #selector(ParametersPopup.measureRightButtonTapped), forControlEvents: .TouchDown)
        addButton(measureRightButton)
        
        //Clear button
        clearButton = ParameterOptionsButton()
        clearButton.type = .CLEAR
        addButton(clearButton)
        
        //Solo button
        soloButton = ParameterOptionsButton()
        soloButton.type = .SOLO
        addButton(soloButton)
        
        //Mute button
        muteButton = ParameterOptionsButton()
        muteButton.type = .MUTE
        addButton(muteButton)
        
    }
    
    //MARK: override standard swift subview layout method to position buttons correctl in view
    override func layoutSubviews() {
        // Set the button's width and height to a square the size of the frame's height.
        var buttonFrame = CGRect(x: 225, y: 20, width: 60, height: 60)
        
        //set measure button layout
        var measureButtonFrame = CGRect(x: 44, y: 44, width: 50, height: 50)
        var measureLabelFrame = CGRect(x: 110, y: 100, width: 100, height: 40)
        
        //measure count label
        measureLabel.frame = measureLabelFrame
        measureLabel.textColor = UIColor.whiteColor()
        measureLabel.textAlignment = .Center
        measureLabel.text = String(format: "1")
        
        //meausure title label
        measureLabelFrame.origin.y = 150
        measureTitleLabel.frame = measureLabelFrame
        measureTitleLabel.textColor = UIColor.whiteColor()
        measureTitleLabel.textAlignment = .Center
        measureTitleLabel.text = String(format: "MEASURES")
        
        //measure buttons
        measureButtonFrame.origin.x = CGFloat(44)
        measureButtonFrame.origin.y = CGFloat(124)
        measureLeftButton.frame = measureButtonFrame
        
        measureButtonFrame.origin.x = CGFloat(260)
        measureButtonFrame.origin.y = CGFloat(124)
        measureRightButton.frame = measureButtonFrame
        
        //set clear button position and text
        clearButton.frame = buttonFrame
        clearButton.setTitle("CLEAR", forState: .Normal)
        
        //set solo button position and text
        buttonFrame.origin.x = 100
        soloButton.frame = buttonFrame
        soloButton.setTitle("SOLO", forState: .Normal)
        
        //set mute button position and text
        buttonFrame.origin.x = 20
        muteButton.frame = buttonFrame
        muteButton.setTitle("MUTE", forState: .Normal)
    }
    
    //MARK: button tapped handlers
    func buttonTapped(button: ParameterOptionsButton){
        selectedButton = button
        updateButtonSelectionStates()
        sendActionsForControlEvents(.ValueChanged) //this tells view controller that something changed
    }
    
    //MARK: update button states / visuals after taped 
    func updateButtonSelectionStates() {
        var num = ParametersButtonTypes.CLEAR
        num = selectedButton.type
        
        var changed = false
        switch num {
        case .CLEAR:
            clearButton.selected = !clearButton.selected
            changed = true
            print("clear selected")
            
        case .SOLO:
            soloButton.selected = !soloButton.selected
            changed = true
            print("solo selected")
            
        case .MUTE:
            muteButton.selected = !muteButton.selected
            changed = true
            print("mute sselected")
        case .MEASURE_LEFT:
            measureLeftButton.selected = !measureLeftButton.selected
            changed = true
            print("measure left selected")
        
        case .MEASURE_RIGHT:
            measureRightButton.selected = !measureRightButton.selected
            changed = true
            print("measure right selected")
        }
        
        if(changed){
            for (_, button) in buttons.enumerate(){
                button.on = button.selected
            }
        }
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
    }
    
    //MARK: update measure count functions
    func updateMeasureString(){
        measureLabel.text = String(format: "\(measures)")
    }
    
    
    //MARK: increment / decrement measure count functions
    func incMeasure(){
        measures += 1
    }
    
    func decMeasure(){
        measures -= 1
        //don't let measure count get below 1
        if(measures < 1){
            measures = 1
        }
    }
    
    
    //MARK: measure arrow tapped functions
    func measureLeftButtonTapped(){
        print("measure left button tapped")
        decMeasure()
        updateMeasureString()
        selectedButton = measureLeftButton
        sendActionsForControlEvents(.ValueChanged) //this tells view controller that something changed
        
    }
    
    func measureRightButtonTapped(){
        print("measure right button tapped")
        incMeasure()
        updateMeasureString()
        selectedButton = measureRightButton
        sendActionsForControlEvents(.ValueChanged) //this tells view controller that something changed
    }
    
    
}
