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
    // TODO maybe remove this, use the frame of contentView in chart instead. It should be always the same.
    public var innerFrame: CGRect
    
    /// If layer is generating views as part of a transform (e.g. panning or zooming)
    var isTransform = false
    
    public init(xAxis: ChartAxis, yAxis: ChartAxis, innerFrame: CGRect) {
        self.xAxis = xAxis
        self.yAxis = yAxis
        self.innerFrame = innerFrame
    }
    
    public override func handleAxisInnerFrameChange(xLow: ChartAxisLayerWithFrameDelta?, yLow: ChartAxisLayerWithFrameDelta?, xHigh: ChartAxisLayerWithFrameDelta?, yHigh: ChartAxisLayerWithFrameDelta?) {
        innerFrame = ChartUtils.insetBy(innerFrame, dx: yLow.deltaDefault0, dy: xHigh.deltaDefault0, dw: yHigh.deltaDefault0, dh: xLow.deltaDefault0)
    }
}
