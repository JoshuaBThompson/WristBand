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
    var currentButton = QuantizeButton()
    var tripletButton: QuantizeButton!
    
    // MARK: Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubviews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        addSubviews()
        
    }
    
    func addButton(_ button: QuantizeButton){
        button.addTarget(self, action: #selector(QuantizeControl.quantizeButtonTapped(_:)), for: .touchDown)
        buttons += [button]
        addSubview(button)
    }
    
    func addSubviews(){
        for i in 0 ..< count {
            var buttonType = QuantizeButtonTypes_t.quarter //QuantizeButtonTypes_t(rawValue: i)
            buttonType = QuantizeButtonTypes_t(rawValue: i)!
            var button: QuantizeButton!
            
            switch buttonType {
            case .quarter:
                button = Quarter()
                button.resolution = 1.0 //resolution used in song to quantize beats in loop
            case .eight:
                button = Eighth()
                button.resolution = 2.0
            case .sixteenth:
                button = Sixteenth()
                button.resolution = 4.0
            case .thirtysec:
                button = Thirtysecond()
                button.resolution = 8.0
            case .triplet:
                button = Triplet()
                button.resolution = 3.0
                tripletButton = button
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
        for (index, button) in buttons.enumerated() {
            //buttonFrame.origin.x = CGFloat(index * (buttonSize + spacing))
            buttonFrame.origin.x = CGFloat(CGFloat(index) * (buttonSpacing) + spacing)
            //buttonFrame.size.width = buttonFrame.size.width
            //buttonFrame.size.height = buttonFrame.size.height
            button.frame = buttonFrame
        }
        updateButtonSelectionStates()
    }
    
    override var intrinsicContentSize : CGSize {
        let buttonSize = CGFloat(frame.size.height)
        let width = (buttonSize + spacing) * CGFloat(count)
        
        return CGSize(width: width, height: buttonSize)
    }
    
    // MARK: Button Action
    
    func quantizeButtonTapped(_ button: QuantizeButton) {
        if(button == tripletButton){
            tripletButton.isSelected = !tripletButton.isSelected
            tripletButton.updateState()
            sendActions(for: .valueChanged) //this tells view controller that something changed
            print("triplet!")
        }
        else{
            currentButtonNum = buttons.index(of: button)!
            currentButton = buttons[currentButtonNum]
            print("Quantized button tapped")
            updateButtonSelectionStates()
            sendActions(for: .valueChanged) //this tells view controller that something changed
        }
        
    }
    
    func updateButtonSelectionStates() {
        //TODO: ?
        var c = 0
        var sel = false
        for (_, button) in buttons.enumerated(){
            c += 1
            if(button != currentButton && button != tripletButton){
                button.isSelected = false
                
                print("button num \(c)")
            }
            else if(currentButton == button){
                
                currentButton.isSelected = !currentButton.isSelected //toggle selected state
                sel = currentButton.isSelected
                print("selected \(sel)")
            }

            button.updateState()
        }
    }

}
