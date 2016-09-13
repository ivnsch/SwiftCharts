//
//  ChartGuideLinesLayer.swift
//  SwiftCharts
//
//  Created by ischuetz on 26/04/15.
//  Copyright (c) 2015 ivanschuetz. All rights reserved.
//

import UIKit

open class ChartGuideLinesLayerSettings {
    let linesColor: UIColor
    let linesWidth: CGFloat
    
    public init(linesColor: UIColor = UIColor.gray, linesWidth: CGFloat = 0.3) {
        self.linesColor = linesColor
        self.linesWidth = linesWidth
    }
}

open class ChartGuideLinesDottedLayerSettings: ChartGuideLinesLayerSettings {
    let dotWidth: CGFloat
    let dotSpacing: CGFloat
    
    public init(linesColor: UIColor, linesWidth: CGFloat, dotWidth: CGFloat = 2, dotSpacing: CGFloat = 2) {
        self.dotWidth = dotWidth
        self.dotSpacing = dotSpacing
        super.init(linesColor: linesColor, linesWidth: linesWidth)
    }
}

public enum ChartGuideLinesLayerAxis {
    case x, y, xAndY
}

open class ChartGuideLinesLayerAbstract<T: ChartGuideLinesLayerSettings>: ChartCoordsSpaceLayer {
    
    fileprivate let settings: T
    fileprivate let onlyVisibleX: Bool
    fileprivate let onlyVisibleY: Bool
    fileprivate let axis: ChartGuideLinesLayerAxis
    
    public init(xAxis: ChartAxisLayer, yAxis: ChartAxisLayer, innerFrame: CGRect, axis: ChartGuideLinesLayerAxis = .xAndY, settings: T, onlyVisibleX: Bool = false, onlyVisibleY: Bool = false) {
        self.settings = settings
        self.onlyVisibleX = onlyVisibleX
        self.onlyVisibleY = onlyVisibleY
        self.axis = axis
        super.init(xAxis: xAxis, yAxis: yAxis, innerFrame: innerFrame)
    }
    
    fileprivate func drawGuideline(_ context: CGContext, p1: CGPoint, p2: CGPoint) {
        fatalError("override")
    }
    
    override open func chartViewDrawing(context: CGContext, chart: Chart) {
        let originScreenLoc = self.innerFrame.origin
        let xScreenLocs = onlyVisibleX ? self.xAxis.visibleAxisValuesScreenLocs : self.xAxis.axisValuesScreenLocs
        let yScreenLocs = onlyVisibleY ? self.yAxis.visibleAxisValuesScreenLocs : self.yAxis.axisValuesScreenLocs
        
        if self.axis == .x || self.axis == .xAndY {
            for xScreenLoc in xScreenLocs {
                let x1 = xScreenLoc
                let y1 = originScreenLoc.y
                let x2 = x1
                let y2 = originScreenLoc.y + self.innerFrame.height
                self.drawGuideline(context, p1: CGPoint(x: x1, y: y1), p2: CGPoint(x: x2, y: y2))
            }
        }
        
        if self.axis == .y || self.axis == .xAndY {
            for yScreenLoc in yScreenLocs {
                let x1 = originScreenLoc.x
                let y1 = yScreenLoc
                let x2 = originScreenLoc.x + self.innerFrame.width
                let y2 = y1
                self.drawGuideline(context, p1: CGPoint(x: x1, y: y1), p2: CGPoint(x: x2, y: y2))
            }
        }
    }
}

public typealias ChartGuideLinesLayer = ChartGuideLinesLayer_<Any>
open class ChartGuideLinesLayer_<N>: ChartGuideLinesLayerAbstract<ChartGuideLinesLayerSettings> {
    
    override public init(xAxis: ChartAxisLayer, yAxis: ChartAxisLayer, innerFrame: CGRect, axis: ChartGuideLinesLayerAxis = .xAndY, settings: ChartGuideLinesLayerSettings, onlyVisibleX: Bool = false, onlyVisibleY: Bool = false) {
        super.init(xAxis: xAxis, yAxis: yAxis, innerFrame: innerFrame, axis: axis, settings: settings, onlyVisibleX: onlyVisibleX, onlyVisibleY: onlyVisibleY)
    }
    
    override fileprivate func drawGuideline(_ context: CGContext, p1: CGPoint, p2: CGPoint) {
        ChartDrawLine(context: context, p1: p1, p2: p2, width: self.settings.linesWidth, color: self.settings.linesColor)
    }
}

public typealias ChartGuideLinesDottedLayer = ChartGuideLinesDottedLayer_<Any>
open class ChartGuideLinesDottedLayer_<N>: ChartGuideLinesLayerAbstract<ChartGuideLinesDottedLayerSettings> {
    
    override public init(xAxis: ChartAxisLayer, yAxis: ChartAxisLayer, innerFrame: CGRect, axis: ChartGuideLinesLayerAxis = .xAndY, settings: ChartGuideLinesDottedLayerSettings, onlyVisibleX: Bool = false, onlyVisibleY: Bool = false) {
        super.init(xAxis: xAxis, yAxis: yAxis, innerFrame: innerFrame, axis: axis, settings: settings, onlyVisibleX: onlyVisibleX, onlyVisibleY: onlyVisibleY)
    }
    
    override fileprivate func drawGuideline(_ context: CGContext, p1: CGPoint, p2: CGPoint) {
        ChartDrawDottedLine(context: context, p1: p1, p2: p2, width: self.settings.linesWidth, color: self.settings.linesColor, dotWidth: self.settings.dotWidth, dotSpacing: self.settings.dotSpacing)
    }
}


open class ChartGuideLinesForValuesLayerAbstract<T: ChartGuideLinesLayerSettings>: ChartCoordsSpaceLayer {
    
    fileprivate let settings: T
    fileprivate let axisValuesX: [ChartAxisValue]
    fileprivate let axisValuesY: [ChartAxisValue]

    public init(xAxis: ChartAxisLayer, yAxis: ChartAxisLayer, innerFrame: CGRect, settings: T, axisValuesX: [ChartAxisValue], axisValuesY: [ChartAxisValue]) {
        self.settings = settings
        self.axisValuesX = axisValuesX
        self.axisValuesY = axisValuesY
        super.init(xAxis: xAxis, yAxis: yAxis, innerFrame: innerFrame)
    }
    
    fileprivate func drawGuideline(_ context: CGContext, color: UIColor, width: CGFloat, p1: CGPoint, p2: CGPoint, dotWidth: CGFloat, dotSpacing: CGFloat) {
        ChartDrawDottedLine(context: context, p1: p1, p2: p2, width: width, color: color, dotWidth: dotWidth, dotSpacing: dotSpacing)
    }
    
    fileprivate func drawGuideline(_ context: CGContext, p1: CGPoint, p2: CGPoint) {
        fatalError("override")
    }
    
    override open func chartViewDrawing(context: CGContext, chart: Chart) {
        let originScreenLoc = self.innerFrame.origin
        
        for axisValue in self.axisValuesX {
            let screenLoc = self.xAxis.screenLocForScalar(axisValue.scalar)
            let x1 = screenLoc
            let y1 = originScreenLoc.y
            let x2 = x1
            let y2 = originScreenLoc.y + self.innerFrame.height
            self.drawGuideline(context, p1: CGPoint(x: x1, y: y1), p2: CGPoint(x: x2, y: y2))

        }
        
        for axisValue in self.axisValuesY {
            let screenLoc = self.yAxis.screenLocForScalar(axisValue.scalar)
            let x1 = originScreenLoc.x
            let y1 = screenLoc
            let x2 = originScreenLoc.x + self.innerFrame.width
            let y2 = y1
            self.drawGuideline(context, p1: CGPoint(x: x1, y: y1), p2: CGPoint(x: x2, y: y2))

        }
    }
}


public typealias ChartGuideLinesForValuesLayer = ChartGuideLinesForValuesLayer_<Any>
open class ChartGuideLinesForValuesLayer_<N>: ChartGuideLinesForValuesLayerAbstract<ChartGuideLinesLayerSettings> {
    
    public override init(xAxis: ChartAxisLayer, yAxis: ChartAxisLayer, innerFrame: CGRect, settings: ChartGuideLinesLayerSettings, axisValuesX: [ChartAxisValue], axisValuesY: [ChartAxisValue]) {
        super.init(xAxis: xAxis, yAxis: yAxis, innerFrame: innerFrame, settings: settings, axisValuesX: axisValuesX, axisValuesY: axisValuesY)
    }
    
    override fileprivate func drawGuideline(_ context: CGContext, p1: CGPoint, p2: CGPoint) {
        ChartDrawLine(context: context, p1: p1, p2: p2, width: self.settings.linesWidth, color: self.settings.linesColor)
    }
}

public typealias ChartGuideLinesForValuesDottedLayer = ChartGuideLinesForValuesDottedLayer_<Any>
open class ChartGuideLinesForValuesDottedLayer_<N>: ChartGuideLinesForValuesLayerAbstract<ChartGuideLinesDottedLayerSettings> {
    
    public override init(xAxis: ChartAxisLayer, yAxis: ChartAxisLayer, innerFrame: CGRect, settings: ChartGuideLinesDottedLayerSettings, axisValuesX: [ChartAxisValue], axisValuesY: [ChartAxisValue]) {
        super.init(xAxis: xAxis, yAxis: yAxis, innerFrame: innerFrame, settings: settings, axisValuesX: axisValuesX, axisValuesY: axisValuesY)
    }
    
    override fileprivate func drawGuideline(_ context: CGContext, p1: CGPoint, p2: CGPoint) {
        ChartDrawDottedLine(context: context, p1: p1, p2: p2, width: self.settings.linesWidth, color: self.settings.linesColor, dotWidth: self.settings.dotWidth, dotSpacing: self.settings.dotSpacing)
    }
}

