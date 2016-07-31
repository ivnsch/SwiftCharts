//
//  ChartLayerBase.swift
//  SwiftCharts
//
//  Created by ischuetz on 02/05/15.
//  Copyright (c) 2015 ivanschuetz. All rights reserved.
//

import UIKit

// Convenience class to make protocol's methods optional
public class ChartLayerBase: NSObject, ChartLayer {

    public weak var chart: Chart?
    
    public func chartInitialized(chart chart: Chart) {
        self.chart = chart
    }
    
    public func chartViewDrawing(context context: CGContextRef, chart: Chart) {}

    public func chartContentViewDrawing(context context: CGContextRef, chart: Chart) {}

    public func chartDrawersContentViewDrawing(context context: CGContextRef, chart: Chart, view: UIView) {}
    
    public func update() {}
    
    public func handleAxisInnerFrameChange(xLow: ChartAxisLayerWithFrameDelta?, yLow: ChartAxisLayerWithFrameDelta?, xHigh: ChartAxisLayerWithFrameDelta?, yHigh: ChartAxisLayerWithFrameDelta?) {}
    
    public func zoom(x: CGFloat, y: CGFloat, centerX: CGFloat, centerY: CGFloat) {}
    
    public func zoom(scaleX: CGFloat, scaleY: CGFloat, centerX: CGFloat, centerY: CGFloat) {}
    
    public func pan(deltaX: CGFloat, deltaY: CGFloat) {}

    public func handleGlobalTap(location: CGPoint) {}

    public override init() {}
}
