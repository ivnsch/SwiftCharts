//
//  ChartPointTargetingView.swift
//  swift_charts
//
//  Created by ischuetz on 15/04/15.
//  Copyright (c) 2015 ivanschuetz. All rights reserved.
//

import UIKit

open class ChartPointTargetingView: UIView {

    fileprivate let animDuration: Float
    fileprivate let animDelay: Float
    
    fileprivate let lineHorizontal: UIView
    fileprivate let lineVertical: UIView
  
    fileprivate let lineWidth = 1
    
    fileprivate let lineHorizontalTargetFrame: CGRect
    fileprivate let lineVerticalTargetFrame: CGRect
    
    public init(chartPoint: ChartPoint, screenLoc: CGPoint, animDuration: Float, animDelay: Float, frame: CGRect, layer: ChartCoordsSpaceLayer) {
        self.animDuration = animDuration
        self.animDelay = animDelay
      
        let chartInnerFrame = layer.innerFrame
        
        let axisOriginX = chartInnerFrame.origin.x
        let axisOriginY = chartInnerFrame.origin.y
        let axisLengthX = chartInnerFrame.width
        let axisLengthY = chartInnerFrame.height
        
        self.lineHorizontal = UIView(frame: CGRect(x: axisOriginX, y: axisOriginY, width: axisLengthX, height: CGFloat(lineWidth)))
        self.lineVertical = UIView(frame: CGRect(x: axisOriginX, y: axisOriginY, width: CGFloat(lineWidth), height: axisLengthY))
        
        self.lineHorizontal.backgroundColor = UIColor.black
        self.lineVertical.backgroundColor = UIColor.red
        
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

    override open func didMoveToSuperview() {
        addSubview(self.lineHorizontal)
        addSubview(self.lineVertical)
        
        UIView.animate(withDuration: TimeInterval(self.animDuration), delay: TimeInterval(self.animDelay), options: UIViewAnimationOptions.curveEaseOut, animations: { () -> Void in
            
            self.lineHorizontal.frame = self.lineHorizontalTargetFrame
            self.lineVertical.frame = self.lineVerticalTargetFrame
            
            }) { (Bool) -> Void in
        }
    }
}
