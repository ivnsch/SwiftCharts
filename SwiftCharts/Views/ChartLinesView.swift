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

    public let lineColor: UIColor
    public let lineWidth: CGFloat
    public let lineJoin: LineJoin
    public let lineCap: LineCap
    public let animDuration: Float
    public let animDelay: Float
    public let dashPattern: [Double]?
    
    public init(path: UIBezierPath, frame: CGRect, lineColor: UIColor, lineWidth: CGFloat, lineJoin: LineJoin, lineCap: LineCap, animDuration: Float, animDelay: Float, dashPattern: [Double]?) {
        self.lineColor = lineColor
        self.lineWidth = lineWidth
        self.lineJoin = lineJoin
        self.lineCap = lineCap
        self.animDuration = animDuration
        self.animDelay = animDelay
        self.dashPattern = dashPattern
        
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

    public func generateLayer(path path: UIBezierPath) -> CAShapeLayer {
        let lineLayer = CAShapeLayer()
        lineLayer.lineJoin = lineJoin.CALayerString
        lineLayer.lineCap = lineCap.CALayerString
        lineLayer.fillColor = UIColor.clearColor().CGColor
        lineLayer.lineWidth = self.lineWidth
        
        lineLayer.path = path.CGPath;
        lineLayer.strokeColor = self.lineColor.CGColor;
        
        if self.animDuration > 0 {
            lineLayer.strokeEnd = 0.0
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
            
            if self.dashPattern != nil {
                lineLayer.lineDashPattern = dashPattern
            }
        } else {
            lineLayer.strokeEnd = 1
        }
        
        return lineLayer
    }
    
    private func show(path path: UIBezierPath) {
        self.layer.addSublayer(self.generateLayer(path: path))
    }
 }
