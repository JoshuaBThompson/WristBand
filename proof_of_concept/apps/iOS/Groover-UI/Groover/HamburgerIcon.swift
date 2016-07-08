//
//  Hamburger.swift
//  Groover
//
//  Created by Alex Crane on 7/4/16.
//  Copyright © 2016 TCM. All rights reserved.
//

import UIKit

//@IBDesignable
class HamburgerIcon: UIButton {
    
    // MARK: Draw
    override func drawRect(rect: CGRect) {
        UIGroover.drawHamburgerCanvas(hamburgerSelected: selected)
    }
    
    // MARK: Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addTarget(self, action: #selector(HamburgerIcon.buttonTapped(_:)), forControlEvents: .TouchDown)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.addTarget(self, action: #selector(HamburgerIcon.buttonTapped(_:)), forControlEvents: .TouchDown)
        
    }
    
    
    // MARK: Button Action
    
    func buttonTapped(button: UIButton) {
        print("Setting button tapped")
        selected = !selected //toggle selected
        sendActionsForControlEvents(.ValueChanged) //this tells view controller that something changed
        updateState()
    }
    
    func updateState(){
        setNeedsDisplay()
    }
    
}
