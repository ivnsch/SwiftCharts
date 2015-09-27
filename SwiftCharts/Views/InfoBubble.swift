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
public class InfoBubble: UIView {

    private let arrowWidth: CGFloat
    private let arrowHeight: CGFloat
    private let bgColor: UIColor
    private let arrowX: CGFloat
    
    public init(frame: CGRect, arrowWidth: CGFloat, arrowHeight: CGFloat, bgColor: UIColor = UIColor.whiteColor(), arrowX: CGFloat) {
        self.arrowWidth = arrowWidth
        self.arrowHeight = arrowHeight
        self.bgColor = bgColor

        let arrowHalf = arrowWidth / 2
        self.arrowX = max(arrowHalf, min(frame.size.width - arrowHalf, arrowX))
        super.init(frame: frame)
        self.backgroundColor = UIColor.clearColor()
    }

    required public init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func drawRect(rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        CGContextSetFillColorWithColor(context, self.bgColor.CGColor)
        CGContextSetStrokeColorWithColor(context, self.bgColor.CGColor)
        let rrect = CGRectInset(rect, 0, 20)
        
        let minx = CGRectGetMinX(rrect), maxx = CGRectGetMaxX(rrect)
        let miny = CGRectGetMinY(rrect), maxy = CGRectGetMaxY(rrect)
        
        let outlinePath = CGPathCreateMutable()
        
        CGPathMoveToPoint(outlinePath, nil, minx, miny)
        CGPathAddLineToPoint(outlinePath, nil, maxx, miny)
        CGPathAddLineToPoint(outlinePath, nil, maxx, maxy)
        CGPathAddLineToPoint(outlinePath, nil, self.arrowX + self.arrowWidth / 2, maxy)
        CGPathAddLineToPoint(outlinePath, nil, self.arrowX, maxy + self.arrowHeight)
        CGPathAddLineToPoint(outlinePath, nil, self.arrowX - self.arrowWidth / 2, maxy)

        CGPathAddLineToPoint(outlinePath, nil, minx, maxy)
        
        CGPathCloseSubpath(outlinePath)

        CGContextAddPath(context, outlinePath)
        CGContextFillPath(context)
    }
}
