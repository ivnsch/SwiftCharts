//
//  InfoBubble.swift
//  SwiftCharts
//
//  Created by ischuetz on 11/04/15.
//  Copyright (c) 2015 ivanschuetz. All rights reserved.
//

import UIKit

// Quick implementation of info bubble, for demonstration purposes
// For serious usage you may consider using a library specialized in this e.g. CMPopTipView
open class InfoBubble: UIView {

    fileprivate let arrowWidth: CGFloat
    fileprivate let arrowHeight: CGFloat
    fileprivate let bgColor: UIColor
    fileprivate let arrowX: CGFloat
    
    public init(frame: CGRect, arrowWidth: CGFloat, arrowHeight: CGFloat, bgColor: UIColor = UIColor.white, arrowX: CGFloat) {
        self.arrowWidth = arrowWidth
        self.arrowHeight = arrowHeight
        self.bgColor = bgColor

        let arrowHalf = arrowWidth / 2
        self.arrowX = max(arrowHalf, min(frame.size.width - arrowHalf, arrowX))
        super.init(frame: frame)
        self.backgroundColor = UIColor.clear
    }

    required public init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override open func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else {
            return
        }
        context.setFillColor(self.bgColor.cgColor)
        context.setStrokeColor(self.bgColor.cgColor)
        let rrect = rect.insetBy(dx: 0, dy: 20)
        
        let minx = rrect.minX, maxx = rrect.maxX
        let miny = rrect.minY, maxy = rrect.maxY
        
        let outlinePath = CGMutablePath()

        outlinePath.move(to: CGPoint(x: minx, y: miny))
        outlinePath.addLine(to: CGPoint(x: maxx, y: miny))
        outlinePath.addLine(to: CGPoint(x: maxx, y: maxy))
        outlinePath.addLine(to: CGPoint(x: self.arrowX + self.arrowWidth / 2, y: maxy))
        outlinePath.addLine(to: CGPoint(x: self.arrowX, y: maxy + self.arrowHeight))
        outlinePath.addLine(to: CGPoint(x: self.arrowX - self.arrowWidth / 2, y: maxy))

        outlinePath.addLine(to: CGPoint(x: minx, y: maxy))
        
        outlinePath.closeSubpath()

        context.addPath(outlinePath)
        context.fillPath()
    }
}
