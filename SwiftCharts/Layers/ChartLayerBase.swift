//
//  ChartLayerBase.swift
//  SwiftCharts
//
//  Created by ischuetz on 02/05/15.
//  Copyright (c) 2015 ivanschuetz. All rights reserved.
//

import UIKit

/// Convenience class to store common properties and make protocol's methods optional
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

    public func processPan(location location: CGPoint, deltaX: CGFloat, deltaY: CGFloat, isGesture: Bool, isDeceleration: Bool) -> Bool {
        return false
    }
    
    public func handlePanStart(location: CGPoint) {}
    
    public func handlePanFinish() {}
    
    public func handleZoomFinish() {}
    
    public func handlePanEnd() {}
    
    public func handleZoomEnd() {}
    
    public func processZoom(deltaX deltaX: CGFloat, deltaY: CGFloat, anchorX: CGFloat, anchorY: CGFloat) -> Bool {
        return false
    }
    
    public func handleGlobalTap(location: CGPoint) -> Any? {
        return nil
    }
    
    public func keepInBoundaries() {}
    
    public override init() {}
}
