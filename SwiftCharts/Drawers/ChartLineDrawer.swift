//
//  ChartLineDrawer.swift
//  SwiftCharts
//
//  Created by ischuetz on 25/04/15.
//  Copyright (c) 2015 ivanschuetz. All rights reserved.
//

import UIKit

class ChartLineDrawer: ChartContextDrawer {
    private let p1: CGPoint
    private let p2: CGPoint
    private let color: UIColor
    
    init(p1: CGPoint, p2: CGPoint, color: UIColor) {
        self.p1 = p1
        self.p2 = p2
        self.color = color
    }
    
    override func draw(#context: CGContextRef, chart: Chart) {
        CGContextSetStrokeColorWithColor(context, self.color.CGColor)
        CGContextMoveToPoint(context, self.p1.x, self.p1.y)
        CGContextAddLineToPoint(context, self.p2.x, self.p2.y)
        CGContextStrokePath(context)
    }
}
