//
//  ChartCoordsSpaceLayer.swift
//  SwiftCharts
//
//  Created by ischuetz on 25/04/15.
//  Copyright (c) 2015 ivanschuetz. All rights reserved.
//

import UIKit

public class ChartCoordsSpaceLayer: ChartLayerBase {
    
    let xAxis: ChartAxis
    let yAxis: ChartAxis
    
    // frame where the layer displays chartpoints
    public let innerFrame: CGRect
    
    public init(xAxis: ChartAxis, yAxis: ChartAxis, innerFrame: CGRect) {
        self.xAxis = xAxis
        self.yAxis = yAxis
        self.innerFrame = innerFrame
    }
}
