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
        //Clear button
        clearButton = ParameterOptionsButton()
        clearButton.type = .CLEAR
        addButton(clearButton)
        
        //Solo button
        soloButton = ParameterOptionsButton()
        soloButton.type = .SOLO
        addButton(soloButton)
        
    }
    
    //MARK: override standard swift subview layout method to position buttons correctl in view
    override func layoutSubviews() {
        // Set the button's width and height to a square the size of the frame's height.
        var buttonFrame = CGRect(x: 225, y: 20, width: 60, height: 60)
        
        //set clear button position and text
        clearButton.frame = buttonFrame
        clearButton.setTitle("CLEAR", forState: .Normal)
        
        //set solo button position and text
        buttonFrame.origin.x = 100
        soloButton.frame = buttonFrame
        soloButton.setTitle("SOLO", forState: .Normal)
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
    
    
}
