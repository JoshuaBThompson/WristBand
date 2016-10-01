//
//  HamburgerIconCtrl.swift
//  Groover
//
//  Created by Joshua Thompson on 10/1/16.
//  Copyright © 2016 TCM. All rights reserved.
//

import UIKit

class HamburgerIconCtrl: HamburgerIcon {

    // MARK: Draw
    override func draw(_ rect: CGRect) {
        UIGroover.drawHamburgerCanvas(hamburgerSelected: isSelected)
    }
    
    // MARK: Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addTarget(self, action: #selector(HamburgerIconCtrl.buttonTapped(_:)), for: .touchDown)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.addTarget(self, action: #selector(HamburgerIconCtrl.buttonTapped(_:)), for: .touchDown)
        
    }
    
    
    // MARK: Button Action
    
    func buttonTapped(_ button: UIButton) {
        print("Setting button tapped")
        isSelected = !isSelected //toggle selected
        sendActions(for: .valueChanged) //this tells view controller that something changed
        updateState()
    }
    
    func updateState(){
        setNeedsDisplay()
    }

}
