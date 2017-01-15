//
//  ParametersButtonCtrl.swift
//  Groover
//
//  Created by Joshua Thompson on 9/28/16.
//  Copyright © 2016 TCM. All rights reserved.
//

import UIKit

//@IBDesignable
class ParametersButtonCtrl: ParametersButton {
    override func draw(_ rect: CGRect) {
        UIGroover.drawSoundParametersCanvas(soundParamteresFrame: self.bounds, soundParametersSelected: isSelected)
    }
    
    // MARK: Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        //self.addTarget(self, action: #selector(ParametersButtonCtrl.buttonTapped(_:)), for: .touchDown)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        //self.addTarget(self, action: #selector(ParametersButtonCtrl.buttonTapped(_:)), for: .touchDown)
        
    }
    
    
    // MARK: Button Action
    
    func buttonTapped(_ button: UIButton) {
        //print("Parameters button tapped")
        //isSelected = !isSelected //toggle selected
        //sendActions(for: .valueChanged) //this tells view controller that something changed
        updateState()
    }
    
    func lightUp(){
        isSelected = true
        updateState()
    }
    
    func unlight(){
        isSelected = false
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


