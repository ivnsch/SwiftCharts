//
//  ChartPointEllipseView.swift
//  SwiftCharts
//
//  Created by ischuetz on 19/04/15.
//  Copyright (c) 2015 ivanschuetz. All rights reserved.
//

import UIKit

public class ChartPointEllipseView: UIView {
    
    public var fillColor: UIColor = UIColor.grayColor()
    public var borderColor: UIColor? = nil
    public var borderWidth: CGFloat? = nil
    public var animDelay: Float = 0
    public var animDuration: Float = 0
    public var animateSize: Bool = true
    public var animateAlpha: Bool = true
    public var animDamping: CGFloat = 1
    public var animInitSpringVelocity: CGFloat = 1
    
    public var touchHandler: (() -> ())?

    convenience public init(center: CGPoint, diameter: CGFloat) {
        self.init(center: center, width: diameter, height: diameter)
    }
    
    public init(center: CGPoint, width: CGFloat, height: CGFloat) {
        super.init(frame: CGRectMake(center.x - width / 2, center.y - height / 2, width, height))
        self.backgroundColor = UIColor.clearColor()
    }

    required public init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
   
    override public func didMoveToSuperview() {
        if self.animDuration != 0 {
            if self.animateSize {
                self.transform = CGAffineTransformMakeScale(0.1, 0.1)
            }
            if self.animateAlpha {
                self.alpha = 0
            }
            
            UIView.animateWithDuration(NSTimeInterval(self.animDuration), delay: NSTimeInterval(self.animDelay), usingSpringWithDamping: self.animDamping, initialSpringVelocity: self.animInitSpringVelocity, options: UIViewAnimationOptions(), animations: { () -> Void in
                if self.animateSize {
                    self.transform = CGAffineTransformMakeScale(1, 1)
                }
                if self.animateAlpha {
                    self.alpha = 1
                }
            }, completion: nil)
        }
    }
    
    override public func drawRect(rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()

        let borderOffset = self.borderWidth ?? 0
        let circleRect = (CGRectMake(borderOffset, borderOffset, self.frame.size.width - (borderOffset * 2), self.frame.size.height - (borderOffset * 2)))
        
        if let borderWidth = self.borderWidth, borderColor = self.borderColor {
            CGContextSetLineWidth(context, borderWidth)
            CGContextSetStrokeColorWithColor(context, borderColor.CGColor)
            CGContextStrokeEllipseInRect(context, circleRect)
        }
        CGContextSetFillColorWithColor(context, self.fillColor.CGColor)
        CGContextFillEllipseInRect(context, circleRect)
    }
    
    override public func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.touchHandler?()
    }
}
