//
//  ChartLabelDrawer.swift
//  SwiftCharts
//
//  Created by ischuetz on 25/04/15.
//  Copyright (c) 2015 ivanschuetz. All rights reserved.
//

import UIKit

public class ChartLabelSettings {
    let font: UIFont
    let fontColor: UIColor
    let rotation: CGFloat
    let rotationKeep: ChartLabelDrawerRotationKeep
    let shiftXOnRotation: Bool
    
    public init(font: UIFont = UIFont.systemFontOfSize(14), fontColor: UIColor = UIColor.blackColor(), rotation: CGFloat = 0, rotationKeep: ChartLabelDrawerRotationKeep = .Center, shiftXOnRotation: Bool = true) {
        self.font = font
        self.fontColor = fontColor
        self.rotation = rotation
        self.rotationKeep = rotationKeep
        self.shiftXOnRotation = shiftXOnRotation
    }
}

public class ChartAxisYLabelSettings: ChartLabelSettings {
    override public init(font: UIFont = UIFont.systemFontOfSize(14), fontColor: UIColor = UIColor.blackColor(), rotation: CGFloat = -90, rotationKeep: ChartLabelDrawerRotationKeep = .Center, shiftXOnRotation: Bool = true) {
        super.init(font: font, fontColor: fontColor, rotation: rotation, rotationKeep: rotationKeep, shiftXOnRotation: shiftXOnRotation)
    }
}

// coordinate of original label which will be preserved after the rotation
public enum ChartLabelDrawerRotationKeep {
    case Center, Top, Bottom
}

public class ChartLabelDrawer: ChartContextDrawer {
    
    private let text: String
    
    private let settings: ChartLabelSettings
    private let screenLoc: CGPoint
    
    private var transform: CGAffineTransform?
    
    var size: CGSize {
        return ChartUtils.textSize(self.text, font: self.settings.font)
    }
    
    init(text: String, screenLoc: CGPoint, settings: ChartLabelSettings) {
        self.text = text
        self.screenLoc = screenLoc
        self.settings = settings
        
        super.init()
        
        self.transform = self.transform(screenLoc, settings: settings)
    }

    override func draw(#context: CGContextRef, chart: Chart) {
        let labelSize = self.size
        
        let labelX = self.screenLoc.x
        let labelY = self.screenLoc.y
        
        func drawLabel() {
            self.drawLabel(x: labelX, y: labelY, text: self.text)
        }
        
        if let transform = self.transform {
            CGContextSaveGState(context)
            CGContextConcatCTM(context, transform)
            drawLabel()
            CGContextRestoreGState(context)

        } else {
            drawLabel()
        }
    }
    
    private func transform(screenLoc: CGPoint, settings: ChartLabelSettings) -> CGAffineTransform? {
        let labelSize = self.size
        
        let labelX = screenLoc.x
        let labelY = screenLoc.y
        
        let labelHalfWidth = labelSize.width / 2
        let labelHalfHeight = labelSize.height / 2
        
        if settings.rotation != 0 {


            let centerX = labelX + labelHalfWidth
            let centerY = labelY + labelHalfHeight
            
            let rotation = settings.rotation * CGFloat(M_PI) / CGFloat(180)

            
            var transform = CGAffineTransformIdentity
            
            if settings.rotationKeep == .Center {
                transform = CGAffineTransformMakeTranslation(-(labelHalfWidth - labelHalfHeight), 0)
                
            } else {
                
                var transformToGetBounds = CGAffineTransformMakeTranslation(0, 0)
                transformToGetBounds = CGAffineTransformTranslate(transformToGetBounds, centerX, centerY)
                transformToGetBounds = CGAffineTransformRotate(transformToGetBounds, rotation)
                transformToGetBounds = CGAffineTransformTranslate(transformToGetBounds, -centerX, -centerY)
                let rect = CGRectMake(labelX, labelY, labelSize.width, labelSize.height)
                let newRect = CGRectApplyAffineTransform(rect, transformToGetBounds)

                let offsetTop: CGFloat = {
                    switch settings.rotationKeep {
                    case .Top:
                        return labelY - newRect.origin.y
                    case .Bottom:
                        return newRect.origin.y + newRect.size.height - (labelY + rect.size.height)
                    default:
                        return 0
                    }
                }()
                
                // when the labels are diagonal we have to shift a little so they look aligned with axis value. We align origin of new rect with the axis value
                if settings.shiftXOnRotation {
                    let xOffset: CGFloat = abs(settings.rotation) == 90 ? 0 : centerX - newRect.origin.x
                    let newLabelX = labelX - xOffset
                    transform = CGAffineTransformTranslate(transform, xOffset, offsetTop)
                }
            }

            transform = CGAffineTransformTranslate(transform, centerX, centerY)
            transform = CGAffineTransformRotate(transform, rotation)
            transform = CGAffineTransformTranslate(transform, -centerX, -centerY)
            return transform
            
        } else {
            return nil
        }
    }

    
    private func drawLabel(#x: CGFloat, y: CGFloat, text: String) {
        let attributes = [NSFontAttributeName: self.settings.font, NSForegroundColorAttributeName: self.settings.fontColor]
        let attrStr = NSAttributedString(string: text, attributes: attributes)
        attrStr.drawAtPoint(CGPointMake(x, y))
    }
}
