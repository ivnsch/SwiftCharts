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
    
    override func draw(context context: CGContextRef, chart: Chart) {
        ChartDrawLine(context: context, p1: self.p1, p2: self.p2, width: 0.2, color: self.color)
    }
}
