//
//  ChartPointTargetingView.swift
//  swift_charts
//
//  Created by ischuetz on 15/04/15.
//  Copyright (c) 2015 ivanschuetz. All rights reserved.
//

import UIKit

public class ChartPointTargetingView: UIView {

    private let animDuration: Float
    private let animDelay: Float
    
    private let lineHorizontal: UIView
    private let lineVertical: UIView
  
    private let lineWidth = 1
    
    private let lineHorizontalTargetFrame: CGRect
    private let lineVerticalTargetFrame: CGRect
    
    public init(chartPoint: ChartPoint, screenLoc: CGPoint, animDuration: Float, animDelay: Float, frame: CGRect, layer: ChartCoordsSpaceLayer) {
        self.animDuration = animDuration
        self.animDelay = animDelay
      
        let chartInnerFrame = layer.innerFrame
        
        let axisOriginX = chartInnerFrame.origin.x
        let axisOriginY = chartInnerFrame.origin.y
        let axisLengthX = chartInnerFrame.width
        let axisLengthY = chartInnerFrame.height
        
        self.lineHorizontal = UIView(frame: CGRectMake(axisOriginX, axisOriginY, axisLengthX, CGFloat(lineWidth)))
        self.lineVertical = UIView(frame: CGRectMake(axisOriginX, axisOriginY, CGFloat(lineWidth), axisLengthY))
        
        self.lineHorizontal.backgroundColor = UIColor.blackColor()
        self.lineVertical.backgroundColor = UIColor.redColor()
        
        let lineWidthHalf = self.lineWidth / 2
        var targetFrameH = lineHorizontal.frame
        targetFrameH.origin.y = screenLoc.y - CGFloat(lineWidthHalf)
        self.lineHorizontalTargetFrame = targetFrameH
        var targetFrameV = lineVertical.frame
        targetFrameV.origin.x = screenLoc.x - CGFloat(lineWidthHalf)
        self.lineVerticalTargetFrame = targetFrameV
 
        super.init(frame: frame)
    }

    required public init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func didMoveToSuperview() {
        addSubview(self.lineHorizontal)
        addSubview(self.lineVertical)
        
        UIView.animateWithDuration(NSTimeInterval(self.animDuration), delay: NSTimeInterval(self.animDelay), options: UIViewAnimationOptions.CurveEaseOut, animations: { () -> Void in
            
            self.lineHorizontal.frame = self.lineHorizontalTargetFrame
            self.lineVertical.frame = self.lineVerticalTargetFrame
            
            }) { (Bool) -> Void in
        }
    }
}
