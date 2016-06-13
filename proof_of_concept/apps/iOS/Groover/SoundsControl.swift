//
//  SoundsControl.swift
//  Groover
//
//  Created by Joshua Thompson on 6/13/16.
//  Copyright © 2016 TCM. All rights reserved.
//

import UIKit

class SoundsControl: UIControl {
    var soundButtons = [Sounds]()
    var spacing = 20
    var count = 4
    var currentSoundNum = 0
    
    // MARK: Initialization
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        for i in 0..<count {
            var button: Sounds!
            switch i {
            case 0:
                button = Sound1()
            case 1:
                button = Sound2()
            case 2:
                button = Sound3()
            case 3:
                button = Sound4()
            default:
                button = Sound4() //TODO: should alert
            }
            
            //button.adjustsImageWhenHighlighted = false
            
            button.addTarget(self, action: #selector(SoundsControl.soundButtonTapped(_:)), forControlEvents: .TouchDown)
            soundButtons += [button]
            addSubview(button)
            
        }
    }
    
    override func layoutSubviews() {
        // Set the button's width and height to a square the size of the frame's height.
        let buttonSize = Int(frame.size.height)
        let buttonSpacing = Int(frame.size.width) / count
        var buttonFrame = CGRect(x: 0, y: 0, width: buttonSize, height: buttonSize)
        
        // Offset each button's origin by the length of the button plus spacing.
        for (index, button) in soundButtons.enumerate() {
            //buttonFrame.origin.x = CGFloat(index * (buttonSize + spacing))
            buttonFrame.origin.x = CGFloat(index * (buttonSpacing) + spacing)
            //buttonFrame.size.width = buttonFrame.size.width
            //buttonFrame.size.height = buttonFrame.size.height
            button.frame = buttonFrame
        }
        updateButtonSelectionStates()
    }
    
    override func intrinsicContentSize() -> CGSize {
        let buttonSize = Int(frame.size.height)
        let width = (buttonSize + spacing) * count
        
        return CGSize(width: width, height: buttonSize)
    }
    
    // MARK: Button Action
    
    func soundButtonTapped(button: Sounds) {
        currentSoundNum = soundButtons.indexOf(button)!
        print("Option button tapped")
        updateButtonSelectionStates()
    }
    
    func updateButtonSelectionStates() {
        for (index, button) in soundButtons.enumerate() {
            // If the index of a button is less than the rating, that button should be selected.
            button.selected = index == currentSoundNum
            button.on = button.selected
            button.updateState()
            
        }
    }
    
    
}

