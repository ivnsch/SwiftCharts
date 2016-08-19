//
//  ChartLayer.swift
//  SwiftCharts
//
//  Created by ischuetz on 02/05/15.
//  Copyright (c) 2015 ivanschuetz. All rights reserved.
//

import UIKit

public protocol ChartLayer {
    
    var chart: Chart? {get set}

    // Execute actions after chart initialisation, e.g. add subviews
     func chartInitialized(chart chart: Chart)
    
    // Draw directly in chart's context
    // Everything drawn here will appear behind subviews added by any layer (regardless of position in layers array)
    func chartViewDrawing(context context: CGContextRef, chart: Chart)
    
    func chartContentViewDrawing(context context: CGContextRef, chart: Chart)

    func chartDrawersContentViewDrawing(context context: CGContextRef, chart: Chart, view: UIView)
    
    /// Trigger views update, to match updated model data
    func update()
    
    /// Handle a change of the available inner space caused by an axis change of size in a direction orthogonal to the axis.
    func handleAxisInnerFrameChange(xLow: ChartAxisLayerWithFrameDelta?, yLow: ChartAxisLayerWithFrameDelta?, xHigh: ChartAxisLayerWithFrameDelta?, yHigh: ChartAxisLayerWithFrameDelta?)
    
    func zoom(x: CGFloat, y: CGFloat, centerX: CGFloat, centerY: CGFloat)
    
    func zoom(scaleX: CGFloat, scaleY: CGFloat, centerX: CGFloat, centerY: CGFloat)

    func pan(deltaX: CGFloat, deltaY: CGFloat)
    
    func handleGlobalTap(location: CGPoint) -> Any?
}