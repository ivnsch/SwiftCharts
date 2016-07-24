//
//  ChartPointsLineLayer.swift
//  SwiftCharts
//
//  Created by ischuetz on 25/04/15.
//  Copyright (c) 2015 ivanschuetz. All rights reserved.
//

import UIKit

private struct ScreenLine {
    let points: [CGPoint]
    let color: UIColor
    let lineWidth: CGFloat
    let lineJoin: String
    let lineCap: String
    let animDuration: Float
    let animDelay: Float
    
    init(points: [CGPoint], color: UIColor, lineWidth: CGFloat, lineJoin: String, lineCap: String, animDuration: Float, animDelay: Float) {
        self.points = points
        self.color = color
        self.lineWidth = lineWidth
        self.lineJoin = lineJoin
        self.lineCap = lineCap
        self.animDuration = animDuration
        self.animDelay = animDelay
    }
}

public class ChartPointsLineLayer<T: ChartPoint>: ChartPointsLayer<T> {
    private var lineModels: [ChartLineModel<T>]
    private var lineViews: [ChartLinesView] = []
    private let pathGenerator: ChartLinesViewPathGenerator

    private let useView: Bool
    
    public init(xAxis: ChartAxis, yAxis: ChartAxis, lineModels: [ChartLineModel<T>], pathGenerator: ChartLinesViewPathGenerator = StraightLinePathGenerator(), displayDelay: Float = 0, useView: Bool = true) {
        
        self.lineModels = lineModels
        self.pathGenerator = pathGenerator
        self.useView = useView
        
        let chartPoints: [T] = lineModels.flatMap{$0.chartPoints}
        
        super.init(xAxis: xAxis, yAxis: yAxis, chartPoints: chartPoints, displayDelay: displayDelay)
    }
    
    private func toScreenLine(lineModel lineModel: ChartLineModel<T>, chart: Chart) -> ScreenLine {
        return ScreenLine(
            points: lineModel.chartPoints.map{self.chartPointScreenLoc($0)},
            color: lineModel.lineColor,
            lineWidth: lineModel.lineWidth,
            lineJoin: lineModel.lineJoin,
            lineCap: lineModel.lineCap,
            animDuration: lineModel.animDuration,
            animDelay: lineModel.animDelay
        )
    }
    
    override func display(chart chart: Chart) {
        if useView {
            let screenLines = self.lineModels.map{self.toScreenLine(lineModel: $0, chart: chart)}
            
            for screenLine in screenLines {
                let lineView = ChartLinesView(
                    path: self.pathGenerator.generatePath(points: screenLine.points, lineWidth: screenLine.lineWidth),
                    frame: chart.contentView.bounds,
                    lineColor: screenLine.color,
                    lineWidth: screenLine.lineWidth,
                    lineJoin: screenLine.lineJoin,
                    lineCap: screenLine.lineCap,
                    animDuration: self.isTransform ? 0 : screenLine.animDuration,
                    animDelay: self.isTransform ? 0 : screenLine.animDelay)
                
                self.lineViews.append(lineView)
                lineView.userInteractionEnabled = false
                chart.addSubview(lineView)
            }
        }
    }
    
    
    override public func chartDrawersContentViewDrawing(context context: CGContextRef, chart: Chart, view: UIView) {
        if !useView {
            for lineModel in lineModels {
                CGContextSetStrokeColorWithColor(context, lineModel.lineColor.CGColor)
                CGContextSetLineWidth(context, lineModel.lineWidth)
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
        return useView ? super.modelLocToScreenLoc(x: x) : xAxis.screenLocForScalar(x) - (chart?.containerFrame.origin.x ?? 0)
    }
    
    public override func modelLocToScreenLoc(y y: Double) -> CGFloat {
        return useView ? super.modelLocToScreenLoc(y: y) : yAxis.screenLocForScalar(y) - (chart?.containerFrame.origin.y ?? 0)
    }
    
    public override func zoom(scaleX: CGFloat, scaleY: CGFloat, centerX: CGFloat, centerY: CGFloat) {
        if !useView {
            chart?.drawersContentView.setNeedsDisplay()
        }
    }
    
    public override func zoom(x: CGFloat, y: CGFloat, centerX: CGFloat, centerY: CGFloat) {
        if !useView {
            chart?.drawersContentView.setNeedsDisplay()
        }
    }
    
    public override func pan(deltaX: CGFloat, deltaY: CGFloat) {
        if !useView {
            chart?.drawersContentView.setNeedsDisplay()
        }
    }
}
