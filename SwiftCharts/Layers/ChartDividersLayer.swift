//
//  ChartDividersLayer.swift
//  SwiftCharts
//
//  Created by ischuetz on 21/04/15.
//  Copyright (c) 2015 ivanschuetz. All rights reserved.
//

import UIKit

public struct ChartDividersLayerSettings {
    let linesColor: UIColor
    let linesWidth: CGFloat
    let start: CGFloat // points from start to axis, axis is 0
    let end: CGFloat // points from axis to end, axis is 0
    
    public init(linesColor: UIColor = UIColor.grayColor(), linesWidth: CGFloat = 0.3, start: CGFloat = 5, end: CGFloat = 5) {
        self.linesColor = linesColor
        self.linesWidth = linesWidth
        self.start = start
        self.end = end
    }
}

public enum ChartDividersLayerAxis {
    case X, Y, XAndY
}

public class ChartDividersLayer: ChartCoordsSpaceLayer {
    
    private let settings: ChartDividersLayerSettings
    
    let axis: ChartDividersLayerAxis

    private let xAxisLayer: ChartAxisLayer
    private let yAxisLayer: ChartAxisLayer
    
    public init(xAxisLayer: ChartAxisLayer, yAxisLayer: ChartAxisLayer, axis: ChartDividersLayerAxis = .XAndY, settings: ChartDividersLayerSettings) {
        self.axis = axis
        self.settings = settings
        
        self.xAxisLayer = xAxisLayer
        self.yAxisLayer = yAxisLayer

        super.init(xAxis: xAxisLayer.axis, yAxis: yAxisLayer.axis)
    }
    
    private func drawLine(context context: CGContextRef, color: UIColor, width: CGFloat, p1: CGPoint, p2: CGPoint) {
        ChartDrawLine(context: context, p1: p1, p2: p2, width: width, color: color)
    }
    
    override public func chartViewDrawing(context context: CGContextRef, chart: Chart) {
        let xScreenLocs = self.xAxisLayer.axisValuesScreenLocs
        let yScreenLocs = self.yAxisLayer.axisValuesScreenLocs
        
        if self.axis == .X || self.axis == .XAndY {
            for xScreenLoc in xScreenLocs {
                let x1 = xScreenLoc
                let y1 = self.xAxisLayer.lineP1.y + (self.xAxisLayer.low ? -self.settings.end : self.settings.end)
                let x2 = xScreenLoc
                let y2 = self.xAxisLayer.lineP1.y + (self.xAxisLayer.low ? self.settings.start : -self.settings.start)
                self.drawLine(context: context, color: self.settings.linesColor, width: self.settings.linesWidth, p1: CGPointMake(x1, y1), p2: CGPointMake(x2, y2))
            }
        }
        
        if self.axis == .Y || self.axis == .XAndY {
            for yScreenLoc in yScreenLocs {
                let x1 = self.yAxisLayer.lineP1.x + (self.yAxisLayer.low ? -self.settings.start : self.settings.start)
                let y1 = yScreenLoc
                let x2 = self.yAxisLayer.lineP1.x + (self.yAxisLayer.low ? self.settings.end : self.settings.end)
                let y2 = yScreenLoc
                self.drawLine(context: context, color: self.settings.linesColor, width: self.settings.linesWidth, p1: CGPointMake(x1, y1), p2: CGPointMake(x2, y2))
            }
        }
    }
}
