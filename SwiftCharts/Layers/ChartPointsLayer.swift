//
//  ChartPointsLayer.swift
//  SwiftCharts
//
//  Created by ischuetz on 25/04/15.
//  Copyright (c) 2015 ivanschuetz. All rights reserved.
//

import UIKit

public struct ChartPointLayerModel<T: ChartPoint> {
    public let chartPoint: T
    public let index: Int
    public let screenLoc: CGPoint
    
    init(chartPoint: T, index: Int, screenLoc: CGPoint) {
        self.chartPoint = chartPoint
        self.index = index
        self.screenLoc = screenLoc
    }
}

public class ChartPointsLayer<T: ChartPoint>: ChartCoordsSpaceLayer {

    public let chartPointsModels: [ChartPointLayerModel<T>]
    
    private let displayDelay: Float
    
    public var chartPointScreenLocs: [CGPoint] {
        return self.chartPointsModels.map{$0.screenLoc}
    }
    
    public init(xAxis: ChartAxisLayer, yAxis: ChartAxisLayer, innerFrame: CGRect, chartPoints: [T], displayDelay: Float = 0) {
        self.chartPointsModels = chartPoints.enumerate().map {index, chartPoint in
            let screenLoc = CGPointMake(xAxis.screenLocForScalar(chartPoint.x.scalar), yAxis.screenLocForScalar(chartPoint.y.scalar))
            return ChartPointLayerModel(chartPoint: chartPoint, index: index, screenLoc: screenLoc)
        }
        
        self.displayDelay = displayDelay
        
        super.init(xAxis: xAxis, yAxis: yAxis, innerFrame: innerFrame)
    }


    override public func chartInitialized(chart chart: Chart) {
        if self.displayDelay == 0 {
            self.display(chart: chart)
        } else {
            dispatch_after(ChartUtils.toDispatchTime(self.displayDelay), dispatch_get_main_queue()) {() -> Void in
                self.display(chart: chart)
            }
        }
    }
    
    func display(chart chart: Chart) {}
    
    public func chartPointScreenLoc(chartPoint: ChartPoint) -> CGPoint {
        return self.modelLocToScreenLoc(x: chartPoint.x.scalar, y: chartPoint.y.scalar)
    }
    
    public func modelLocToScreenLoc(x x: Double, y: Double) -> CGPoint {
        return CGPointMake(
            self.xAxis.screenLocForScalar(x),
            self.yAxis.screenLocForScalar(y))
    }
    
    public func chartPointsForScreenLoc(screenLoc: CGPoint) -> [T] {
        return self.filterChartPoints { $0 == screenLoc }
    }
    
    public func chartPointsForScreenLocX(x: CGFloat) -> [T] {
        return self.filterChartPoints { $0.x == x }
    }
    
    public func chartPointsForScreenLocY(y: CGFloat) -> [T] {
        return self.filterChartPoints { $0.y == y }

    }

    // smallest screen space between chartpoints on x axis
    public lazy var minXScreenSpace: CGFloat = {
        return self.minAxisScreenSpace{$0.x}
    }()
    
    // smallest screen space between chartpoints on y axis
    public lazy var minYScreenSpace: CGFloat = {
        return self.minAxisScreenSpace{$0.y}
    }()
    
    private func minAxisScreenSpace(dimPicker dimPicker: (CGPoint) -> CGFloat) -> CGFloat {
        return self.chartPointsModels.reduce((CGFloat.max, -CGFloat.max)) {tuple, viewWithChartPoint in
            let minSpace = tuple.0
            let previousScreenLoc = tuple.1
            return (min(minSpace, abs(dimPicker(viewWithChartPoint.screenLoc) - previousScreenLoc)), dimPicker(viewWithChartPoint.screenLoc))
        }.0
    }
    
    private func filterChartPoints(includePoint: (CGPoint) -> Bool) -> [T] {
        return self.chartPointsModels.reduce(Array<T>()) { includedPoints, chartPointModel in
            let chartPoint = chartPointModel.chartPoint
            if includePoint(self.chartPointScreenLoc(chartPoint)) {
                return includedPoints + [chartPoint]
            } else {
                return includedPoints
            }
        }
    }
}
