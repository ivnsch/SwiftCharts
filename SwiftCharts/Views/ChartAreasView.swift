//
//  ChartAreasView.swift
//  swift_charts
//
//  Created by ischuetz on 18/04/15.
//  Copyright (c) 2015 ivanschuetz. All rights reserved.
//

import UIKit

open class ChartAreasView: UIView {

    fileprivate let animDuration: Float
    fileprivate var colors: [UIColor]
    fileprivate let animDelay: Float
    fileprivate let addContainerPoints: Bool
    
    public init(points: [CGPoint], frame: CGRect, colors: [UIColor], animDuration: Float, animDelay: Float, addContainerPoints: Bool, pathGenerator: ChartLinesViewPathGenerator) {
        self.colors = colors
        self.animDuration = animDuration
        self.animDelay = animDelay
        self.addContainerPoints = addContainerPoints
        
        super.init(frame: frame)

        backgroundColor = UIColor.clear
        show(path: generateAreaPath(points: points, pathGenerator: pathGenerator))
    }
    
    required public init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func generateAreaPath(points: [CGPoint], pathGenerator: ChartLinesViewPathGenerator) -> UIBezierPath {
        return pathGenerator.generateAreaPath(points: points, lineWidth: 1.0)
    }
    
    fileprivate func show(path: UIBezierPath) {
        guard let firstColor = colors.first else {
            print("WARNING: No color(s) used for ChartAreasView")
            return
        }
        
        if colors.count == 1 {
            colors.append(colors[0])
        }
        
        let shape = CAShapeLayer()
        shape.frame = self.bounds
        
        shape.path = path.cgPath
        shape.strokeColor = firstColor.cgColor
        shape.lineWidth = 2
        shape.fillColor = nil
        
        let gradient = CAGradientLayer()
        gradient.frame = self.bounds
        gradient.colors = colors.map{$0.cgColor}
        
        let mask = CAShapeLayer()
        mask.frame = self.bounds
        
        if addContainerPoints {
            path.addLine(to: CGPoint(x: shape.frame.size.width, y: shape.frame.size.height))
            path.addLine(to: CGPoint(x: 0, y: shape.frame.size.height))
            path.close()
        }
        
        mask.path = path.cgPath
        mask.fillColor = UIColor.black.cgColor
        gradient.mask = mask
        
        self.layer.addSublayer(gradient)
        self.layer.addSublayer(shape)
        
        if animDuration > 0 {
            let maskLayer = CAGradientLayer()
            maskLayer.anchorPoint = CGPoint.zero
            
            let colors = [
                UIColor(white: 0, alpha: 0).cgColor,
                UIColor(white: 0, alpha: 1).cgColor]
            maskLayer.colors = colors
            maskLayer.bounds = CGRect(x: 0, y: 0, width: 0, height: layer.bounds.size.height)
            maskLayer.startPoint = CGPoint(x: 1, y: 0)
            maskLayer.endPoint = CGPoint(x: 0, y: 0)
            layer.mask = maskLayer
            
            let revealAnimation = CABasicAnimation(keyPath: "bounds")
            revealAnimation.fromValue = NSValue(cgRect: CGRect(x: 0, y: 0, width: 0, height: layer.bounds.size.height))
            
            let target = CGRect(x: layer.bounds.origin.x, y: layer.bounds.origin.y, width: layer.bounds.size.width + 2000, height: layer.bounds.size.height)
            
            revealAnimation.toValue = NSValue(cgRect: target)
            revealAnimation.duration = CFTimeInterval(animDuration)
            
            revealAnimation.isRemovedOnCompletion = false
            revealAnimation.fillMode = kCAFillModeForwards
            
            revealAnimation.beginTime = CACurrentMediaTime() + CFTimeInterval(animDelay)
            layer.mask?.add(revealAnimation, forKey: "revealAnimation")
        }
    }
}

