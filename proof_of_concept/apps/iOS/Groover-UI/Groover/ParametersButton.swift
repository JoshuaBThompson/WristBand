//
//  ParametersButton.swift
//  Groover
//
//  Created by Alex Crane on 7/4/16.
//  Copyright © 2016 TCM. All rights reserved.
//

import UIKit

//@IBDesignable
class ParametersButton: UIButton {
    override func drawRect(rect: CGRect) {
        UIGroover.drawSoundParametersCanvas()
    }
    
    // MARK: Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addTarget(self, action: #selector(ParametersButton.buttonTapped(_:)), forControlEvents: .TouchDown)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.addTarget(self, action: #selector(ParametersButton.buttonTapped(_:)), forControlEvents: .TouchDown)
        
    }
    
    
    // MARK: Button Action
    
    func buttonTapped(button: UIButton) {
        print("Parameters button tapped")
        selected = !selected //toggle selected
        sendActionsForControlEvents(.ValueChanged) //this tells view controller that something changed
        updateState()
    }
    
    func updateState(){
        setNeedsDisplay()
    }
    
    //MARK: show / hide functions
    func show(){
        hidden = false
    }
    
    func hide(){
        hidden = true
    }
    
}
