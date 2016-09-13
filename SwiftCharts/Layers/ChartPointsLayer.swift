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

open class ChartPointsLayer<T: ChartPoint>: ChartCoordsSpaceLayer {

    open let chartPointsModels: [ChartPointLayerModel<T>]
    
    fileprivate let displayDelay: Float
    
    open var chartPointScreenLocs: [CGPoint] {
        return self.chartPointsModels.map{$0.screenLoc}
    }
    
    public init(xAxis: ChartAxisLayer, yAxis: ChartAxisLayer, innerFrame: CGRect, chartPoints: [T], displayDelay: Float = 0) {
        self.chartPointsModels = chartPoints.enumerated().map {index, chartPoint in
            let screenLoc = CGPoint(x: xAxis.screenLocForScalar(chartPoint.x.scalar), y: yAxis.screenLocForScalar(chartPoint.y.scalar))
            return ChartPointLayerModel(chartPoint: chartPoint, index: index, screenLoc: screenLoc)
        }
        
        self.displayDelay = displayDelay
        
        super.init(xAxis: xAxis, yAxis: yAxis, innerFrame: innerFrame)
    }


    override open func chartInitialized(chart: Chart) {
        if self.displayDelay == 0 {
            self.display(chart: chart)
        } else {
            DispatchQueue.main.asyncAfter(deadline: ChartUtils.toDispatchTime(self.displayDelay)) {() -> Void in
                self.display(chart: chart)
            }
        }
    }
    
    func display(chart: Chart) {}
    
    open func chartPointScreenLoc(_ chartPoint: ChartPoint) -> CGPoint {
        return self.modelLocToScreenLoc(x: chartPoint.x.scalar, y: chartPoint.y.scalar)
    }
    
    open func modelLocToScreenLoc(x: Double, y: Double) -> CGPoint {
        return CGPoint(
            x: self.xAxis.screenLocForScalar(x),
            y: self.yAxis.screenLocForScalar(y))
    }
    
    open func chartPointsForScreenLoc(_ screenLoc: CGPoint) -> [T] {
        return self.filterChartPoints { $0 == screenLoc }
    }
    
    open func chartPointsForScreenLocX(_ x: CGFloat) -> [T] {
        return self.filterChartPoints { $0.x == x }
    }
    
    open func chartPointsForScreenLocY(_ y: CGFloat) -> [T] {
        return self.filterChartPoints { $0.y == y }

    }

    // smallest screen space between chartpoints on x axis
    open lazy var minXScreenSpace: CGFloat = {
        return self.minAxisScreenSpace{$0.x}
    }()
    
    // smallest screen space between chartpoints on y axis
    open lazy var minYScreenSpace: CGFloat = {
        return self.minAxisScreenSpace{$0.y}
    }()
    
    fileprivate func minAxisScreenSpace(dimPicker: (CGPoint) -> CGFloat) -> CGFloat {
        return self.chartPointsModels.reduce((CGFloat.greatestFiniteMagnitude, -CGFloat.greatestFiniteMagnitude)) {tuple, viewWithChartPoint in
            let minSpace = tuple.0
            let previousScreenLoc = tuple.1
            return (min(minSpace, abs(dimPicker(viewWithChartPoint.screenLoc) - previousScreenLoc)), dimPicker(viewWithChartPoint.screenLoc))
        }.0
    }
    
    fileprivate func filterChartPoints(_ includePoint: (CGPoint) -> Bool) -> [T] {
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
