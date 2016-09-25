//
//  ThirtysecondCtrl.swift
//  Groover
//
//  Created by Joshua Thompson on 9/24/16.
//  Copyright © 2016 TCM. All rights reserved.
//

import UIKit

class ThirtysecondCtrl: Thirtysecond, QuantizeButtonProtocol {
    var resolution = ThirtysecondResolution
    var on: Bool {
        get {
            return isSelected
        }
        set(sel) {
            isSelected = sel
        }
    }
    
    var button: UIButton!
    override func draw(_ rect: CGRect) {
        UIGroover.drawThirtysecondCanvas(thirtysecondSelected: isSelected)
    }
    
    // MARK: Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addTarget(self, action: #selector(buttonTapped), for: .touchDown)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.addTarget(self, action: #selector(buttonTapped), for: .touchDown)
    }
    
    func buttonTapped(){
        print("thirtysecond selected!")
        isSelected = !isSelected
        sendActions(for: .valueChanged) //this tells view controller that something changed
    }

}
