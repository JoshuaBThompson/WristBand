//
//  GrooverUI.swift
//  Groover
//
//  Created by  on 6/8/16.
//  Copyright (c) 2016 TCM. All rights reserved.
//
//  Generated by PaintCode (www.paintcodeapp.com)
//



import UIKit

public class GrooverUI : NSObject {

    //// Cache

    private struct Cache {
        static var fullbgimage: UIImage?

    }

    //// Images

    public class var fullbgimage: UIImage {
        if Cache.fullbgimage == nil {
            Cache.fullbgimage = UIImage(named: "fullbgimage")!
        }
        return Cache.fullbgimage!
    }

    //// Drawing Methods

    public class func drawBgCanvas() {
        //// General Declarations
        let context = UIGraphicsGetCurrentContext()

        //// bgFullscreen Drawing
        let bgFullscreenPath = UIBezierPath(roundedRect: CGRectMake(0, 0, 320, 568), cornerRadius: 6)
        CGContextSaveGState(context)
        bgFullscreenPath.addClip()
        CGContextScaleCTM(context, 1, -1)
        CGContextDrawTiledImage(context, CGRectMake(0, 0, GrooverUI.fullbgimage.size.width, GrooverUI.fullbgimage.size.height), GrooverUI.fullbgimage.CGImage)
        CGContextRestoreGState(context)
    }

    public class func drawKnobCanvas(knobAngle knobAngle: CGFloat = 0, innerKnobActive: Bool = false, clickActive: Bool = false, innerKnobPosition: CGFloat = 90) {
        //// General Declarations
        let context = UIGraphicsGetCurrentContext()

        //// Color Declarations
        let clickStrokeColor = UIColor(red: 0.173, green: 0.220, blue: 0.263, alpha: 0.490)
        let clickIconColor = UIColor(red: 0.173, green: 0.220, blue: 0.263, alpha: 1.000)
        let selectedBlueColor = UIColor(red: 0.349, green: 0.733, blue: 0.961, alpha: 1.000)
        let innerpositionIndicatorColor = UIColor(red: 0.037, green: 0.112, blue: 0.182, alpha: 0.114)

        //// Image Declarations
        let knobouterimage = UIImage(named: "knobouterimage")!
        let knobrotationimage = UIImage(named: "knobrotationimage")!
        let knobcenterimage = UIImage(named: "knobcenterimage")!

        //// Variable Declarations
        let clickButtonColor = clickActive ? selectedBlueColor : clickIconColor
        let clickButtonStrokeColor = clickActive ? selectedBlueColor : clickStrokeColor

        //// knobOuter Drawing
        let knobOuterPath = UIBezierPath(ovalInRect: CGRectMake(0, 0, 280, 280))
        CGContextSaveGState(context)
        knobOuterPath.addClip()
        CGContextScaleCTM(context, 1, -1)
        CGContextDrawTiledImage(context, CGRectMake(0, 0, knobouterimage.size.width, knobouterimage.size.height), knobouterimage.CGImage)
        CGContextRestoreGState(context)


        //// knobRotation Drawing
        CGContextSaveGState(context)
        CGContextTranslateCTM(context, 140, 140)
        CGContextRotateCTM(context, -knobAngle * CGFloat(M_PI) / 180)

        let knobRotationPath = UIBezierPath(ovalInRect: CGRectMake(-140, -140, 280, 280))
        CGContextSaveGState(context)
        knobRotationPath.addClip()
        knobrotationimage.drawInRect(CGRectMake(-140, -140, knobrotationimage.size.width, knobrotationimage.size.height))
        CGContextRestoreGState(context)

        CGContextRestoreGState(context)


        //// knobCenter Drawing
        let knobCenterPath = UIBezierPath(ovalInRect: CGRectMake(59, 59, 162, 162))
        CGContextSaveGState(context)
        knobCenterPath.addClip()
        CGContextScaleCTM(context, 1, -1)
        CGContextDrawTiledImage(context, CGRectMake(59, -59, knobcenterimage.size.width, knobcenterimage.size.height), knobcenterimage.CGImage)
        CGContextRestoreGState(context)


        //// clickButton
        //// path-1 Drawing
        let path1Path = UIBezierPath(ovalInRect: CGRectMake(106, 106, 68, 68))
        clickButtonStrokeColor.setStroke()
        path1Path.lineWidth = 1
        path1Path.stroke()


        //// click-icon-4 Drawing
        let clickicon4Path = UIBezierPath(ovalInRect: CGRectMake(152.24, 137.27, 7.12, 7.13))
        clickButtonColor.setFill()
        clickicon4Path.fill()


        //// click-icon-3 Drawing
        let clickicon3Path = UIBezierPath(roundedRect: CGRectMake(139.57, 132.53, 11.05, 16.65), cornerRadius: 5.53)
        clickButtonColor.setFill()
        clickicon3Path.fill()


        //// click-icon-2 Drawing
        let clickicon2Path = UIBezierPath(ovalInRect: CGRectMake(130.89, 137.27, 7.12, 7.13))
        clickButtonColor.setFill()
        clickicon2Path.fill()


        //// click-icon-1 Drawing
        let clickicon1Path = UIBezierPath(ovalInRect: CGRectMake(120.61, 137.27, 7.12, 7.13))
        clickButtonColor.setFill()
        clickicon1Path.fill()




        if (innerKnobActive) {
            //// InnerKnobIndicator Drawing
            CGContextSaveGState(context)
            CGContextTranslateCTM(context, 140, 140)

            let innerKnobIndicatorPath = UIBezierPath()
            innerKnobIndicatorPath.moveToPoint(CGPointMake(0, 80))
            innerKnobIndicatorPath.addCurveToPoint(CGPointMake(80, 0), controlPoint1: CGPointMake(44.18, 80), controlPoint2: CGPointMake(80, 44.18))
            innerKnobIndicatorPath.addCurveToPoint(CGPointMake(0, -80), controlPoint1: CGPointMake(80, -44.18), controlPoint2: CGPointMake(44.18, -80))
            innerKnobIndicatorPath.addCurveToPoint(CGPointMake(-80, 0), controlPoint1: CGPointMake(-44.18, -80), controlPoint2: CGPointMake(-80, -44.18))
            innerKnobIndicatorPath.addCurveToPoint(CGPointMake(0, 80), controlPoint1: CGPointMake(-80, 44.18), controlPoint2: CGPointMake(-44.18, 80))
            innerKnobIndicatorPath.addLineToPoint(CGPointMake(0, 80))
            innerKnobIndicatorPath.closePath()
            innerKnobIndicatorPath.moveToPoint(CGPointMake(0, 78))
            innerKnobIndicatorPath.addCurveToPoint(CGPointMake(78, 0), controlPoint1: CGPointMake(43.08, 78), controlPoint2: CGPointMake(78, 43.08))
            innerKnobIndicatorPath.addCurveToPoint(CGPointMake(0, -78), controlPoint1: CGPointMake(78, -43.08), controlPoint2: CGPointMake(43.08, -78))
            innerKnobIndicatorPath.addCurveToPoint(CGPointMake(-78, 0), controlPoint1: CGPointMake(-43.08, -78), controlPoint2: CGPointMake(-78, -43.08))
            innerKnobIndicatorPath.addCurveToPoint(CGPointMake(0, 78), controlPoint1: CGPointMake(-78, 43.08), controlPoint2: CGPointMake(-43.08, 78))
            innerKnobIndicatorPath.addLineToPoint(CGPointMake(0, 78))
            innerKnobIndicatorPath.closePath()
            innerKnobIndicatorPath.usesEvenOddFillRule = true;

            selectedBlueColor.setFill()
            innerKnobIndicatorPath.fill()

            CGContextRestoreGState(context)


            //// innerPositionIndicator
            CGContextSaveGState(context)
            CGContextTranslateCTM(context, 140, 140)
            CGContextRotateCTM(context, -innerKnobPosition * CGFloat(M_PI) / 180)



            //// innerPositionIndicatorBorder Drawing
            CGContextSaveGState(context)
            CGContextTranslateCTM(context, -38.5, 36.5)

            let innerPositionIndicatorBorderPath = UIBezierPath(ovalInRect: CGRectMake(-5.5, -5.5, 11, 11))
            innerpositionIndicatorColor.setFill()
            innerPositionIndicatorBorderPath.fill()

            CGContextRestoreGState(context)


            //// innerPositionIndicatorFill Drawing
            let innerPositionIndicatorFillPath = UIBezierPath(ovalInRect: CGRectMake(-43, 32, 9, 9))
            selectedBlueColor.setFill()
            innerPositionIndicatorFillPath.fill()



            CGContextRestoreGState(context)
        }
    }

    public class func drawPlayCanvas(playSelected playSelected: Bool = false) {
        //// General Declarations
        let context = UIGraphicsGetCurrentContext()

        //// Color Declarations
        let darkButtonColor = UIColor(red: 0.043, green: 0.082, blue: 0.157, alpha: 1.000)
        let playButtonSelected = UIColor(red: 0.443, green: 0.737, blue: 0.435, alpha: 1.000)

        //// Image Declarations
        let playglowimage = UIImage(named: "playglowimage")!

        //// Variable Declarations
        let playButtonColor = playSelected ? playButtonSelected : darkButtonColor

        if (playSelected) {
            //// playGlowCanvas Drawing
            let playGlowCanvasPath = UIBezierPath(rect: CGRectMake(0, 0, 38, 38))
            CGContextSaveGState(context)
            playGlowCanvasPath.addClip()
            playglowimage.drawInRect(CGRectMake(0, 0, playglowimage.size.width, playglowimage.size.height))
            CGContextRestoreGState(context)
        }


        //// platButton Drawing
        let platButtonPath = UIBezierPath()
        platButtonPath.moveToPoint(CGPointMake(8, 30))
        platButtonPath.addLineToPoint(CGPointMake(8, 8))
        platButtonPath.addLineToPoint(CGPointMake(30, 19))
        platButtonPath.addLineToPoint(CGPointMake(8, 30))
        platButtonPath.closePath()
        platButtonPath.usesEvenOddFillRule = true;

        playButtonColor.setFill()
        platButtonPath.fill()
    }

    public class func drawRecordCanvas(recordSelected recordSelected: Bool = false) {
        //// General Declarations
        let context = UIGraphicsGetCurrentContext()

        //// Color Declarations
        let darkButtonColor = UIColor(red: 0.043, green: 0.082, blue: 0.157, alpha: 1.000)
        let recordButtonSelected = UIColor(red: 0.773, green: 0.141, blue: 0.169, alpha: 1.000)

        //// Image Declarations
        let recordglowimage = UIImage(named: "recordglowimage")!

        //// Variable Declarations
        let recordButtonColor = recordSelected ? recordButtonSelected : darkButtonColor

        if (recordSelected) {
            //// recordGlowCanvas Drawing
            let recordGlowCanvasPath = UIBezierPath(rect: CGRectMake(0, 0, 40, 40))
            CGContextSaveGState(context)
            recordGlowCanvasPath.addClip()
            recordglowimage.drawInRect(CGRectMake(0, 0, recordglowimage.size.width, recordglowimage.size.height))
            CGContextRestoreGState(context)
        }


        //// recordButton Drawing
        let recordButtonPath = UIBezierPath()
        recordButtonPath.moveToPoint(CGPointMake(20, 31))
        recordButtonPath.addCurveToPoint(CGPointMake(31, 20), controlPoint1: CGPointMake(26.08, 31), controlPoint2: CGPointMake(31, 26.08))
        recordButtonPath.addCurveToPoint(CGPointMake(20, 9), controlPoint1: CGPointMake(31, 13.92), controlPoint2: CGPointMake(26.08, 9))
        recordButtonPath.addCurveToPoint(CGPointMake(9, 20), controlPoint1: CGPointMake(13.92, 9), controlPoint2: CGPointMake(9, 13.92))
        recordButtonPath.addCurveToPoint(CGPointMake(20, 31), controlPoint1: CGPointMake(9, 26.08), controlPoint2: CGPointMake(13.92, 31))
        recordButtonPath.closePath()
        recordButtonPath.usesEvenOddFillRule = true;

        recordButtonColor.setFill()
        recordButtonPath.fill()
    }

    public class func drawOptionsCanvas1(optionOneSelected optionOneSelected: Bool = false) {
        //// Color Declarations
        let selectedBlueColor = UIColor(red: 0.349, green: 0.733, blue: 0.961, alpha: 1.000)
        let optionButtonDeslected = UIColor(red: 0.800, green: 0.847, blue: 0.890, alpha: 0.141)

        //// Variable Declarations
        let optionOneColor = optionOneSelected ? selectedBlueColor : optionButtonDeslected

        //// optionsButton Drawing
        let optionsButtonPath = UIBezierPath()
        optionsButtonPath.moveToPoint(CGPointMake(0, 1.99))
        optionsButtonPath.addCurveToPoint(CGPointMake(1.99, 0), controlPoint1: CGPointMake(0, 0.89), controlPoint2: CGPointMake(0.89, 0))
        optionsButtonPath.addLineToPoint(CGPointMake(48.01, 0))
        optionsButtonPath.addCurveToPoint(CGPointMake(50, 1.99), controlPoint1: CGPointMake(49.11, 0), controlPoint2: CGPointMake(50, 0.89))
        optionsButtonPath.addLineToPoint(CGPointMake(50, 48.01))
        optionsButtonPath.addCurveToPoint(CGPointMake(48.01, 50), controlPoint1: CGPointMake(50, 49.11), controlPoint2: CGPointMake(49.11, 50))
        optionsButtonPath.addLineToPoint(CGPointMake(1.99, 50))
        optionsButtonPath.addCurveToPoint(CGPointMake(0, 48.01), controlPoint1: CGPointMake(0.89, 50), controlPoint2: CGPointMake(0, 49.11))
        optionsButtonPath.addLineToPoint(CGPointMake(0, 1.99))
        optionsButtonPath.closePath()
        optionsButtonPath.usesEvenOddFillRule = true;

        optionOneColor.setFill()
        optionsButtonPath.fill()
    }

    public class func drawOptionsCanvas2(optionTwoSelected optionTwoSelected: Bool = false) {
        //// Color Declarations
        let selectedBlueColor = UIColor(red: 0.349, green: 0.733, blue: 0.961, alpha: 1.000)
        let optionButtonDeslected = UIColor(red: 0.800, green: 0.847, blue: 0.890, alpha: 0.141)

        //// Variable Declarations
        let optionTwoColor = optionTwoSelected ? selectedBlueColor : optionButtonDeslected

        //// optionsButton Drawing
        let optionsButtonPath = UIBezierPath()
        optionsButtonPath.moveToPoint(CGPointMake(0, 1.99))
        optionsButtonPath.addCurveToPoint(CGPointMake(1.99, 0), controlPoint1: CGPointMake(0, 0.89), controlPoint2: CGPointMake(0.89, 0))
        optionsButtonPath.addLineToPoint(CGPointMake(48.01, 0))
        optionsButtonPath.addCurveToPoint(CGPointMake(50, 1.99), controlPoint1: CGPointMake(49.11, 0), controlPoint2: CGPointMake(50, 0.89))
        optionsButtonPath.addLineToPoint(CGPointMake(50, 48.01))
        optionsButtonPath.addCurveToPoint(CGPointMake(48.01, 50), controlPoint1: CGPointMake(50, 49.11), controlPoint2: CGPointMake(49.11, 50))
        optionsButtonPath.addLineToPoint(CGPointMake(1.99, 50))
        optionsButtonPath.addCurveToPoint(CGPointMake(0, 48.01), controlPoint1: CGPointMake(0.89, 50), controlPoint2: CGPointMake(0, 49.11))
        optionsButtonPath.addLineToPoint(CGPointMake(0, 1.99))
        optionsButtonPath.closePath()
        optionsButtonPath.usesEvenOddFillRule = true;

        optionTwoColor.setFill()
        optionsButtonPath.fill()
    }

    public class func drawOptionsCanvas3(optionThreeSelected optionThreeSelected: Bool = false) {
        //// Color Declarations
        let selectedBlueColor = UIColor(red: 0.349, green: 0.733, blue: 0.961, alpha: 1.000)
        let optionButtonDeslected = UIColor(red: 0.800, green: 0.847, blue: 0.890, alpha: 0.141)

        //// Variable Declarations
        let optionThreeColor = optionThreeSelected ? selectedBlueColor : optionButtonDeslected

        //// optionsButton Drawing
        let optionsButtonPath = UIBezierPath()
        optionsButtonPath.moveToPoint(CGPointMake(0, 1.99))
        optionsButtonPath.addCurveToPoint(CGPointMake(1.99, 0), controlPoint1: CGPointMake(0, 0.89), controlPoint2: CGPointMake(0.89, 0))
        optionsButtonPath.addLineToPoint(CGPointMake(48.01, 0))
        optionsButtonPath.addCurveToPoint(CGPointMake(50, 1.99), controlPoint1: CGPointMake(49.11, 0), controlPoint2: CGPointMake(50, 0.89))
        optionsButtonPath.addLineToPoint(CGPointMake(50, 48.01))
        optionsButtonPath.addCurveToPoint(CGPointMake(48.01, 50), controlPoint1: CGPointMake(50, 49.11), controlPoint2: CGPointMake(49.11, 50))
        optionsButtonPath.addLineToPoint(CGPointMake(1.99, 50))
        optionsButtonPath.addCurveToPoint(CGPointMake(0, 48.01), controlPoint1: CGPointMake(0.89, 50), controlPoint2: CGPointMake(0, 49.11))
        optionsButtonPath.addLineToPoint(CGPointMake(0, 1.99))
        optionsButtonPath.closePath()
        optionsButtonPath.usesEvenOddFillRule = true;

        optionThreeColor.setFill()
        optionsButtonPath.fill()
    }

    public class func drawOptionsCanvas4(optionFourSelected optionFourSelected: Bool = false) {
        //// Color Declarations
        let selectedBlueColor = UIColor(red: 0.349, green: 0.733, blue: 0.961, alpha: 1.000)
        let optionButtonDeslected = UIColor(red: 0.800, green: 0.847, blue: 0.890, alpha: 0.141)

        //// Variable Declarations
        let optionFourColor = optionFourSelected ? selectedBlueColor : optionButtonDeslected

        //// optionsButton Drawing
        let optionsButtonPath = UIBezierPath()
        optionsButtonPath.moveToPoint(CGPointMake(0, 1.99))
        optionsButtonPath.addCurveToPoint(CGPointMake(1.99, 0), controlPoint1: CGPointMake(0, 0.89), controlPoint2: CGPointMake(0.89, 0))
        optionsButtonPath.addLineToPoint(CGPointMake(48.01, 0))
        optionsButtonPath.addCurveToPoint(CGPointMake(50, 1.99), controlPoint1: CGPointMake(49.11, 0), controlPoint2: CGPointMake(50, 0.89))
        optionsButtonPath.addLineToPoint(CGPointMake(50, 48.01))
        optionsButtonPath.addCurveToPoint(CGPointMake(48.01, 50), controlPoint1: CGPointMake(50, 49.11), controlPoint2: CGPointMake(49.11, 50))
        optionsButtonPath.addLineToPoint(CGPointMake(1.99, 50))
        optionsButtonPath.addCurveToPoint(CGPointMake(0, 48.01), controlPoint1: CGPointMake(0.89, 50), controlPoint2: CGPointMake(0, 49.11))
        optionsButtonPath.addLineToPoint(CGPointMake(0, 1.99))
        optionsButtonPath.closePath()
        optionsButtonPath.usesEvenOddFillRule = true;

        optionFourColor.setFill()
        optionsButtonPath.fill()
    }

    public class func drawSoundCanvasOne(soundOneSelected soundOneSelected: Bool = false) {
        //// Color Declarations
        let selectedBlueColor = UIColor(red: 0.349, green: 0.733, blue: 0.961, alpha: 1.000)
        let optionButtonDeslected = UIColor(red: 0.800, green: 0.847, blue: 0.890, alpha: 0.141)

        //// Variable Declarations
        let soundOneColor = soundOneSelected ? selectedBlueColor : optionButtonDeslected

        //// soundOneIcon
        //// Oval 1 Drawing
        let oval1Path = UIBezierPath(ovalInRect: CGRectMake(21, 20, 6, 6))
        soundOneColor.setFill()
        oval1Path.fill()


        //// Oval 2 Drawing
        let oval2Path = UIBezierPath(ovalInRect: CGRectMake(24, 12, 6, 6))
        soundOneColor.setFill()
        oval2Path.fill()


        //// Oval 3 Drawing
        let oval3Path = UIBezierPath(ovalInRect: CGRectMake(12, 12, 6, 6))
        soundOneColor.setFill()
        oval3Path.fill()


        //// Oval 4 Drawing
        let oval4Path = UIBezierPath(ovalInRect: CGRectMake(21, 3, 6, 6))
        soundOneColor.setFill()
        oval4Path.fill()


        //// Oval 5 Drawing
        let oval5Path = UIBezierPath(ovalInRect: CGRectMake(12, 0, 6, 6))
        soundOneColor.setFill()
        oval5Path.fill()


        //// Oval 6 Drawing
        let oval6Path = UIBezierPath(ovalInRect: CGRectMake(3, 3, 6, 6))
        soundOneColor.setFill()
        oval6Path.fill()


        //// Oval 7 Drawing
        let oval7Path = UIBezierPath(ovalInRect: CGRectMake(0, 12, 6, 6))
        soundOneColor.setFill()
        oval7Path.fill()


        //// Oval 8 Drawing
        let oval8Path = UIBezierPath(ovalInRect: CGRectMake(3, 20, 6, 6))
        soundOneColor.setFill()
        oval8Path.fill()


        //// oval 9 Drawing
        let oval9Path = UIBezierPath()
        oval9Path.moveToPoint(CGPointMake(15, 30))
        oval9Path.addCurveToPoint(CGPointMake(18, 27), controlPoint1: CGPointMake(16.66, 30), controlPoint2: CGPointMake(18, 28.66))
        oval9Path.addCurveToPoint(CGPointMake(15, 24), controlPoint1: CGPointMake(18, 25.34), controlPoint2: CGPointMake(16.66, 24))
        oval9Path.addCurveToPoint(CGPointMake(12, 27), controlPoint1: CGPointMake(13.34, 24), controlPoint2: CGPointMake(12, 25.34))
        oval9Path.addCurveToPoint(CGPointMake(15, 30), controlPoint1: CGPointMake(12, 28.66), controlPoint2: CGPointMake(13.34, 30))
        oval9Path.closePath()
        oval9Path.usesEvenOddFillRule = true;

        soundOneColor.setFill()
        oval9Path.fill()
    }

    public class func drawSoundCanvasTwo(soundTwoSelected soundTwoSelected: Bool = false) {
        //// Color Declarations
        let selectedBlueColor = UIColor(red: 0.349, green: 0.733, blue: 0.961, alpha: 1.000)
        let optionButtonDeslected = UIColor(red: 0.800, green: 0.847, blue: 0.890, alpha: 0.141)

        //// Variable Declarations
        let soundTwoColor = soundTwoSelected ? selectedBlueColor : optionButtonDeslected

        //// soundButtonTwo
        //// Oval 1 Drawing
        let oval1Path = UIBezierPath(ovalInRect: CGRectMake(18, 9, 6, 6))
        soundTwoColor.setFill()
        oval1Path.fill()


        //// Oval 2 Drawing
        let oval2Path = UIBezierPath(ovalInRect: CGRectMake(9, 9, 6, 6))
        soundTwoColor.setFill()
        oval2Path.fill()


        //// Oval 3 Drawing
        let oval3Path = UIBezierPath(ovalInRect: CGRectMake(18, 0, 6, 6))
        soundTwoColor.setFill()
        oval3Path.fill()


        //// Oval 4 Drawing
        let oval4Path = UIBezierPath(ovalInRect: CGRectMake(9, 0, 6, 6))
        soundTwoColor.setFill()
        oval4Path.fill()


        //// Oval 5 Drawing
        let oval5Path = UIBezierPath(ovalInRect: CGRectMake(0, 0, 6, 6))
        soundTwoColor.setFill()
        oval5Path.fill()


        //// Oval 6 Drawing
        let oval6Path = UIBezierPath(ovalInRect: CGRectMake(0, 9, 6, 6))
        soundTwoColor.setFill()
        oval6Path.fill()


        //// Oval 7 Drawing
        let oval7Path = UIBezierPath()
        oval7Path.moveToPoint(CGPointMake(3, 24))
        oval7Path.addCurveToPoint(CGPointMake(6, 21), controlPoint1: CGPointMake(4.66, 24), controlPoint2: CGPointMake(6, 22.66))
        oval7Path.addCurveToPoint(CGPointMake(3, 18), controlPoint1: CGPointMake(6, 19.34), controlPoint2: CGPointMake(4.66, 18))
        oval7Path.addCurveToPoint(CGPointMake(0, 21), controlPoint1: CGPointMake(1.34, 18), controlPoint2: CGPointMake(0, 19.34))
        oval7Path.addCurveToPoint(CGPointMake(3, 24), controlPoint1: CGPointMake(0, 22.66), controlPoint2: CGPointMake(1.34, 24))
        oval7Path.closePath()
        oval7Path.usesEvenOddFillRule = true;

        soundTwoColor.setFill()
        oval7Path.fill()


        //// Oval 8 Drawing
        let oval8Path = UIBezierPath()
        oval8Path.moveToPoint(CGPointMake(12, 24))
        oval8Path.addCurveToPoint(CGPointMake(15, 21), controlPoint1: CGPointMake(13.66, 24), controlPoint2: CGPointMake(15, 22.66))
        oval8Path.addCurveToPoint(CGPointMake(12, 18), controlPoint1: CGPointMake(15, 19.34), controlPoint2: CGPointMake(13.66, 18))
        oval8Path.addCurveToPoint(CGPointMake(9, 21), controlPoint1: CGPointMake(10.34, 18), controlPoint2: CGPointMake(9, 19.34))
        oval8Path.addCurveToPoint(CGPointMake(12, 24), controlPoint1: CGPointMake(9, 22.66), controlPoint2: CGPointMake(10.34, 24))
        oval8Path.closePath()
        oval8Path.usesEvenOddFillRule = true;

        soundTwoColor.setFill()
        oval8Path.fill()


        //// Oval 9 Drawing
        let oval9Path = UIBezierPath()
        oval9Path.moveToPoint(CGPointMake(21, 24))
        oval9Path.addCurveToPoint(CGPointMake(24, 21), controlPoint1: CGPointMake(22.66, 24), controlPoint2: CGPointMake(24, 22.66))
        oval9Path.addCurveToPoint(CGPointMake(21, 18), controlPoint1: CGPointMake(24, 19.34), controlPoint2: CGPointMake(22.66, 18))
        oval9Path.addCurveToPoint(CGPointMake(18, 21), controlPoint1: CGPointMake(19.34, 18), controlPoint2: CGPointMake(18, 19.34))
        oval9Path.addCurveToPoint(CGPointMake(21, 24), controlPoint1: CGPointMake(18, 22.66), controlPoint2: CGPointMake(19.34, 24))
        oval9Path.closePath()
        oval9Path.usesEvenOddFillRule = true;

        soundTwoColor.setFill()
        oval9Path.fill()
    }

    public class func drawSoundCanvasThree(soundThreeSelected soundThreeSelected: Bool = false) {
        //// Color Declarations
        let selectedBlueColor = UIColor(red: 0.349, green: 0.733, blue: 0.961, alpha: 1.000)
        let optionButtonDeslected = UIColor(red: 0.800, green: 0.847, blue: 0.890, alpha: 0.141)

        //// Variable Declarations
        let soundThreeColor = soundThreeSelected ? selectedBlueColor : optionButtonDeslected

        //// soundButtonThree
        //// Oval 1 Drawing
        let oval1Path = UIBezierPath(ovalInRect: CGRectMake(13, 9, 6, 6))
        soundThreeColor.setFill()
        oval1Path.fill()


        //// Oval 2 Drawing
        let oval2Path = UIBezierPath(ovalInRect: CGRectMake(9, 0, 6, 6))
        soundThreeColor.setFill()
        oval2Path.fill()


        //// Oval 3 Drawing
        let oval3Path = UIBezierPath(ovalInRect: CGRectMake(4, 9, 6, 6))
        soundThreeColor.setFill()
        oval3Path.fill()


        //// Oval 4 Drawing
        let oval4Path = UIBezierPath()
        oval4Path.moveToPoint(CGPointMake(3, 24))
        oval4Path.addCurveToPoint(CGPointMake(6, 21), controlPoint1: CGPointMake(4.66, 24), controlPoint2: CGPointMake(6, 22.66))
        oval4Path.addCurveToPoint(CGPointMake(3, 18), controlPoint1: CGPointMake(6, 19.34), controlPoint2: CGPointMake(4.66, 18))
        oval4Path.addCurveToPoint(CGPointMake(0, 21), controlPoint1: CGPointMake(1.34, 18), controlPoint2: CGPointMake(0, 19.34))
        oval4Path.addCurveToPoint(CGPointMake(3, 24), controlPoint1: CGPointMake(0, 22.66), controlPoint2: CGPointMake(1.34, 24))
        oval4Path.closePath()
        oval4Path.usesEvenOddFillRule = true;

        soundThreeColor.setFill()
        oval4Path.fill()


        //// Oval 5 Drawing
        let oval5Path = UIBezierPath()
        oval5Path.moveToPoint(CGPointMake(12, 24))
        oval5Path.addCurveToPoint(CGPointMake(15, 21), controlPoint1: CGPointMake(13.66, 24), controlPoint2: CGPointMake(15, 22.66))
        oval5Path.addCurveToPoint(CGPointMake(12, 18), controlPoint1: CGPointMake(15, 19.34), controlPoint2: CGPointMake(13.66, 18))
        oval5Path.addCurveToPoint(CGPointMake(9, 21), controlPoint1: CGPointMake(10.34, 18), controlPoint2: CGPointMake(9, 19.34))
        oval5Path.addCurveToPoint(CGPointMake(12, 24), controlPoint1: CGPointMake(9, 22.66), controlPoint2: CGPointMake(10.34, 24))
        oval5Path.closePath()
        oval5Path.usesEvenOddFillRule = true;

        soundThreeColor.setFill()
        oval5Path.fill()


        //// Oval 6 Drawing
        let oval6Path = UIBezierPath()
        oval6Path.moveToPoint(CGPointMake(21, 24))
        oval6Path.addCurveToPoint(CGPointMake(24, 21), controlPoint1: CGPointMake(22.66, 24), controlPoint2: CGPointMake(24, 22.66))
        oval6Path.addCurveToPoint(CGPointMake(21, 18), controlPoint1: CGPointMake(24, 19.34), controlPoint2: CGPointMake(22.66, 18))
        oval6Path.addCurveToPoint(CGPointMake(18, 21), controlPoint1: CGPointMake(19.34, 18), controlPoint2: CGPointMake(18, 19.34))
        oval6Path.addCurveToPoint(CGPointMake(21, 24), controlPoint1: CGPointMake(18, 22.66), controlPoint2: CGPointMake(19.34, 24))
        oval6Path.closePath()
        oval6Path.usesEvenOddFillRule = true;

        soundThreeColor.setFill()
        oval6Path.fill()
    }

    public class func drawSoundCanvasFour(soundFourSelected soundFourSelected: Bool = false) {
        //// Color Declarations
        let selectedBlueColor = UIColor(red: 0.349, green: 0.733, blue: 0.961, alpha: 1.000)
        let optionButtonDeslected = UIColor(red: 0.800, green: 0.847, blue: 0.890, alpha: 0.141)

        //// Variable Declarations
        let soundFourColor = soundFourSelected ? selectedBlueColor : optionButtonDeslected

        //// soundButtonFour
        //// Oval 1 Drawing
        let oval1Path = UIBezierPath(ovalInRect: CGRectMake(18, 9, 6, 6))
        soundFourColor.setFill()
        oval1Path.fill()


        //// Oval 2 Drawing
        let oval2Path = UIBezierPath(ovalInRect: CGRectMake(9, 9, 6, 6))
        soundFourColor.setFill()
        oval2Path.fill()


        //// Oval 3 Drawing
        let oval3Path = UIBezierPath(ovalInRect: CGRectMake(18, 0, 6, 6))
        soundFourColor.setFill()
        oval3Path.fill()


        //// Oval 4 Drawing
        let oval4Path = UIBezierPath(ovalInRect: CGRectMake(9, 0, 6, 6))
        soundFourColor.setFill()
        oval4Path.fill()


        //// Oval 5 Drawing
        let oval5Path = UIBezierPath(ovalInRect: CGRectMake(0, 9, 6, 6))
        soundFourColor.setFill()
        oval5Path.fill()


        //// Oval 6 Drawing
        let oval6Path = UIBezierPath()
        oval6Path.moveToPoint(CGPointMake(3, 24))
        oval6Path.addCurveToPoint(CGPointMake(6, 21), controlPoint1: CGPointMake(4.66, 24), controlPoint2: CGPointMake(6, 22.66))
        oval6Path.addCurveToPoint(CGPointMake(3, 18), controlPoint1: CGPointMake(6, 19.34), controlPoint2: CGPointMake(4.66, 18))
        oval6Path.addCurveToPoint(CGPointMake(0, 21), controlPoint1: CGPointMake(1.34, 18), controlPoint2: CGPointMake(0, 19.34))
        oval6Path.addCurveToPoint(CGPointMake(3, 24), controlPoint1: CGPointMake(0, 22.66), controlPoint2: CGPointMake(1.34, 24))
        oval6Path.closePath()
        oval6Path.usesEvenOddFillRule = true;

        soundFourColor.setFill()
        oval6Path.fill()


        //// Oval 7 Drawing
        let oval7Path = UIBezierPath()
        oval7Path.moveToPoint(CGPointMake(12, 24))
        oval7Path.addCurveToPoint(CGPointMake(15, 21), controlPoint1: CGPointMake(13.66, 24), controlPoint2: CGPointMake(15, 22.66))
        oval7Path.addCurveToPoint(CGPointMake(12, 18), controlPoint1: CGPointMake(15, 19.34), controlPoint2: CGPointMake(13.66, 18))
        oval7Path.addCurveToPoint(CGPointMake(9, 21), controlPoint1: CGPointMake(10.34, 18), controlPoint2: CGPointMake(9, 19.34))
        oval7Path.addCurveToPoint(CGPointMake(12, 24), controlPoint1: CGPointMake(9, 22.66), controlPoint2: CGPointMake(10.34, 24))
        oval7Path.closePath()
        oval7Path.usesEvenOddFillRule = true;

        soundFourColor.setFill()
        oval7Path.fill()
    }

}
