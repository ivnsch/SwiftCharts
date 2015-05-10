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
    let axis: ChartDividersLayerAxis
    let start: CGFloat // points from start to axis, axis is 0
    let end: CGFloat // points from axis to end, axis is 0
    let onlyVisibleValues: Bool
    
    public init(linesColor: UIColor = UIColor.grayColor(), linesWidth: CGFloat = 0.3, axis: ChartDividersLayerAxis = .XAndY, start: CGFloat = 5, end: CGFloat = 5, onlyVisibleValues: Bool = false) {
        self.linesColor = linesColor
        self.linesWidth = linesWidth
        self.axis = axis
        self.start = start
        self.end = end
        self.onlyVisibleValues = onlyVisibleValues
    }
}

public enum ChartDividersLayerAxis {
    case X, Y, XAndY
}

public class ChartDividersLayer: ChartCoordsSpaceLayer {
    
    private let settings: ChartDividersLayerSettings
    
    private let xScreenLocs: [CGFloat]
    private let yScreenLocs: [CGFloat]
    
    public init(xAxis: ChartAxisLayer, yAxis: ChartAxisLayer, innerFrame: CGRect, settings: ChartDividersLayerSettings) {
        self.settings = settings
        
        func screenLocs(axisLayer: ChartAxisLayer) -> [CGFloat] {
            let values = settings.onlyVisibleValues ? axisLayer.axisValues.filter{!$0.hidden} : axisLayer.axisValues
            return values.map{axisLayer.screenLocForScalar($0.scalar)}
        }
        
        self.xScreenLocs = screenLocs(xAxis)
        self.yScreenLocs = screenLocs(yAxis)
        
        super.init(xAxis: xAxis, yAxis: yAxis, innerFrame: innerFrame)
    }
    
    private func renderLine(#context: CGContextRef, color: UIColor, width: CGFloat, p1: CGPoint, p2: CGPoint) {
        CGContextSetStrokeColorWithColor(context, color.CGColor)
        CGContextSetLineWidth(context, width)
        CGContextMoveToPoint(context, p1.x, p1.y)
        CGContextAddLineToPoint(context, p2.x, p2.y)
        CGContextStrokePath(context)
    }
    
    override public func chartViewDrawing(#context: CGContextRef, chart: Chart) {
        let originScreenLoc = self.innerFrame.origin
        let xScreenLocs = self.xScreenLocs
        let yScreenLocs = self.yScreenLocs
        let xAxisScreenLength = self.xAxis.length
        let yAxisScreenLength = self.yAxis.length
        
        if self.settings.axis == .X || self.settings.axis == .XAndY {
            for xScreenLoc in xScreenLocs {
                let x1 = xScreenLoc
                let y1 = self.xAxis.lineP1.y + (self.xAxis.low ? -self.settings.end : self.settings.end)
                let x2 = xScreenLoc
                let y2 = self.xAxis.lineP1.y + (self.xAxis.low ? self.settings.start : -self.settings.end)
                self.renderLine(context: context, color: self.settings.linesColor, width: self.settings.linesWidth, p1: CGPointMake(x1, y1), p2: CGPointMake(x2, y2))
            }
        }
        
        if settings.axis == .Y || settings.axis == .XAndY {
            for yScreenLoc in yScreenLocs {
                let x1 = self.yAxis.lineP1.x + (self.yAxis.low ? -self.settings.start : self.settings.start)
                let y1 = yScreenLoc
                let x2 = self.yAxis.lineP1.x + (self.yAxis.low ? self.settings.end : self.settings.end)
                let y2 = yScreenLoc
                self.renderLine(context: context, color: self.settings.linesColor, width: self.settings.linesWidth, p1: CGPointMake(x1, y1), p2: CGPointMake(x2, y2))
            }
        }
    }
}
