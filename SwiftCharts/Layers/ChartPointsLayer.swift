//
//  ChartPointsLayer.swift
//  SwiftCharts
//
//  Created by ischuetz on 25/04/15.
//  Copyright (c) 2015 ivanschuetz. All rights reserved.
//

import UIKit

public struct ChartPointLayerModel<T: ChartPoint>: CustomDebugStringConvertible {
    public let chartPoint: T
    public let index: Int
    public var screenLoc: CGPoint
    
    init(chartPoint: T, index: Int, screenLoc: CGPoint) {
        self.chartPoint = chartPoint
        self.index = index
        self.screenLoc = screenLoc
    }
    
    func copy(chartPoint: T? = nil, index: Int? = nil, screenLoc: CGPoint? = nil) -> ChartPointLayerModel<T> {
        return ChartPointLayerModel(
            chartPoint: chartPoint ?? self.chartPoint,
            index: index ?? self.index,
            screenLoc: screenLoc ?? self.screenLoc
        )
    }
    
    public var debugDescription: String {
        return "chartPoint: \(chartPoint), index: \(index), screenLoc: \(screenLoc)"
    }
}

public struct TappedChartPointLayerModel<T: ChartPoint> {
    public let model: ChartPointLayerModel<T>
    public let distance: CGFloat
    
    init(model: ChartPointLayerModel<T>, distance: CGFloat) {
        self.model = model
        self.distance = distance
    }
}


public struct TappedChartPointLayerModels<T: ChartPoint> {
    public let models: [TappedChartPointLayerModel<T>]
    public let layer: ChartPointsLayer<T>
    
    init(models: [TappedChartPointLayerModel<T>], layer: ChartPointsLayer<T>) {
        self.models = models
        self.layer = layer
    }
}

public struct ChartPointsTapSettings<T: ChartPoint> {
    public let radius: CGFloat
    let handler: (TappedChartPointLayerModels<T> -> Void)?
    
    public init(radius: CGFloat = 30, handler: (TappedChartPointLayerModels<T> -> Void)? = nil) {
        self.radius = radius
        self.handler = handler
    }
}

public class ChartPointsLayer<T: ChartPoint>: ChartCoordsSpaceLayer {

    public internal(set) var chartPointsModels: [ChartPointLayerModel<T>] = []
    
    private let displayDelay: Float
    
    public var chartPointScreenLocs: [CGPoint] {
        return self.chartPointsModels.map{$0.screenLoc}
    }
    
    private let chartPoints: [T]

    private let tapSettings: ChartPointsTapSettings<T>?
    
    public init(xAxis: ChartAxis, yAxis: ChartAxis, chartPoints: [T], displayDelay: Float = 0, tapSettings: ChartPointsTapSettings<T>? = nil) {
        self.chartPoints = chartPoints
        self.displayDelay = displayDelay
        self.tapSettings = tapSettings
        
        super.init(xAxis: xAxis, yAxis: yAxis)
    }

    public override func handleGlobalTap(location: CGPoint) -> Any? {
        guard let tapSettings = tapSettings, localCenter = toLocalCoordinates(location) else {return nil}
        var models: [TappedChartPointLayerModel<T>] = []
        for chartPointModel in chartPointsModels {
            let transformedScreenLoc = modelLocToScreenLoc(x: chartPointModel.chartPoint.x.scalar, y: chartPointModel.chartPoint.y.scalar)
            let distance = transformedScreenLoc.distance(localCenter)
            if distance < tapSettings.radius {
                models.append(TappedChartPointLayerModel(model: chartPointModel.copy(screenLoc: containerToGlobalScreenLoc(chartPointModel.chartPoint)), distance: distance))
            }
        }
        
        let tappedModels = TappedChartPointLayerModels(models: models, layer: self)
        
        tapSettings.handler?(tappedModels)
        
        return tappedModels
    }
    
    func toLocalCoordinates(globalPoint: CGPoint) -> CGPoint? {
        return globalPoint
    }
    
    override public func chartInitialized(chart chart: Chart) {
        super.chartInitialized(chart: chart)
        
        initChartPointModels()
        
        if self.isTransform || self.displayDelay == 0 {
            self.display(chart: chart)
        } else {
            dispatch_after(ChartTimeUtils.toDispatchTime(self.displayDelay), dispatch_get_main_queue()) {() -> Void in
                self.display(chart: chart)
            }
        }
    }
    
    func initChartPointModels() {
        chartPointsModels = generateChartPointModels(chartPoints)
    }
    
    func generateChartPointModels(chartPoints: [T]) -> [ChartPointLayerModel<T>] {
        return chartPoints.enumerate().map {index, chartPoint in
            ChartPointLayerModel(chartPoint: chartPoint, index: index, screenLoc: modelLocToScreenLoc(x: chartPoint.x.scalar, y: chartPoint.y.scalar))
        }
    }
    
    func display(chart chart: Chart) {}
    
    public override func handleAxisInnerFrameChange(xLow: ChartAxisLayerWithFrameDelta?, yLow: ChartAxisLayerWithFrameDelta?, xHigh: ChartAxisLayerWithFrameDelta?, yHigh: ChartAxisLayerWithFrameDelta?) {
        super.handleAxisInnerFrameChange(xLow, yLow: yLow, xHigh: xHigh, yHigh: yHigh)

        chartPointsModels = chartPoints.enumerate().map {index, chartPoint in
            return ChartPointLayerModel(chartPoint: chartPoint, index: index, screenLoc: modelLocToScreenLoc(x: chartPoint.x.scalar, y: chartPoint.y.scalar))
        }
    }
    
    public func chartPointScreenLoc(chartPoint: ChartPoint) -> CGPoint {
        return self.modelLocToScreenLoc(x: chartPoint.x.scalar, y: chartPoint.y.scalar)
    }
    
    public func chartPointsForScreenLoc(screenLoc: CGPoint) -> [T] {
        return self.filterChartPoints { $0 == screenLoc }
    }
    
    public func chartPointsForScreenLocX(x: CGFloat) -> [T] {
        return self.filterChartPoints { $0.x =~ x }
    }
    
    public func chartPointsForScreenLocY(y: CGFloat) -> [T] {
        return self.filterChartPoints { $0.y =~ y }

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
    
    func updateChartPointsScreenLocations() {
        chartPointsModels = updateChartPointsScreenLocations(chartPointsModels)
    }
    
    func updateChartPointsScreenLocations(chartPointsModels: [ChartPointLayerModel<T>]) -> [ChartPointLayerModel<T>] {
        var chartPointsModelsVar = chartPointsModels
        for i in 0..<chartPointsModelsVar.count {
            let chartPointModel = chartPointsModelsVar[i]
            chartPointsModelsVar[i].screenLoc = CGPointMake(xAxis.screenLocForScalar(chartPointModel.chartPoint.x.scalar), yAxis.screenLocForScalar(chartPointModel.chartPoint.y.scalar))
        }
        return chartPointsModelsVar
    }
}
