//
//  ChartCandleStickView.swift
//  SwiftCharts
//
//  Created by ischuetz on 29/04/15.
//  Copyright (c) 2015 ivanschuetz. All rights reserved.
//

import UIKit

public class ChartCandleStickView: UIView {

    private let innerRect: CGRect
    
    private let fillColor: UIColor
    private let strokeColor: UIColor
    
    private var currentFillColor: UIColor
    private var currentStrokeColor: UIColor
    
    private let highlightColor = UIColor.redColor()
   
    private let strokeWidth: CGFloat
    
    var highlighted: Bool = false {
        didSet {
            if self.highlighted {
                self.currentFillColor = self.highlightColor
                self.currentStrokeColor = self.highlightColor
            } else {
                self.currentFillColor = self.fillColor
                self.currentStrokeColor = self.strokeColor
            }
            self.setNeedsDisplay()
        }
    }
    
    public init(lineX: CGFloat, width: CGFloat, top: CGFloat, bottom: CGFloat, innerRectTop: CGFloat, innerRectBottom: CGFloat, fillColor: UIColor, strokeColor: UIColor = UIColor.blackColor(), strokeWidth: CGFloat = 1) {
        
        let frameX = lineX - width / CGFloat(2)
        let frame = CGRectMake(frameX, top, width, bottom - top)
        let t = innerRectTop - top
        let hsw = strokeWidth / 2
        self.innerRect = CGRectMake(hsw, t + hsw, width - strokeWidth, innerRectBottom - top - t - strokeWidth)

        self.fillColor = fillColor
        self.strokeColor = strokeColor
        
        self.currentFillColor = fillColor
        self.currentStrokeColor = strokeColor
        self.strokeWidth = strokeWidth
        
        super.init(frame: frame)
        
        self.backgroundColor = UIColor.clearColor()
    }

    required public init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func drawRect(rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()

        let wHalf = self.frame.width / 2
        
        CGContextSetLineWidth(context, self.strokeWidth)
        CGContextSetStrokeColorWithColor(context, self.currentStrokeColor.CGColor)
        CGContextMoveToPoint(context, wHalf, 0)
        CGContextAddLineToPoint(context, wHalf, self.frame.height)
        
        CGContextStrokePath(context)
        
        CGContextSetRGBFillColor(context, 1.0, 1.0, 1.0, 0.0)
        CGContextSetFillColorWithColor(context, self.currentFillColor.CGColor)
        CGContextFillRect(context, self.innerRect)
        CGContextStrokeRect(context, self.innerRect)
    }
   

}
