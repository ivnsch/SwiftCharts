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
        return CGPointMake(x + point.x, y + point.y)
    }
    
    func substract(point: CGPoint) -> CGPoint {
        return CGPointMake(x - point.x, y - point.y)
    }
}