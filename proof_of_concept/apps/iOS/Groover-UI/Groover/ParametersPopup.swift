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
        button.addTarget(self, action: #selector(ParametersPopup.clearButtonTapped), forControlEvents: .TouchDown)
        addSubview(button)
    }
    
    func addSubviews(){
        clearButton = ParameterOptionsButton()
        clearButton.type = .CLEAR
        addButton(clearButton)
        
    }
    
    //MARK: override standard swift subview layout method to position buttons correctl in view
    override func layoutSubviews() {
        // Set the button's width and height to a square the size of the frame's height.
        let buttonFrame = CGRect(x: 225, y: 20, width: 60, height: 60)
        
        //clear button
        clearButton.frame = buttonFrame
        clearButton.setTitle("Clear", forState: .Normal)
    }
    
    //MARK: button tapped handlers
    func clearButtonTapped(){
        print("clear button on parameters popup tapped!")
        sendActionsForControlEvents(.ValueChanged) //this tells view controller that something changed
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
