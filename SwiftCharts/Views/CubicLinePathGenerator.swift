//
//  CubicLinePathGenerator.swift
//  SwiftCharts
//
//  Created by ischuetz on 28/04/15.
//  Copyright (c) 2015 ivanschuetz. All rights reserved.
//

import UIKit

public class CubicLinePathGenerator: ChartLinesViewPathGenerator {
    
    public init() {}
    
    // src: http://stackoverflow.com/a/29876400/930450
    public func generatePath(points points: [CGPoint], lineWidth: CGFloat) -> UIBezierPath {
        var cp1: CGPoint
        var cp2: CGPoint
        
        let path = UIBezierPath()
        var p0: CGPoint
        var p1: CGPoint
        var p2: CGPoint
        var p3: CGPoint
        var tensionBezier1: CGFloat = 0.3
        var tensionBezier2: CGFloat = 0.3
        
        var previousPoint1: CGPoint = CGPointZero
//        var previousPoint2: CGPoint
        
        path.moveToPoint(points.first!)
        
        for i in 0..<(points.count - 1) {
            p1 = points[i]
            p2 = points[i + 1]
            
            let maxTension: CGFloat = 1 / 3
            tensionBezier1 = maxTension
            tensionBezier2 = maxTension
            
            if i > 0 {  // Exception for first line because there is no previous point
                p0 = previousPoint1
                
                if p2.y - p1.y == p2.y - p0.y {
                    tensionBezier1 = 0
                }
                
            } else {
                tensionBezier1 = 0
                p0 = p1
            }
            
            if i < points.count - 2 { // Exception for last line because there is no next point
                p3 = points[i + 2]
                if p3.y - p2.y == p2.y - p1.y {
                    tensionBezier2 = 0
                }
            } else {
                p3 = p2
                tensionBezier2 = 0
            }
            
            // The tension should never exceed 0.3
            if tensionBezier1 > maxTension {
                tensionBezier1 = maxTension
            }
            if tensionBezier1 > maxTension {
                tensionBezier2 = maxTension
            }
            
            // First control point
            cp1 = CGPointMake(p1.x + (p2.x - p1.x)/3,
                p1.y - (p1.y - p2.y)/3 - (p0.y - p1.y)*tensionBezier1)
            
            // Second control point
            cp2 = CGPointMake(p1.x + 2*(p2.x - p1.x)/3,
                (p1.y - 2*(p1.y - p2.y)/3) + (p2.y - p3.y)*tensionBezier2)
            
            
            path.addCurveToPoint(p2, controlPoint1: cp1, controlPoint2: cp2)
            
            previousPoint1 = p1;
//            previousPoint2 = p2;
        }
        
        return path
    }
}