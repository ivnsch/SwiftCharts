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
}