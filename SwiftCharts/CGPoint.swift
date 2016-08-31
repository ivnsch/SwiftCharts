//
//  CGPoint.swift
//  SwiftCharts
//
//  Created by ischuetz on 30/07/16.
//  Copyright © 2016 ivanschuetz. All rights reserved.
//

import UIKit

extension CGPoint {

    func distance(point: CGPoint) -> CGFloat {
        return CGFloat(hypotf(Float(x) - Float(point.x), Float(y) - Float(point.y)))
    }
    
    func add(point: CGPoint) -> CGPoint {
        return offset(x: point.x, y: point.y)
    }
    
    func substract(point: CGPoint) -> CGPoint {
        return offset(x: -point.x, y: -point.y)
    }
    
    func offset(x x: CGFloat = 0, y: CGFloat = 0) -> CGPoint {
        return CGPointMake(self.x + x, self.y + y)
    }
    
    func surroundingRect(size: CGFloat) -> CGRect {
        return CGRectMake(x - size / 2, y - size / 2, size, size)
    }
    
    func nearest(intersections: [CGPoint]) -> (distance: CGFloat, point: CGPoint)? {
        return nearest(intersections, pointMapper: {$0}).map{(distance: $0.distance, point: $0.pointMappable)}
    }
    
    /// Finds nearest object which can be mapped to a point using pointMapper function. This is convenient for objects that contain/represent a point, in order to avoid having to map to points and back.
    func nearest<T>(pointMappables: [T], pointMapper: T -> CGPoint) -> (distance: CGFloat, pointMappable: T)? {
        var minDistancePoint: (distance: CGFloat, pointMappable: T)? = nil
        for pointMappable in pointMappables {
            let dist = distance(pointMapper(pointMappable))
            if (minDistancePoint.map{dist < $0.0}) ?? true {
                minDistancePoint = (dist, pointMappable)
            }
        }
        return minDistancePoint
    }
}