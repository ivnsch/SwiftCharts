//
//  ChartPointViewBar.swift
//  Examples
//
//  Created by ischuetz on 14/05/15.
//  Copyright (c) 2015 ivanschuetz. All rights reserved.
//

import UIKit

public class ChartPointViewBar: UIView {
    
    private let targetFrame: CGRect
    private let greyOut: Bool
    
    private let animDuration: Float
    private let greyOutDelay: Float
    private let greyOutAnimDuration: Float
    
    init(chartPoint: ChartPoint, p1: CGPoint, p2: CGPoint, width: CGFloat, color: UIColor, animDuration: Float = 0.5, greyOut: Bool = false, greyOutDelay: Float = 1, greyOutAnimDuration: Float = 0.5) {
        
        let (targetFrame: CGRect, firstFrame: CGRect) = {
            if p1.y - p2.y == 0 { // horizontal
                let targetFrame = CGRectMake(p1.x, p1.y - width / 2, p2.x - p1.x, width)
                let initFrame = CGRectMake(targetFrame.origin.x, targetFrame.origin.y, 0, targetFrame.size.height)
                return (targetFrame, initFrame)
                
            } else { // vertical
                let targetFrame = CGRectMake(p1.x - width / 2, p1.y, width, p2.y - p1.y)
                let initFrame = CGRectMake(targetFrame.origin.x, targetFrame.origin.y, targetFrame.size.width, 0)
                return (targetFrame, initFrame)
            }
        }()
        
        self.targetFrame =  targetFrame
        self.animDuration = animDuration
        self.greyOut = greyOut
        self.greyOutDelay = greyOutDelay
        self.greyOutAnimDuration = greyOutAnimDuration
        
        super.init(frame: firstFrame)
        
        self.backgroundColor = color
    }
    
    required public init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func didMoveToSuperview() {
        UIView.animateWithDuration(CFTimeInterval(self.animDuration), delay: 0.0, options: UIViewAnimationOptions.CurveEaseOut, animations: {() -> Void in
            self.frame = self.targetFrame
        }, completion: nil)
        
        if self.greyOut {
            UIView.animateWithDuration(CFTimeInterval(self.greyOutAnimDuration), delay: CFTimeInterval(self.greyOutDelay), options: UIViewAnimationOptions.CurveEaseOut, animations: {() -> Void in
                self.backgroundColor = UIColor.grayColor()
            }, completion: nil)
        }
    }
}