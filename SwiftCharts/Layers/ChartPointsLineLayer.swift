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
    let animDuration: Float
    let animDelay: Float
    let dashPattern: [Double]?
    
    init(points: [CGPoint], color: UIColor, lineWidth: CGFloat, animDuration: Float, animDelay: Float, dashPattern: [Double]?) {
        self.points = points
        self.color = color
        self.lineWidth = lineWidth
        self.animDuration = animDuration
        self.animDelay = animDelay
        self.dashPattern = dashPattern
    }
}

open class ChartPointsLineLayer<T: ChartPoint>: ChartPointsLayer<T> {
    fileprivate let lineModels: [ChartLineModel<T>]
    fileprivate var lineViews: [ChartLinesView] = []
    fileprivate let pathGenerator: ChartLinesViewPathGenerator
    
    public init(xAxis: ChartAxisLayer, yAxis: ChartAxisLayer, innerFrame: CGRect, lineModels: [ChartLineModel<T>], pathGenerator: ChartLinesViewPathGenerator = StraightLinePathGenerator(), displayDelay: Float = 0) {
        
        self.lineModels = lineModels
        self.pathGenerator = pathGenerator
        
        let chartPoints: [T] = lineModels.flatMap{$0.chartPoints}
        
        super.init(xAxis: xAxis, yAxis: yAxis, innerFrame: innerFrame, chartPoints: chartPoints, displayDelay: displayDelay)
    }
    
    fileprivate func toScreenLine(lineModel: ChartLineModel<T>, chart: Chart) -> ScreenLine {
        return ScreenLine(
            points: lineModel.chartPoints.map{self.chartPointScreenLoc($0)},
            color: lineModel.lineColor,
            lineWidth: lineModel.lineWidth,
            animDuration: lineModel.animDuration,
            animDelay: lineModel.animDelay,
            dashPattern: lineModel.dashPattern
        )
    }
    
    override func display(chart: Chart) {
        let screenLines = self.lineModels.map{self.toScreenLine(lineModel: $0, chart: chart)}
        
        for screenLine in screenLines {
            let lineView = ChartLinesView(
                path: self.pathGenerator.generatePath(points: screenLine.points, lineWidth: screenLine.lineWidth),
                frame: chart.bounds,
                lineColor: screenLine.color,
                lineWidth: screenLine.lineWidth,
                animDuration: screenLine.animDuration,
                animDelay: screenLine.animDelay,
                dashPattern: screenLine.dashPattern)
            
            self.lineViews.append(lineView)
            lineView.isUserInteractionEnabled = false
            chart.addSubview(lineView)
        }
    }
    
}
