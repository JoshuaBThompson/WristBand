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
    override func draw(_ rect: CGRect) {
        UIGroover.drawSoundParametersCanvas()
    }
    
    // MARK: Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addTarget(self, action: #selector(ParametersButton.buttonTapped(_:)), for: .touchDown)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.addTarget(self, action: #selector(ParametersButton.buttonTapped(_:)), for: .touchDown)
        
    }
    
    
    // MARK: Button Action
    
    func buttonTapped(_ button: UIButton) {
        print("Parameters button tapped")
        isSelected = !isSelected //toggle selected
        sendActions(for: .valueChanged) //this tells view controller that something changed
        updateState()
    }
    
    func updateState(){
        setNeedsDisplay()
    }
    
    //MARK: show / hide functions
    func show(){
        isHidden = false
    }
    
    func hide(){
        isHidden = true
    }
    
}
