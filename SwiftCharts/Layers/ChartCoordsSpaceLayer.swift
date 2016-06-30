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
    public var innerFrame: CGRect
    
    /// If layer is generating views as part of a transform (e.g. panning or zooming)
    var isTransform = false
    
    public init(xAxis: ChartAxis, yAxis: ChartAxis, innerFrame: CGRect) {
        self.xAxis = xAxis
        self.yAxis = yAxis
        self.innerFrame = innerFrame
    }
    
    public override func handleAxisInnerFrameChange(xLow: ChartAxisLayerWithFrameDelta?, yLow: ChartAxisLayerWithFrameDelta?, xHigh: ChartAxisLayerWithFrameDelta?, yHigh: ChartAxisLayerWithFrameDelta?) {
        
        func default0(axisWithDeltaMaybe: ChartAxisLayerWithFrameDelta?) -> CGFloat {
            return axisWithDeltaMaybe?.delta ?? 0
        }
        
        self.innerFrame = ChartUtils.insetBy(self.innerFrame, dx: default0(yLow), dy: default0(xHigh), dw: default0(yHigh), dh: default0(xLow))
    }
}
