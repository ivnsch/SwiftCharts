//
//  ChartLabelDrawer.swift
//  SwiftCharts
//
//  Created by ischuetz on 25/04/15.
//  Copyright (c) 2015 ivanschuetz. All rights reserved.
//

import UIKit

public enum ChartLabelTextAlignment {
    case left, right, `default`
}

open class ChartLabelSettings {
    let font: UIFont
    let fontColor: UIColor
    let rotation: CGFloat
    let rotationKeep: ChartLabelDrawerRotationKeep
    let shiftXOnRotation: Bool
    let textAlignment: ChartLabelTextAlignment
    
    public init(font: UIFont = UIFont.systemFont(ofSize: 14), fontColor: UIColor = UIColor.black, rotation: CGFloat = 0, rotationKeep: ChartLabelDrawerRotationKeep = .center, shiftXOnRotation: Bool = true, textAlignment: ChartLabelTextAlignment = .default) {
        self.font = font
        self.fontColor = fontColor
        self.rotation = rotation
        self.rotationKeep = rotationKeep
        self.shiftXOnRotation = shiftXOnRotation
        self.textAlignment = textAlignment
    }
    
    open func copy(_ font: UIFont? = nil, fontColor: UIColor? = nil, rotation: CGFloat? = nil, rotationKeep: ChartLabelDrawerRotationKeep? = nil, shiftXOnRotation: Bool? = nil) -> ChartLabelSettings {
        return ChartLabelSettings(
            font: font ?? self.font,
            fontColor: fontColor ?? self.fontColor,
            rotation: rotation ?? self.rotation,
            rotationKeep: rotationKeep ?? self.rotationKeep,
            shiftXOnRotation: shiftXOnRotation ?? self.shiftXOnRotation)
    }
}

public extension ChartLabelSettings {
    public func defaultVertical() -> ChartLabelSettings {
        return self.copy(rotation: -90)
    }
}

// coordinate of original label which will be preserved after the rotation
public enum ChartLabelDrawerRotationKeep {
    case center, top, bottom
}

open class ChartLabelDrawer: ChartContextDrawer {
    
    fileprivate let text: String
    
    fileprivate let settings: ChartLabelSettings
    var screenLoc: CGPoint
    
    fileprivate var transform: CGAffineTransform?
    
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

    override func draw(context: CGContext, chart: Chart) {
        let labelSize = self.size
        
        let labelX = self.screenLoc.x
        let labelY = self.screenLoc.y
        
        func drawLabel() {
            self.drawLabel(x: labelX, y: labelY, text: self.text)
        }
        
        if let transform = self.transform {
            context.saveGState()
            context.concatenate(transform)
            drawLabel()
            context.restoreGState()

        } else {
            drawLabel()
        }
    }
    
    fileprivate func transform(_ screenLoc: CGPoint, settings: ChartLabelSettings) -> CGAffineTransform? {
        let labelSize = self.size
        
        let labelX = screenLoc.x
        let labelY = screenLoc.y
        
        let labelHalfWidth = labelSize.width / 2
        let labelHalfHeight = labelSize.height / 2
        
        if settings.rotation != 0 {


            let centerX = labelX + labelHalfWidth
            let centerY = labelY + labelHalfHeight
            
            let rotation = settings.rotation * CGFloat(M_PI) / CGFloat(180)

            
            var transform = CGAffineTransform.identity
            
            if settings.rotationKeep == .center {
                transform = CGAffineTransform(translationX: -(labelHalfWidth - labelHalfHeight), y: 0)
                
            } else {
                
                var transformToGetBounds = CGAffineTransform(translationX: 0, y: 0)
                transformToGetBounds = transformToGetBounds.translatedBy(x: centerX, y: centerY)
                transformToGetBounds = transformToGetBounds.rotated(by: rotation)
                transformToGetBounds = transformToGetBounds.translatedBy(x: -centerX, y: -centerY)
                let rect = CGRect(x: labelX, y: labelY, width: labelSize.width, height: labelSize.height)
                let newRect = rect.applying(transformToGetBounds)

                let offsetTop: CGFloat = {
                    switch settings.rotationKeep {
                    case .top:
                        return labelY - newRect.origin.y
                    case .bottom:
                        return newRect.origin.y + newRect.size.height - (labelY + rect.size.height)
                    default:
                        return 0
                    }
                }()
                
                // when the labels are diagonal we have to shift a little so they look aligned with axis value. We align origin of new rect with the axis value
                if settings.shiftXOnRotation {
                    let xOffset: CGFloat = abs(settings.rotation) == 90 ? 0 : centerX - newRect.origin.x
                    transform = transform.translatedBy(x: xOffset, y: offsetTop)
                }
            }

            transform = transform.translatedBy(x: centerX, y: centerY)
            transform = transform.rotated(by: rotation)
            transform = transform.translatedBy(x: -centerX, y: -centerY)
            return transform
            
        } else {
            return nil
        }
    }

    
    fileprivate func drawLabel(x: CGFloat, y: CGFloat, text: String) {
        let attributes = [NSFontAttributeName: self.settings.font, NSForegroundColorAttributeName: self.settings.fontColor]
        let attrStr = NSAttributedString(string: text, attributes: attributes)
        attrStr.draw(at: CGPoint(x: x, y: y))
    }
}
