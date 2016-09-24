//
//  ChartPointsLineLayer.swift
//  SwiftCharts
//
//  Created by ischuetz on 25/04/15.
//  Copyright (c) 2015 ivanschuetz. All rights reserved.
//

import UIKit

public enum LineJoin {
    case Miter
    case Round
    case Bevel
    
    var CALayerString: String {
        switch self {
        case .Miter: return kCALineJoinMiter
        case .Round: return kCALineCapRound
        case .Bevel: return kCALineJoinBevel
        }
    }
    
    var CGValue: CGLineJoin {
        switch self {
        case .Miter: return .Miter
        case .Round: return .Round
        case .Bevel: return .Bevel
        }
    }
}

public enum LineCap {
    case Butt
    case Round
    case Square
    
    var CALayerString: String {
        switch self {
        case .Butt: return kCALineCapButt
        case .Round: return kCALineCapRound
        case .Square: return kCALineCapSquare
        }
    }
    
    var CGValue: CGLineCap {
        switch self {
        case .Butt: return .Butt
        case .Round: return .Round
        case .Square: return .Square
        }
    }
}

private struct ScreenLine<T: ChartPoint> {
    var points: [CGPoint]
    let color: UIColor
    let lineWidth: CGFloat
    let lineJoin: LineJoin
    let lineCap: LineCap
    let animDuration: Float
    let animDelay: Float
    let lineModel: ChartLineModel<T>
    let dashPattern: [Double]?
    
    init(points: [CGPoint], color: UIColor, lineWidth: CGFloat, lineJoin: LineJoin, lineCap: LineCap, animDuration: Float, animDelay: Float, lineModel: ChartLineModel<T>, dashPattern: [Double]?) {
        self.points = points
        self.color = color
        self.lineWidth = lineWidth
        self.lineJoin = lineJoin
        self.lineCap = lineCap
        self.animDuration = animDuration
        self.animDelay = animDelay
        self.lineModel = lineModel
        self.dashPattern = dashPattern
    }
}

public class ChartPointsLineLayer<T: ChartPoint>: ChartPointsLayer<T> {
    private var lineModels: [ChartLineModel<T>]
    private var lineViews: [ChartLinesView] = []
    private let pathGenerator: ChartLinesViewPathGenerator
    private var screenLines: [(screenLine: ScreenLine<T>, view: ChartLinesView)] = []
    
    private let useView: Bool
    
    private let delayInit: Bool
    
    public init(xAxis: ChartAxis, yAxis: ChartAxis, lineModels: [ChartLineModel<T>], pathGenerator: ChartLinesViewPathGenerator = StraightLinePathGenerator(), displayDelay: Float = 0, useView: Bool = true, delayInit: Bool = false) {
        self.lineModels = lineModels
        self.pathGenerator = pathGenerator
        self.useView = useView
        self.delayInit = delayInit
        
        let chartPoints: [T] = lineModels.flatMap{$0.chartPoints}
        
        super.init(xAxis: xAxis, yAxis: yAxis, chartPoints: chartPoints, displayDelay: displayDelay)
    }
    
    private func toScreenLine(lineModel lineModel: ChartLineModel<T>, chart: Chart) -> ScreenLine<T> {
        return ScreenLine(
            points: lineModel.chartPoints.map{self.chartPointScreenLoc($0)},
            color: lineModel.lineColor,
            lineWidth: lineModel.lineWidth,
            lineJoin: lineModel.lineJoin,
            lineCap: lineModel.lineCap,
            animDuration: lineModel.animDuration,
            animDelay: lineModel.animDelay,
            lineModel: lineModel,
            dashPattern: lineModel.dashPattern
        )
    }
    
    override func display(chart chart: Chart) {
        if !delayInit {
            if useView {
                initScreenLines(chart)
            }
        }
    }
    
    public func initScreenLines(chart: Chart) {
        let screenLines = self.lineModels.map{self.toScreenLine(lineModel: $0, chart: chart)}
        
        for screenLine in screenLines {
            let lineView = generateLineView(screenLine, chart: chart)
            self.lineViews.append(lineView)
            lineView.userInteractionEnabled = false
            chart.addSubviewNoTransform(lineView)
            self.screenLines.append((screenLine, lineView))
        }
    }
    
    private func generateLineView(screenLine: ScreenLine<T>, chart: Chart) -> ChartLinesView {
        return ChartLinesView(
            path: self.pathGenerator.generatePath(points: screenLine.points, lineWidth: screenLine.lineWidth),
            frame: chart.contentView.bounds,
            lineColor: screenLine.color,
            lineWidth: screenLine.lineWidth,
            lineJoin: screenLine.lineJoin,
            lineCap: screenLine.lineCap,
            animDuration: self.isTransform ? 0 : screenLine.animDuration,
            animDelay: self.isTransform ? 0 : screenLine.animDelay,
            dashPattern: screenLine.dashPattern
        )
    }
    
    override public func chartDrawersContentViewDrawing(context context: CGContextRef, chart: Chart, view: UIView) {
        if !useView {
            for lineModel in lineModels {
                CGContextSetStrokeColorWithColor(context, lineModel.lineColor.CGColor)
                CGContextSetLineWidth(context, lineModel.lineWidth)
                CGContextSetLineJoin(context, lineModel.lineJoin.CGValue)
                CGContextSetLineCap(context, lineModel.lineCap.CGValue)
                for i in 0..<lineModel.chartPoints.count {
                    let chartPoint = lineModel.chartPoints[i]
                    let p1 = modelLocToScreenLoc(x: chartPoint.x.scalar, y: chartPoint.y.scalar)
                    CGContextMoveToPoint(context, p1.x, p1.y)
                    if i < lineModel.chartPoints.count - 1 {
                        let nextChartPoint = lineModel.chartPoints[i + 1]
                        let p2 = modelLocToScreenLoc(x: nextChartPoint.x.scalar, y: nextChartPoint.y.scalar)
                        CGContextAddLineToPoint(context, p2.x, p2.y)
                    }
                }
                CGContextStrokePath(context)
            }
        }
    }
    
    public override func modelLocToScreenLoc(x x: Double) -> CGFloat {
        return xAxis.screenLocForScalar(x) - (chart?.containerFrame.origin.x ?? 0)
    }
    
    public override func modelLocToScreenLoc(y y: Double) -> CGFloat {
        return yAxis.screenLocForScalar(y) - (chart?.containerFrame.origin.y ?? 0)
    }
    
    public override func zoom(scaleX: CGFloat, scaleY: CGFloat, centerX: CGFloat, centerY: CGFloat) {
        if !useView {
            chart?.drawersContentView.setNeedsDisplay()
        }
    }
    
    public override func zoom(x: CGFloat, y: CGFloat, centerX: CGFloat, centerY: CGFloat) {
        if !useView {
            chart?.drawersContentView.setNeedsDisplay()
        } else {
            updateScreenLines()
        }
    }
    
    public override func pan(deltaX: CGFloat, deltaY: CGFloat) {
        if !useView {
            chart?.drawersContentView.setNeedsDisplay()
        } else {
            updateScreenLines()
        }
    }

    private func updateScreenLines() {

        guard let chart = chart else {return}
        
        isTransform = true
        
        for i in 0..<screenLines.count {
            for j in 0..<screenLines[i].screenLine.points.count {
                let chartPoint = screenLines[i].screenLine.lineModel.chartPoints[j]
                screenLines[i].screenLine.points[j] = modelLocToScreenLoc(x: chartPoint.x.scalar, y: chartPoint.y.scalar)
            }
            
            screenLines[i].view.removeFromSuperview()
            screenLines[i].view = generateLineView(screenLines[i].screenLine, chart: chart)
            chart.addSubviewNoTransform(screenLines[i].view)
        }
        
        isTransform = false
    }
}
