//
//  TripletCtrl.swift
//  Groover
//
//  Created by Joshua Thompson on 9/24/16.
//  Copyright © 2016 TCM. All rights reserved.
//

import UIKit

class TripletCtrl: Triplet, QuantizeButtonProtocol {
    var resolution = TripletResolution
    var on: Bool {
        get {
            return isSelected
        }
        set(sel) {
            isSelected = sel
        }
    }
    
    override func draw(_ rect: CGRect) {
        UIGroover.drawTripletCanvas(tripletFrame: self.bounds, tripletSelected: isSelected)
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
        
        isSelected = !isSelected
        print("triplet selected to \(isSelected)")
        sendActions(for: .valueChanged) //this tells view controller that something changed
    }
}
