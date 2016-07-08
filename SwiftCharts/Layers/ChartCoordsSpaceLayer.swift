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
    
    /// If layer is generating views as part of a transform (e.g. panning or zooming)
    var isTransform = false
    
    public init(xAxis: ChartAxis, yAxis: ChartAxis) {
        self.xAxis = xAxis
        self.yAxis = yAxis
    }
}