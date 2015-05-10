//
//  ChartGuideLinesLayer.swift
//  SwiftCharts
//
//  Created by ischuetz on 26/04/15.
//  Copyright (c) 2015 ivanschuetz. All rights reserved.
//

import UIKit


public class ChartGuideLinesIterator {
    
    public typealias LineDrawer = (p1: CGPoint, p2: CGPoint) -> ()

    func iterateLines(layer: ChartCoordsSpaceLayer, axis: ChartGuideLinesLayerAxis, onlyVisibleX: Bool, onlyVisibleY: Bool, lineDrawer: LineDrawer) {
        let originScreenLoc = layer.innerFrame.origin
        let xScreenLocs = onlyVisibleX ? layer.xAxis.visibleAxisValuesScreenLocs : layer.xAxis.axisValuesScreenLocs
        let yScreenLocs = onlyVisibleY ? layer.yAxis.visibleAxisValuesScreenLocs : layer.yAxis.axisValuesScreenLocs
        
        if axis == .X || axis == .XAndY {
            for xScreenLoc in xScreenLocs {
                let x1 = xScreenLoc
                let y1 = originScreenLoc.y
                let x2 = x1
                let y2 = originScreenLoc.y + layer.innerFrame.height
                lineDrawer(p1: CGPointMake(x1, y1), p2: CGPointMake(x2, y2))
            }
        }
        
        if axis == .Y || axis == .XAndY {
            for yScreenLoc in yScreenLocs {
                let x1 = originScreenLoc.x
                let y1 = yScreenLoc
                let x2 = originScreenLoc.x + layer.innerFrame.width
                let y2 = y1
                lineDrawer(p1: CGPointMake(x1, y1), p2: CGPointMake(x2, y2))
            }
        }
    }
}

public struct ChartGuideLinesLayerSettings {
    let linesColor: UIColor
    let linesWidth: CGFloat
    let axis: ChartGuideLinesLayerAxis
    
    public init(linesColor: UIColor = UIColor.grayColor(), linesWidth: CGFloat = 0.3, axis: ChartGuideLinesLayerAxis = .XAndY) {
        self.linesColor = linesColor
        self.linesWidth = linesWidth
        self.axis = axis
    }
}

public enum ChartGuideLinesLayerAxis {
    case X, Y, XAndY
}

public class ChartGuideLinesLayer: ChartCoordsSpaceLayer {
    
    private let settings: ChartGuideLinesLayerSettings
    private let onlyVisibleX: Bool
    private let onlyVisibleY: Bool
    
    public init(axisX: ChartAxisLayer, yAxis: ChartAxisLayer, innerFrame: CGRect, settings: ChartGuideLinesLayerSettings, onlyVisibleX: Bool = false, onlyVisibleY: Bool = false) {
        self.settings = settings
        self.onlyVisibleX = onlyVisibleX
        self.onlyVisibleY = onlyVisibleY
        super.init(xAxis: axisX, yAxis: yAxis, innerFrame: innerFrame)
    }
    
    private func drawGuideline(context: CGContextRef, color: UIColor, width: CGFloat, p1: CGPoint, p2: CGPoint, dotWidth: CGFloat, dotSpacing: CGFloat) {
        CGContextSetStrokeColorWithColor(context, color.CGColor)
        CGContextSetLineWidth(context, width)
        CGContextMoveToPoint(context, p1.x, p1.y)
        CGContextAddLineToPoint(context, p2.x, p2.y)
        CGContextStrokePath(context)
    }
    
    override public func chartViewDrawing(#context: CGContextRef, chart: Chart) {
        ChartGuideLinesIterator().iterateLines(self, axis: self.settings.axis, onlyVisibleX: self.onlyVisibleX, onlyVisibleY: self.onlyVisibleY) {(p1, p2) -> () in
            self.drawGuideline(context, color: self.settings.linesColor, width: self.settings.linesWidth, p1: p1, p2: p2, dotWidth: 2, dotSpacing: 2)
        }
    }
}


public struct ChartGuideLinesDottedLayerSettings {
    let linesColor: UIColor
    let linesWidth: CGFloat
    let axis: ChartGuideLinesLayerAxis
    let dotWidth: CGFloat
    let dotSpacing: CGFloat
    
    public init(linesColor: UIColor = UIColor.grayColor(), linesWidth: CGFloat = 0.3, axis: ChartGuideLinesLayerAxis = .XAndY, dotWidth: CGFloat = 2, dotSpacing: CGFloat = 2) {
        self.linesColor = linesColor
        self.linesWidth = linesWidth
        self.axis = axis
        self.dotWidth = dotWidth
        self.dotSpacing = dotSpacing
    }
}

public class ChartGuideLinesDottedLayer: ChartCoordsSpaceLayer {
    
    private let settings: ChartGuideLinesDottedLayerSettings
    private let onlyVisibleX: Bool
    private let onlyVisibleY: Bool
    
    public init(axisX: ChartAxisLayer, yAxis: ChartAxisLayer, innerFrame: CGRect, settings: ChartGuideLinesDottedLayerSettings, onlyVisibleX: Bool = false, onlyVisibleY: Bool = false) {
        self.settings = settings
        self.onlyVisibleX = onlyVisibleX
        self.onlyVisibleY = onlyVisibleY
        super.init(xAxis: axisX, yAxis: yAxis, innerFrame: innerFrame)
    }
    
    private func drawGuideline(context: CGContextRef, color: UIColor, width: CGFloat, p1: CGPoint, p2: CGPoint, dotWidth: CGFloat, dotSpacing: CGFloat) {
        
        CGContextSetStrokeColorWithColor(context, color.CGColor)
        CGContextSetLineWidth(context, width)
        
        let offset = dotWidth + dotSpacing
        
        let offsetY = (p2.y - p1.y)
        let yConstant = offsetY == 0
        var limit: CGFloat
        var start: CGFloat
        
        if yConstant { //horizontal line
            limit = p2.x - p1.x
            start = p1.x
            
        } else { //vertical line
            limit = p2.y - p1.y
            start = p1.y
        }
        
        limit += start
        
        for tmp in stride(from: start, to: limit, by: offset) {
            
            var x1: CGFloat
            var y1: CGFloat
            var x2: CGFloat
            var y2: CGFloat
            
            if yConstant { //horizontal line
                x1 = tmp
                y1 = p1.y
                x2 = x1 + dotWidth
                y2 = y1
                
            } else { //vertical line
                x1 = p1.x
                y1 = tmp
                x2 = x1
                y2 = y1 + dotWidth
            }
            
            CGContextMoveToPoint(context, x1, y1)
            CGContextAddLineToPoint(context, x2, y2)
            CGContextStrokePath(context)
        }
    }
    
    override public func chartViewDrawing(#context: CGContextRef, chart: Chart) {
        ChartGuideLinesIterator().iterateLines(self, axis: self.settings.axis, onlyVisibleX: self.onlyVisibleX, onlyVisibleY: self.onlyVisibleY) {(p1, p2) -> () in
            self.drawGuideline(context, color: self.settings.linesColor, width: self.settings.linesWidth, p1: p1, p2: p2, dotWidth: 2, dotSpacing: 2)
        }
    }
}