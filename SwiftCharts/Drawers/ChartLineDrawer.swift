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
    private let strokeWidth: CGFloat
    
    init(p1: CGPoint, p2: CGPoint, color: UIColor, strokeWidth: CGFloat = 0.2) {
        self.p1 = p1
        self.p2 = p2
        self.color = color
        self.strokeWidth = strokeWidth
    }

    override func draw(context context: CGContextRef, chart: Chart) {
        ChartDrawLine(context: context, p1: self.p1, p2: self.p2, width: self.strokeWidth, color: self.color)
    }
}
