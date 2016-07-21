//
//  ParametersPopup.swift
//  Groover
//
//  Created by Alex Crane on 7/19/16.
//  Copyright © 2016 TCM. All rights reserved.
//

import UIKit

//@IBDesignable
class ParametersPopup: UIView {
    
    override func drawRect(rect: CGRect) {
        UIGroover.drawPopupCanvas()
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
