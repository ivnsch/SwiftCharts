//
//  ChartGuideLinesLayer.swift
//  SwiftCharts
//
//  Created by ischuetz on 26/04/15.
//  Copyright (c) 2015 ivanschuetz. All rights reserved.
//

import UIKit

public class ChartGuideLinesLayerSettings {
    let linesColor: UIColor
    let linesWidth: CGFloat
    
    public init(linesColor: UIColor = UIColor.grayColor(), linesWidth: CGFloat = 0.3) {
        self.linesColor = linesColor
        self.linesWidth = linesWidth
    }
}

public class ChartGuideLinesDottedLayerSettings: ChartGuideLinesLayerSettings {
    let dotWidth: CGFloat
    let dotSpacing: CGFloat
    
    public init(linesColor: UIColor, linesWidth: CGFloat, dotWidth: CGFloat = 2, dotSpacing: CGFloat = 2) {
        self.dotWidth = dotWidth
        self.dotSpacing = dotSpacing
        super.init(linesColor: linesColor, linesWidth: linesWidth)
    }
}

public enum ChartGuideLinesLayerAxis {
    case X, Y, XAndY
}

public class ChartGuideLinesLayerAbstract<T: ChartGuideLinesLayerSettings>: ChartCoordsSpaceLayer {
    
    private let settings: T
    private let onlyVisibleX: Bool
    private let onlyVisibleY: Bool
    private let axis: ChartGuideLinesLayerAxis
    
    public init(xAxis: ChartAxisLayer, yAxis: ChartAxisLayer, innerFrame: CGRect, axis: ChartGuideLinesLayerAxis = .XAndY, settings: T, onlyVisibleX: Bool = false, onlyVisibleY: Bool = false) {
        self.settings = settings
        self.onlyVisibleX = onlyVisibleX
        self.onlyVisibleY = onlyVisibleY
        self.axis = axis
        super.init(xAxis: xAxis, yAxis: yAxis, innerFrame: innerFrame)
    }
    
    private func drawGuideline(context: CGContextRef, p1: CGPoint, p2: CGPoint) {
        fatalError("override")
    }
    
    override public func chartViewDrawing(context context: CGContextRef, chart: Chart) {
        let originScreenLoc = self.innerFrame.origin
        let xScreenLocs = onlyVisibleX ? self.xAxis.visibleAxisValuesScreenLocs : self.xAxis.axisValuesScreenLocs
        let yScreenLocs = onlyVisibleY ? self.yAxis.visibleAxisValuesScreenLocs : self.yAxis.axisValuesScreenLocs
        
        if self.axis == .X || self.axis == .XAndY {
            for xScreenLoc in xScreenLocs {
                let x1 = xScreenLoc
                let y1 = originScreenLoc.y
                let x2 = x1
                let y2 = originScreenLoc.y + self.innerFrame.height
                self.drawGuideline(context, p1: CGPointMake(x1, y1), p2: CGPointMake(x2, y2))
            }
        }
        
        if self.axis == .Y || self.axis == .XAndY {
            for yScreenLoc in yScreenLocs {
                let x1 = originScreenLoc.x
                let y1 = yScreenLoc
                let x2 = originScreenLoc.x + self.innerFrame.width
                let y2 = y1
                self.drawGuideline(context, p1: CGPointMake(x1, y1), p2: CGPointMake(x2, y2))
            }
        }
    }
}

public typealias ChartGuideLinesLayer = ChartGuideLinesLayer_<Any>
public class ChartGuideLinesLayer_<N>: ChartGuideLinesLayerAbstract<ChartGuideLinesLayerSettings> {
    
    override public init(xAxis: ChartAxisLayer, yAxis: ChartAxisLayer, innerFrame: CGRect, axis: ChartGuideLinesLayerAxis = .XAndY, settings: ChartGuideLinesLayerSettings, onlyVisibleX: Bool = false, onlyVisibleY: Bool = false) {
        super.init(xAxis: xAxis, yAxis: yAxis, innerFrame: innerFrame, axis: axis, settings: settings, onlyVisibleX: onlyVisibleX, onlyVisibleY: onlyVisibleY)
    }
    
    override private func drawGuideline(context: CGContextRef, p1: CGPoint, p2: CGPoint) {
        ChartDrawLine(context: context, p1: p1, p2: p2, width: self.settings.linesWidth, color: self.settings.linesColor)
    }
}

public typealias ChartGuideLinesDottedLayer = ChartGuideLinesDottedLayer_<Any>
public class ChartGuideLinesDottedLayer_<N>: ChartGuideLinesLayerAbstract<ChartGuideLinesDottedLayerSettings> {
    
    override public init(xAxis: ChartAxisLayer, yAxis: ChartAxisLayer, innerFrame: CGRect, axis: ChartGuideLinesLayerAxis = .XAndY, settings: ChartGuideLinesDottedLayerSettings, onlyVisibleX: Bool = false, onlyVisibleY: Bool = false) {
        super.init(xAxis: xAxis, yAxis: yAxis, innerFrame: innerFrame, axis: axis, settings: settings, onlyVisibleX: onlyVisibleX, onlyVisibleY: onlyVisibleY)
    }
    
    override private func drawGuideline(context: CGContextRef, p1: CGPoint, p2: CGPoint) {
        ChartDrawDottedLine(context: context, p1: p1, p2: p2, width: self.settings.linesWidth, color: self.settings.linesColor, dotWidth: self.settings.dotWidth, dotSpacing: self.settings.dotSpacing)
    }
}


public class ChartGuideLinesForValuesLayerAbstract<T: ChartGuideLinesLayerSettings>: ChartCoordsSpaceLayer {
    
    private let settings: T
    private let axisValuesX: [ChartAxisValue]
    private let axisValuesY: [ChartAxisValue]

    public init(xAxis: ChartAxisLayer, yAxis: ChartAxisLayer, innerFrame: CGRect, settings: T, axisValuesX: [ChartAxisValue], axisValuesY: [ChartAxisValue]) {
        self.settings = settings
        self.axisValuesX = axisValuesX
        self.axisValuesY = axisValuesY
        super.init(xAxis: xAxis, yAxis: yAxis, innerFrame: innerFrame)
    }
    
    private func drawGuideline(context: CGContextRef, color: UIColor, width: CGFloat, p1: CGPoint, p2: CGPoint, dotWidth: CGFloat, dotSpacing: CGFloat) {
        ChartDrawDottedLine(context: context, p1: p1, p2: p2, width: width, color: color, dotWidth: dotWidth, dotSpacing: dotSpacing)
    }
    
    private func drawGuideline(context: CGContextRef, p1: CGPoint, p2: CGPoint) {
        fatalError("override")
    }
    
    override public func chartViewDrawing(context context: CGContextRef, chart: Chart) {
        let originScreenLoc = self.innerFrame.origin
        
        for axisValue in self.axisValuesX {
            let screenLoc = self.xAxis.screenLocForScalar(axisValue.scalar)
            let x1 = screenLoc
            let y1 = originScreenLoc.y
            let x2 = x1
            let y2 = originScreenLoc.y + self.innerFrame.height
            self.drawGuideline(context, p1: CGPointMake(x1, y1), p2: CGPointMake(x2, y2))

        }
        
        for axisValue in self.axisValuesY {
            let screenLoc = self.yAxis.screenLocForScalar(axisValue.scalar)
            let x1 = originScreenLoc.x
            let y1 = screenLoc
            let x2 = originScreenLoc.x + self.innerFrame.width
            let y2 = y1
            self.drawGuideline(context, p1: CGPointMake(x1, y1), p2: CGPointMake(x2, y2))

        }
    }
}


public typealias ChartGuideLinesForValuesLayer = ChartGuideLinesForValuesLayer_<Any>
public class ChartGuideLinesForValuesLayer_<N>: ChartGuideLinesForValuesLayerAbstract<ChartGuideLinesLayerSettings> {
    
    public override init(xAxis: ChartAxisLayer, yAxis: ChartAxisLayer, innerFrame: CGRect, settings: ChartGuideLinesLayerSettings, axisValuesX: [ChartAxisValue], axisValuesY: [ChartAxisValue]) {
        super.init(xAxis: xAxis, yAxis: yAxis, innerFrame: innerFrame, settings: settings, axisValuesX: axisValuesX, axisValuesY: axisValuesY)
    }
    
    override private func drawGuideline(context: CGContextRef, p1: CGPoint, p2: CGPoint) {
        ChartDrawLine(context: context, p1: p1, p2: p2, width: self.settings.linesWidth, color: self.settings.linesColor)
    }
}

public typealias ChartGuideLinesForValuesDottedLayer = ChartGuideLinesForValuesDottedLayer_<Any>
public class ChartGuideLinesForValuesDottedLayer_<N>: ChartGuideLinesForValuesLayerAbstract<ChartGuideLinesDottedLayerSettings> {
    
    public override init(xAxis: ChartAxisLayer, yAxis: ChartAxisLayer, innerFrame: CGRect, settings: ChartGuideLinesDottedLayerSettings, axisValuesX: [ChartAxisValue], axisValuesY: [ChartAxisValue]) {
        super.init(xAxis: xAxis, yAxis: yAxis, innerFrame: innerFrame, settings: settings, axisValuesX: axisValuesX, axisValuesY: axisValuesY)
    }
    
    override private func drawGuideline(context: CGContextRef, p1: CGPoint, p2: CGPoint) {
        ChartDrawDottedLine(context: context, p1: p1, p2: p2, width: self.settings.linesWidth, color: self.settings.linesColor, dotWidth: self.settings.dotWidth, dotSpacing: self.settings.dotSpacing)
    }
}

