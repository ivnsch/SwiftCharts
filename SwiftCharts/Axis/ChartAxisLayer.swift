//
//  ChartAxisLayer.swift
//  SwiftCharts
//
//  Created by ischuetz on 02/05/15.
//  Copyright (c) 2015 ivanschuetz. All rights reserved.
//

import UIKit

public protocol ChartAxisLayer: ChartLayer {
        
    var p1: CGPoint {get}
    var p2: CGPoint {get}
    var axisValues: [ChartAxisValue] {get}
    var rect: CGRect {get}
    var axisValuesScreenLocs: [CGFloat] {get}
    var visibleAxisValuesScreenLocs: [CGFloat] {get}
    var minAxisScreenSpace: CGFloat {get}
    var length: CGFloat {get}
    var modelLength: CGFloat {get}
    var low: Bool {get}
    var lineP1: CGPoint {get}
    var lineP2: CGPoint {get}
    
    func screenLocForScalar(scalar: Double) -> CGFloat
}