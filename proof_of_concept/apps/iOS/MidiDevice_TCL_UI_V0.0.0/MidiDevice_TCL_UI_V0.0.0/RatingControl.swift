//
//  RatingControl.swift
//  MidiDevice_TCL_UI_V0.0.0
//
//  Created by Joshua Thompson on 6/4/16.
//  Copyright © 2016 Joshua Thompson. All rights reserved.
//

import UIKit

class RatingButton: UIButton {
    var angle: CGFloat = 0.0
}

//@IBDesignable
class RatingControl: UIControl {
    //MARK: properties
    var emptyStarImage: UIImage!
    var filledStarImage: UIImage!
    var imageView: UIImageView!
    var knobAngle: CGFloat = 281
    var rating = 0 {
        didSet {
            setNeedsLayout()
            
        }
    }
    var ratingButtons = [RatingButton]()
    let spacing = 5
    let startCount = 1

    
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
        drawKnob()
    }
    
    
    /* this should be used for live rendering when @IBDesignable is tagged to class
    override func prepareForInterfaceBuilder() {
        //code
    }
    */
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubviews()
    }
    
    
    required init?(coder aDecoder: NSCoder) {
         super.init(coder: aDecoder)
        addSubviews()
        
    }
    
    //subview
    func addSubviews(){
        //star images
        emptyStarImage = UIImage(named: "emptyStar")
        filledStarImage = UIImage(named: "filledStar")
        //create buttons
        for _ in 0..<startCount {
            let button = RatingButton()
            //button.setImage(emptyStarImage, forState: .Normal)
            //button.setImage(emptyStarImage, forState: .Selected)
            //button.setImage(emptyStarImage, forState: [.Highlighted, .Selected])
            button.setImage(emptyStarImage, forState: .Normal)
            button.adjustsImageWhenHighlighted = false
            button.addTarget(self, action: #selector(RatingControl.ratingButtonTapped(_:)), forControlEvents: .TouchDown)
            ratingButtons += [button]
            addSubview(button)
        }
    }
    
    //MARK: initialization
    override func layoutSubviews() {
        super.layoutSubviews()
        let buttonSize = 44//Int(frame.size.height)
        var buttonFrame = CGRect(x: 0, y: 0, width: buttonSize, height: buttonSize)
        for (index, button) in ratingButtons.enumerate(){
            buttonFrame.origin.x = CGFloat(index*(buttonSize + spacing))
            button.frame = buttonFrame
        }
        updateButtonSelectionStates()
    }
    
    override func intrinsicContentSize() -> CGSize {
        let buttonSize = Int(frame.size.height)
        let width = (buttonSize * startCount) + (startCount*(spacing - 1))
        return CGSize(width: width, height: buttonSize)
    }
    
    //MARK: button actions
    func ratingButtonTapped(button: RatingButton){
        print("rotating button")
        print("button tapped!")
        
        rating = ratingButtons.indexOf(button)! + 1
        updateButtonSelectionStates()
        
    }
    
    func updateButtonSelectionStates(){
        for (index, button) in ratingButtons.enumerate(){
            button.selected = index < rating
        }
    }
    
    func drawKnob() {
        //// General Declarations
        let context = UIGraphicsGetCurrentContext()
        
        
        //// Image Declarations
        let knobRotatePng = UIImage(named: "knobRotate.png")!
        
        
        //// knobRotate Drawing
        CGContextSaveGState(context)
        CGContextTranslateCTM(context, 123, 122)
        CGContextRotateCTM(context, -knobAngle * CGFloat(M_PI) / 180)
        
        //let knobRotatePath = UIBezierPath(ovalInRect: CGRectMake(-123, -122, 245, 245))
        CGContextSaveGState(context)
        //knobRotatePath.addClip()
        knobRotatePng.drawInRect(CGRectMake(-123/2.0, -122/2.0, knobRotatePng.size.width, knobRotatePng.size.height))
        CGContextRestoreGState(context)
        
        print("draw knob!")
        
    }
    
    
    func turnKnob(){
        knobAngle += 5
        setNeedsDisplay()
    }
    
    
    
    /* Touch Tracking */
    override func beginTrackingWithTouch(touch: UITouch, withEvent event: UIEvent?) -> Bool {
        print("begin tracking knob")
        return true
    }
    
    override func continueTrackingWithTouch(touch: UITouch, withEvent event: UIEvent?) -> Bool {
        print("continue tracking with touch")
        turnKnob()
        return true
    }
    
    override func endTrackingWithTouch(touch: UITouch?, withEvent event: UIEvent?) {
        print("end tracking with touch")
    }


}
