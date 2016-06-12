//
//  OptionsControl.swift
//  Groover
//
//  Created by Joshua Thompson on 6/11/16.
//  Copyright © 2016 TCM. All rights reserved.
//

import UIKit

class OptionsControl: UIControl {
    var optionButtons = [Options]()
    var spacing = 12
    var count = 4
    var currentOptionNum = 0
    
    // MARK: Initialization
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        for i in 0..<count {
            var button: Options!
            switch i {
            case 0:
                button = Option1()
            case 1:
                button = Option2()
            case 2:
                button = Option3()
            case 3:
                button = Option4()
            default:
                button = Option4() //TODO: should alert
            }
            
            //button.adjustsImageWhenHighlighted = false
            
            button.addTarget(self, action: #selector(OptionsControl.optionButtonTapped(_:)), forControlEvents: .TouchDown)
            optionButtons += [button]
            addSubview(button)
            
        }
    }
    
    override func layoutSubviews() {
        // Set the button's width and height to a square the size of the frame's height.
        let buttonSize = Int(frame.size.height)
        let buttonSpacing = Int(frame.size.width) / count
        var buttonFrame = CGRect(x: 0, y: 0, width: buttonSize, height: buttonSize)
        
        // Offset each button's origin by the length of the button plus spacing.
        for (index, button) in optionButtons.enumerate() {
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
    
    func optionButtonTapped(button: Options) {
        currentOptionNum = optionButtons.indexOf(button)!
        print("Option button tapped")
        updateButtonSelectionStates()
    }
    
    func updateButtonSelectionStates() {
        for (index, button) in optionButtons.enumerate() {
            // If the index of a button is less than the rating, that button should be selected.
            button.selected = index == currentOptionNum
            button.on = button.selected
            button.updateState()
            
        }
    }


}
