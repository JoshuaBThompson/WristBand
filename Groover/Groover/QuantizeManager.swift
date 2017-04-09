//
//  QuantizeManager.swift
//  Groover
//
//  Created by Joshua Thompson on 4/9/17.
//  Copyright © 2017 TCM. All rights reserved.
//

import Foundation
import UIKit


class QuantizeManager {
    //MARK: Attributes
    var quantize_buttons = [QuantizeButtonProtocol]()
    var active: Bool = false
    var resolution: Double = 0
    var tripletActive: Bool = false
    
    //MARK: Init
    init(quantize_buttons_list: [QuantizeButtonProtocol]){
        //set quantize button callbacks
        quantize_buttons = quantize_buttons_list
    }
    
    //MARK: Functions
    
    //MARK: Handle quantize button value change and update resolution and selected variables
    func processQuantizeEvent(quantizeButton: QuantizeButtonProtocol){
    
        if(quantizeButton.resolution == TripletResolution){
            tripletActive = quantizeButton.on
        }
        
        else if(quantizeButton.resolution != TripletResolution){
            resolution = quantizeButton.resolution
            active = quantizeButton.on
        }
        
        for button in quantize_buttons {
            if(button.resolution != quantizeButton.resolution && quantizeButton.resolution != TripletResolution && button.resolution != TripletResolution){
                button.on = false
            }
                
            else if(button.resolution != TripletResolution && quantizeButton.resolution == TripletResolution){
                if(button.on){
                    active = true
                    resolution = button.resolution
                }
            }
        }
    }
    
    
    
}
