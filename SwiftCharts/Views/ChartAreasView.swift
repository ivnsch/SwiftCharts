//
//  ChartAreasView.swift
//  swift_charts
//
//  Created by ischuetz on 18/04/15.
//  Copyright (c) 2015 ivanschuetz. All rights reserved.
//

import UIKit

public class ChartAreasView: UIView {

    private let animDuration: Float
    private let color: UIColor
    private let animDelay: Float
    
    public init(points: [CGPoint], frame: CGRect, color: UIColor, animDuration: Float, animDelay: Float) {
        self.color = color
        self.animDuration = animDuration
        self.animDelay = animDelay
        
        super.init(frame: frame)

        self.backgroundColor = UIColor.clearColor()
        self.show(path: self.generateAreaPath(points: points))
    }
    
    required public init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func generateAreaPath(points points: [CGPoint]) -> UIBezierPath {
        
        let progressline = UIBezierPath()
        progressline.lineWidth = 1.0
        progressline.lineCapStyle = .Round
        progressline.lineJoinStyle = .Round
        
        if let p = points.first {
            progressline.moveToPoint(p)
        }
        
        for i in 1..<points.count {
            let p = points[i]
            progressline.addLineToPoint(p)
        }
        
        progressline.closePath()
        
        return progressline
    }
    
    private func show(path path: UIBezierPath) {
        let areaLayer = CAShapeLayer()
        areaLayer.lineJoin = kCALineJoinBevel
        areaLayer.fillColor   = self.color.CGColor
        areaLayer.lineWidth   = 2.0
        areaLayer.strokeEnd   = 0.0
        self.layer.addSublayer(areaLayer)
        
        areaLayer.path = path.CGPath
        areaLayer.strokeColor = self.color.CGColor
        
        if self.animDuration > 0 {
            let maskLayer = CAGradientLayer()
            maskLayer.anchorPoint = CGPointZero
            
            let colors = [
                UIColor(white: 0, alpha: 0).CGColor,
                UIColor(white: 0, alpha: 1).CGColor]
            maskLayer.colors = colors
            maskLayer.bounds = CGRectMake(0, 0, 0, self.layer.bounds.size.height)
            maskLayer.startPoint = CGPointMake(1, 0)
            maskLayer.endPoint = CGPointMake(0, 0)
            self.layer.mask = maskLayer
        
            let revealAnimation = CABasicAnimation(keyPath: "bounds")
            revealAnimation.fromValue = NSValue(CGRect: CGRectMake(0, 0, 0, self.layer.bounds.size.height))
            
            let target = CGRectMake(self.layer.bounds.origin.x, self.layer.bounds.origin.y, self.layer.bounds.size.width + 2000, self.layer.bounds.size.height);
            
            revealAnimation.toValue = NSValue(CGRect: target)
            revealAnimation.duration = CFTimeInterval(self.animDuration)
            
            revealAnimation.removedOnCompletion = false
            revealAnimation.fillMode = kCAFillModeForwards
            
            revealAnimation.beginTime = CACurrentMediaTime() + CFTimeInterval(self.animDelay)
            self.layer.mask?.addAnimation(revealAnimation, forKey: "revealAnimation")
        }
    }
}
