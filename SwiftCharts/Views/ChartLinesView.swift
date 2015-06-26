//
//  ChartLinesView.swift
//  swift_charts
//
//  Created by ischuetz on 11/04/15.
//  Copyright (c) 2015 ivanschuetz. All rights reserved.
//

import UIKit

public protocol ChartLinesViewPathGenerator {
    func generatePath(points points: [CGPoint], lineWidth: CGFloat) -> UIBezierPath
}

public class ChartLinesView: UIView {

    private let lineColor: UIColor
    private let lineWidth: CGFloat
    private let animDuration: Float
    private let animDelay: Float

    init(path: UIBezierPath, frame: CGRect, lineColor: UIColor, lineWidth: CGFloat, animDuration: Float, animDelay: Float) {
        
        self.lineColor = lineColor
        self.lineWidth = lineWidth
        self.animDuration = animDuration
        self.animDelay = animDelay
        
        super.init(frame: frame)

        self.backgroundColor = UIColor.clearColor()
        self.show(path: path)
    }

    required public init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func createLineMask(frame frame: CGRect) -> CALayer {
        let lineMaskLayer = CAShapeLayer()
        var maskRect = frame
        maskRect.origin.y = 0
        maskRect.size.height = frame.size.height
        let path = CGPathCreateWithRect(maskRect, nil)
        
        lineMaskLayer.path = path
        
        return lineMaskLayer
    }

    private func generateLayer(path path: UIBezierPath) -> CAShapeLayer {
        let lineLayer = CAShapeLayer()
        lineLayer.lineJoin = kCALineJoinBevel
        lineLayer.fillColor   = UIColor.clearColor().CGColor
        lineLayer.lineWidth   = self.lineWidth
        
        lineLayer.path = path.CGPath;
        lineLayer.strokeColor = self.lineColor.CGColor;
        
        if self.animDuration > 0 {
            lineLayer.strokeEnd   = 0.0
            let pathAnimation = CABasicAnimation(keyPath: "strokeEnd")
            pathAnimation.duration = CFTimeInterval(self.animDuration)
            pathAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
            pathAnimation.fromValue = NSNumber(float: 0)
            pathAnimation.toValue = NSNumber(float: 1)
            pathAnimation.autoreverses = false
            pathAnimation.removedOnCompletion = false
            pathAnimation.fillMode = kCAFillModeForwards
            
            pathAnimation.beginTime = CACurrentMediaTime() + CFTimeInterval(self.animDelay)
            lineLayer.addAnimation(pathAnimation, forKey: "strokeEndAnimation")
            
        } else {
            lineLayer.strokeEnd = 1
        }
        
        return lineLayer
    }
    
    private func show(path path: UIBezierPath) {
        let lineMask = self.createLineMask(frame: frame)
        self.layer.mask = lineMask
        self.layer.addSublayer(self.generateLayer(path: path))
    }
 }
