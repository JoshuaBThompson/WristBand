//
//  PlayRecordControl.swift
//  Groover
//
//  Created by Joshua Thompson on 6/15/16.
//  Copyright © 2016 TCM. All rights reserved.
//

import UIKit

class PlayRecordControl: UIControl {
    var buttons = [PlayRecordButton]()
    var spacing = 20
    var count = 2
    var currentButtonNum = 0
    
    // MARK: Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubviews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        addSubviews()
        
    }
    
    func addSubviews(){
        for i in 0..<count {
            var button: PlayRecordButton!
            switch i {
            case 0:
                button = Play()
            case 1:
                button = Record()
            default:
                button = Play() //TODO: should alert error
            }
            
            //button.adjustsImageWhenHighlighted = false
            
            button.addTarget(self, action: #selector(PlayRecordControl.playRecordButtonTapped(_:)), forControlEvents: .TouchDown)
            buttons += [button]
            addSubview(button)
            
        }
    }
    
    override func layoutSubviews() {
        // Set the button's width and height to a square the size of the frame's height.
        let buttonSize = Int(frame.size.height)
        let buttonSpacing = Int(frame.size.width) / count
        var buttonFrame = CGRect(x: 0, y: 0, width: buttonSize, height: buttonSize)
        
        // Offset each button's origin by the length of the button plus spacing.
        for (index, button) in buttons.enumerate() {
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
    
    func playRecordButtonTapped(button: PlayRecordButton) {
        currentButtonNum = buttons.indexOf(button)!
        print("Play or Record button tapped")
        updateButtonSelectionStates()
        sendActionsForControlEvents(.ValueChanged) //this tells view controller that something changed
        
    }
    
    func updateButtonSelectionStates() {
        for (index, button) in buttons.enumerate() {
            // If the index of a button is less than the rating, that button should be selected.
            button.selected = index == currentButtonNum
            button.on = button.selected
            button.updateState()
            
        }
    }
    
    
}
