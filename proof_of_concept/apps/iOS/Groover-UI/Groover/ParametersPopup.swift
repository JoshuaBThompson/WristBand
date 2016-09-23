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
    var measures = 1
    var measuresUpdated = false
    var measureTitleLabel: UILabel!
    var measureLabel: UILabel!
    var selectedButton: ParameterOptionsButton!
    var buttons = [ParameterOptionsButton]()
    
    override func draw(_ rect: CGRect) {
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
        isHidden = true
        addSubviews()
    }
    
    //MARK: add button views and buttons
    
    func addButton(_ button: ParameterOptionsButton){
        buttons.append(button)
        button.addTarget(self, action: #selector(ParametersPopup.buttonTapped(_:)), for: .touchDown)
        addSubview(button)
    }
    
    func addSubviews(){
        //Measure buttons
        measureLabel = UILabel()
        measureTitleLabel = UILabel()
        addSubview(measureLabel)
        addSubview(measureTitleLabel)
        measureLeftButton = ParametersMeasureLeft()
        measureLeftButton.type = .measure_LEFT
        measureLeftButton.addTarget(self, action: #selector(ParametersPopup.measureLeftButtonTapped), for: .touchDown)
        addButton(measureLeftButton)
        
        measureRightButton = ParametersMeasureRight()
        measureRightButton.type = .measure_RIGHT
        measureRightButton.addTarget(self, action: #selector(ParametersPopup.measureRightButtonTapped), for: .touchDown)
        addButton(measureRightButton)
        
        //Clear button
        clearButton = ParameterOptionsButton()
        clearButton.type = .clear
        addButton(clearButton)
        
        //Solo button
        soloButton = ParameterOptionsButton()
        soloButton.type = .solo
        addButton(soloButton)
        
        //Mute button
        muteButton = ParameterOptionsButton()
        muteButton.type = .mute
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
        measureLabel.textColor = UIColor.white
        measureLabel.textAlignment = .center
        measureLabel.text = String(format: "1")
        
        //meausure title label
        measureLabelFrame.origin.y = 150
        measureTitleLabel.frame = measureLabelFrame
        measureTitleLabel.textColor = UIColor.white
        measureTitleLabel.textAlignment = .center
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
        clearButton.setTitle("CLEAR", for: UIControlState())
        
        //set solo button position and text
        buttonFrame.origin.x = 100
        soloButton.frame = buttonFrame
        soloButton.setTitle("SOLO", for: UIControlState())
        
        //set mute button position and text
        buttonFrame.origin.x = 20
        muteButton.frame = buttonFrame
        muteButton.setTitle("MUTE", for: UIControlState())
    }
    
    //MARK: button tapped handlers
    func buttonTapped(_ button: ParameterOptionsButton){
        selectedButton = button
        updateButtonSelectionStates()
        sendActions(for: .valueChanged) //this tells view controller that something changed
    }
    
    //MARK: update button states / visuals after taped 
    func updateButtonSelectionStates() {
        var num = ParametersButtonTypes.clear
        num = selectedButton.type
        
        var changed = false
        switch num {
        case .clear:
            clearButton.isSelected = !clearButton.isSelected
            changed = true
            print("clear selected")
            
        case .solo:
            soloButton.isSelected = !soloButton.isSelected
            changed = true
            print("solo selected")
            
        case .mute:
            muteButton.isSelected = !muteButton.isSelected
            changed = true
            print("mute sselected")
        case .measure_LEFT:
            measureLeftButton.isSelected = !measureLeftButton.isSelected
            changed = true
            print("measure left selected")
        
        case .measure_RIGHT:
            measureRightButton.isSelected = !measureRightButton.isSelected
            changed = true
            print("measure right selected")
        }
        
        if(changed){
            for (_, button) in buttons.enumerated(){
                button.on = button.isSelected
            }
        }
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
    }
    
    //MARK: update measure count functions
    
    func setMeasure(_ measureCount: Int){
        measures = measureCount
        updateMeasureString()
    }
    
    func updateMeasureString(){
        measureLabel.text = String(format: "\(measures)")
    }
    
    
    //MARK: increment / decrement measure count functions
    func incMeasure(){
        measures += 1
        measuresUpdated = true
    }
    
    func decMeasure(){
        measures -= 1
        //don't let measure count get below 1
        if(measures < 1){
            measures = 1
        }
        measuresUpdated = true
    }
    
    
    //MARK: measure arrow tapped functions
    func measureLeftButtonTapped(){
        print("measure left button tapped")
        decMeasure()
        updateMeasureString()
        selectedButton = measureLeftButton
        sendActions(for: .valueChanged) //this tells view controller that something changed
        
    }
    
    func measureRightButtonTapped(){
        print("measure right button tapped")
        incMeasure()
        updateMeasureString()
        selectedButton = measureRightButton
        sendActions(for: .valueChanged) //this tells view controller that something changed
    }
    
    
}
