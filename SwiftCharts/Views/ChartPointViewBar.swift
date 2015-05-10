//
//  ChartPointViewBar.swift
//  swift_charts
//
//  Created by ischuetz on 15/04/15.
//  Copyright (c) 2015 ivanschuetz. All rights reserved.
//

import UIKit

public class ChartPointViewBar: UIView {

    private let targetFrame: CGRect
    private let greyOut: Bool
    
    public init(chartPoint: ChartPoint, screenLoc: CGPoint, barWidth: CGFloat, bottomLeft: CGPoint, color: UIColor, horizontal: Bool = false, greyOut: Bool = false) {
        self.targetFrame =  ChartPointViewBar.barRectForPoint(screenLoc, barWidth, bottomLeft, horizontal)
        self.greyOut = greyOut

        if horizontal {
            super.init(frame: CGRectMake(self.targetFrame.origin.x, self.targetFrame.origin.y, 0, self.targetFrame.size.height))
        } else {
            super.init(frame: CGRectMake(self.targetFrame.origin.x, self.targetFrame.origin.y, self.targetFrame.width, 0))
        }
        
        self.backgroundColor = color
    }

    required public init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func didMoveToSuperview() {
        UIView.animateWithDuration(0.5, delay: 0.0, options: UIViewAnimationOptions.CurveEaseOut, animations: { () -> Void in
            self.frame = self.targetFrame
        }, completion: nil)
        
        if self.greyOut {
            UIView.animateWithDuration(0.5, delay: 1.0, options: UIViewAnimationOptions.CurveEaseOut, animations: { () -> Void in
                self.backgroundColor = UIColor.grayColor()
            }, completion: nil)
        }
    }
    
    class func barRectForPoint(point: CGPoint, _ barWidth: CGFloat, _ origin: CGPoint, _ horizontal: Bool) -> CGRect {
        if horizontal {
            return CGRectMake(origin.x, point.y - (barWidth / 2), point.x - origin.x, barWidth)
        } else {
            let barHeight = origin.y - point.y
            return CGRectMake(point.x - CGFloat(barWidth / 2), point.y + barHeight, CGFloat(barWidth), -CGFloat(barHeight))
        }
    }
}
