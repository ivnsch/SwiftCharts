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
    fileprivate let animDelay: Float
    fileprivate let addContainerPoints: Bool
    
    public init(points: [CGPoint], frame: CGRect, colors: [UIColor], animDuration: Float, animDelay: Float, addContainerPoints: Bool, pathGenerator: ChartLinesViewPathGenerator) {
        self.animDuration = animDuration
        self.animDelay = animDelay
        self.addContainerPoints = addContainerPoints
        
        super.init(frame: frame)

        backgroundColor = UIColor.clear
        show(path: generateAreaPath(points: points, pathGenerator: pathGenerator), colors: colors)
    }
    
    required public init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func generateAreaPath(points: [CGPoint], pathGenerator: ChartLinesViewPathGenerator) -> UIBezierPath {
        return pathGenerator.generateAreaPath(points: points, lineWidth: 1.0)
    }
    
    fileprivate func show(path: UIBezierPath, colors: [UIColor]) {
        var gradientColors = colors
        guard let firstColor = gradientColors.first else {
            print("WARNING: No color(s) used for ChartAreasView")
            return
        }
        
        /*
         * There is always the possibility to draw a single-color gradient.
         * Since we're adding the gradient layer anyway we must ensure that there are at least 2 colors present.
         * To handle this case we're adding the same color twice to the colors array to make sure we have at least 2 colors to fill the gradient layer with.
         */
        if gradientColors.count == 1 {
            gradientColors.append(gradientColors[0])
        }
        
        let shape = CAShapeLayer()
        shape.frame = CGRect(x: bounds.origin.x, y: bounds.origin.y, width: path.bounds.width, height: bounds.height)
        
        shape.path = path.cgPath
        shape.strokeColor = firstColor.cgColor
        shape.lineWidth = 2
        shape.fillColor = nil
        
        let gradient = CAGradientLayer()
        gradient.frame = shape.bounds
        gradient.colors = gradientColors.map{$0.cgColor}
        
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
        
        layer.addSublayer(gradient)
        layer.addSublayer(shape)
        
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
            revealAnimation.fillMode = CAMediaTimingFillMode.forwards
            
            revealAnimation.beginTime = CACurrentMediaTime() + CFTimeInterval(animDelay)
            layer.mask?.add(revealAnimation, forKey: "revealAnimation")
        }
    }
}

