//
//  QuantizeControl.swift
//  Groover
//
//  Created by Joshua Thompson on 8/23/16.
//  Copyright © 2016 TCM. All rights reserved.
//

import UIKit

@IBDesignable
class QuantizeControl: UIControl {

    var buttons = [QuantizeButton]()
    var spacing: CGFloat = 15
    var count = 5
    var currentButtonNum = 0
    var currentButton: QuantizeButton!
    
    // MARK: Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubviews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        addSubviews()
        
    }
    
    func addButton(button: QuantizeButton){
        button.addTarget(self, action: #selector(QuantizeControl.quantizeButtonTapped(_:)), forControlEvents: .TouchDown)
        buttons += [button]
        addSubview(button)
    }
    
    func addSubviews(){
        for i in 0 ..< count {
            var buttonType = QuantizeButtonTypes_t.QUARTER //QuantizeButtonTypes_t(rawValue: i)
            buttonType = QuantizeButtonTypes_t(rawValue: i)!
            var button: QuantizeButton!
            
            switch buttonType {
            case .QUARTER:
                button = Quarter()
                button.resolution = 4.0 //resolution used in song to quantize beats in loop
            case .EIGHT:
                button = Eighth()
                button.resolution = 8.0
            case .SIXTEENTH:
                button = Sixteenth()
                button.resolution = 16.0
            case .THIRTYSEC:
                button = Thirtysecond()
                button.resolution = 32.0
            case .TRIPLET:
                button = Triplet()
                button.resolution = 64.0
            }
            
            button.type = buttonType //convert number to button type (QUARTER, EIGHTH ..etc)
            addButton(button)
            
            
        }
        //button.adjustsImageWhenHighlighted = false
        
    }
    
    override func layoutSubviews() {
        // Set the button's width and height to a square the size of the frame's height.
        let buttonSize = CGFloat(frame.size.height)
        let buttonSpacing = (frame.size.width) / CGFloat(count)
        var buttonFrame = CGRect(x: 0, y: 20, width: buttonSize, height: buttonSize)
        
        // Offset each button's origin by the length of the button plus spacing.
        for (index, button) in buttons.enumerate() {
            //buttonFrame.origin.x = CGFloat(index * (buttonSize + spacing))
            buttonFrame.origin.x = CGFloat(CGFloat(index) * (buttonSpacing) + spacing)
            //buttonFrame.size.width = buttonFrame.size.width
            //buttonFrame.size.height = buttonFrame.size.height
            button.frame = buttonFrame
        }
        updateButtonSelectionStates()
    }
    
    override func intrinsicContentSize() -> CGSize {
        let buttonSize = CGFloat(frame.size.height)
        let width = (buttonSize + spacing) * CGFloat(count)
        
        return CGSize(width: width, height: buttonSize)
    }
    
    // MARK: Button Action
    
    func quantizeButtonTapped(button: QuantizeButton) {
        currentButtonNum = buttons.indexOf(button)!
        currentButton = buttons[currentButtonNum]
        print("Quantized button tapped")
        updateButtonSelectionStates()
        sendActionsForControlEvents(.ValueChanged) //this tells view controller that something changed
        
    }
    
    func updateButtonSelectionStates() {
        //TODO: ?
        
        for (_, button) in buttons.enumerate(){
            if(button != currentButton){
                button.selected = false
            }
            else{
                currentButton.selected = !currentButton.selected //toggle selected state
            }
            //button.on = button.selected //colors to bright when on and selected are both true
            //button.set = button.selected
            button.updateState()
        }
    }

}