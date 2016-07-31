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
    
    // TODO differentiate - subclasses of ChartPointsLayer don't necessarily use contentView
    public func modelLocToScreenLoc(x x: Double, y: Double) -> CGPoint {
        return CGPointMake(modelLocToScreenLoc(x: x), modelLocToScreenLoc(y: y))
    }
    
    public func modelLocToScreenLoc(x x: Double) -> CGFloat {
        return xAxis.innerScreenLocForScalar(x) / (chart?.contentView.transform.a ?? 1)
    }
    
    public func modelLocToScreenLoc(y y: Double) -> CGFloat {
        return yAxis.innerScreenLocForScalar(y) / (chart?.contentView.transform.d ?? 1)
    }
    
    public func scalarForScreenLoc(x x: CGFloat) -> Double {
        return xAxis.innerScalarForScreenLoc(x * (chart?.contentView.transform.a ?? 1))
    }
    
    public func scalarForScreenLoc(y y: CGFloat) -> Double {
        return yAxis.innerScalarForScreenLoc(y * (chart?.contentView.transform.d ?? 1))
    }
    
    public func globalToDrawersContainerCoordinates(point: CGPoint) -> CGPoint? {
        guard let chart = chart else {return nil}
        return point.substract(chart.containerView.frame.origin)
    }
    
    public func containerToGlobalCoordinates(point: CGPoint) -> CGPoint? {
        guard let chart = chart else {return nil}
        return point.add(chart.containerView.frame.origin)
    }
}