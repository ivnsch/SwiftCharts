//
//  ChartPointsTrackerLayer.swift
//  swift_charts
//
//  Created by ischuetz on 16/04/15.
//  Copyright (c) 2015 ivanschuetz. All rights reserved.
//

import UIKit

public struct ChartPointsLineTrackerLayerThumbSettings {
    let thumbSize: CGFloat
    let thumbBorderWidth: CGFloat
    let thumbBorderColor: UIColor
    
    public init(thumbSize: CGFloat, thumbBorderWidth: CGFloat = 4, thumbBorderColor: UIColor = UIColor.blackColor()) {
        self.thumbSize = thumbSize
        self.thumbBorderWidth = thumbBorderWidth
        self.thumbBorderColor = thumbBorderColor
    }
}

public struct ChartPointsLineTrackerLayerSettings {
    let thumbSettings: ChartPointsLineTrackerLayerThumbSettings? // nil -> no thumb
    let selectNearest: Bool
    
    public init(thumbSettings: ChartPointsLineTrackerLayerThumbSettings? = nil, selectNearest: Bool = false) {
        self.thumbSettings = thumbSettings
        self.selectNearest = selectNearest
    }
}


public struct ChartTrackerSelectedChartPoint<T: ChartPoint, U>: CustomDebugStringConvertible {
    
    public let chartPoint: T
    public let screenLoc: CGPoint
    public let lineIndex: Int
    public let lineModel: ChartTrackerLineLayerModel<T, U>
    public let lineExtra: U?
    
    init(chartPoint: T, intersection: ChartTrackerIntersection<T, U>) {
        self.init(chartPoint: chartPoint, screenLoc: intersection.screenLoc, lineIndex: intersection.lineIndex, lineModel: intersection.lineModel, lineExtra: intersection.lineModel.extra)
    }
    
    init(chartPoint: T, screenLoc: CGPoint, lineIndex: Int, lineModel: ChartTrackerLineLayerModel<T, U>, lineExtra: U?) {
        self.chartPoint = chartPoint
        self.screenLoc = screenLoc
        self.lineIndex = lineIndex
        self.lineModel = lineModel
        self.lineExtra = lineExtra
    }
    
    func copy(chartPoint: T? = nil, screenLoc: CGPoint? = nil, lineIndex: Int? = nil, lineModel: ChartTrackerLineLayerModel<T, U>? = nil, lineExtra: U? = nil) -> ChartTrackerSelectedChartPoint<T, U> {
        return ChartTrackerSelectedChartPoint(
            chartPoint: chartPoint ?? self.chartPoint,
            screenLoc: screenLoc ?? self.screenLoc,
            lineIndex: lineIndex ?? self.lineIndex,
            lineModel: lineModel ?? self.lineModel,
            lineExtra: lineExtra ?? self.lineExtra
        )
    }
    
    public var debugDescription: String {
        return "chartPoint: \(chartPoint), screenLoc: \(screenLoc), lineIndex: \(lineIndex), lineModel: \(lineModel)"
    }
}

public struct ChartTrackerIntersection<T: ChartPoint, U> {
    let screenLoc: CGPoint
    let lineIndex: Int
    let lineModel: ChartTrackerLineLayerModel<T, U>
    
    init(screenLoc: CGPoint, lineIndex: Int, lineModel: ChartTrackerLineLayerModel<T, U>) {
        self.screenLoc = screenLoc
        self.lineIndex = lineIndex
        self.lineModel = lineModel
    }
}

public struct ChartTrackerLineModel<T: ChartPoint, U> {
    public let chartPoints: [T]
    public let extra: U?
    
    public init(chartPoints: [T]) {
        self.init(chartPoints: chartPoints, extra: nil)
    }
    
    /// extra: optional object which is passed back with the line in the position update handler. Can be for example an id to group certain lines together, a color, etc.
    public init(chartPoints: [T], extra: U?) {
        self.chartPoints = chartPoints
        self.extra = extra
    }
}

public struct ChartTrackerLineLayerModel<T: ChartPoint, U> {
    public let chartPointModels: [ChartPointLayerModel<T>]
    public let extra: U?
    
    init(chartPointModels: [ChartPointLayerModel<T>], extra: U?) {
        self.chartPointModels = chartPointModels
        self.extra = extra
    }
    
    func copy(chartPointModels: [ChartPointLayerModel<T>]? = nil, extra: U?? = nil) -> ChartTrackerLineLayerModel {
        return ChartTrackerLineLayerModel(
            chartPointModels: chartPointModels ?? self.chartPointModels,
            extra: extra ?? self.extra
        )
    }
}

public class ChartPointsLineTrackerLayer<T: ChartPoint, U>: ChartPointsLayer<T> {
    
    private let lineColor: UIColor
    private let animDuration: Float
    private let animDelay: Float
    
    private let settings: ChartPointsLineTrackerLayerSettings

    private var isTracking: Bool = false
    
    public var positionUpdateHandler: ([ChartTrackerSelectedChartPoint<T, U>] -> Void)?
    
    public let lines: [ChartTrackerLineModel<T, U>]
    public var lineModels: [ChartTrackerLineLayerModel<T, U>] = []
    
    private var currentIntersections: [ChartTrackerIntersection<T, U>] = []
    
    public convenience init(xAxis: ChartAxis, yAxis: ChartAxis, lines: [[T]], lineColor: UIColor, animDuration: Float, animDelay: Float, settings: ChartPointsLineTrackerLayerSettings, positionUpdateHandler: ([ChartTrackerSelectedChartPoint<T, U>] -> Void)? = nil) {
        self.init(xAxis: xAxis, yAxis: yAxis, lines: lines.map{ChartTrackerLineModel(chartPoints: $0)}, lineColor: lineColor, animDuration: animDuration, animDelay: animDelay, settings: settings, positionUpdateHandler: positionUpdateHandler)
    }
    
    public init(xAxis: ChartAxis, yAxis: ChartAxis, lines: [ChartTrackerLineModel<T, U>], lineColor: UIColor, animDuration: Float, animDelay: Float, settings: ChartPointsLineTrackerLayerSettings, positionUpdateHandler: ([ChartTrackerSelectedChartPoint<T, U>] -> Void)? = nil) {
        self.lineColor = lineColor
        self.animDuration = animDuration
        self.animDelay = animDelay
        self.settings = settings
        self.positionUpdateHandler = positionUpdateHandler
        self.lines = lines
        super.init(xAxis: xAxis, yAxis: yAxis, chartPoints: Array(lines.map{$0.chartPoints}.flatten()))
    }

    private func linesIntersection(line1P1 line1P1: CGPoint, line1P2: CGPoint, line2P1: CGPoint, line2P2: CGPoint) -> CGPoint? {
        return self.findLineIntersection(p0X: line1P1.x, p0y: line1P1.y, p1x: line1P2.x, p1y: line1P2.y, p2x: line2P1.x, p2y: line2P1.y, p3x: line2P2.x, p3y: line2P2.y)
    }
    
    override func initChartPointModels() {
        lineModels = lines.map{ChartTrackerLineLayerModel<T, U>(chartPointModels: generateChartPointModels($0.chartPoints), extra: $0.extra)}
        chartPointsModels = Array(lineModels.map{$0.chartPointModels}.flatten()) // consistency
    }
    
    override func updateChartPointsScreenLocations() {
        super.updateChartPointsScreenLocations()
        for i in 0..<lineModels.count {
            let line = lineModels[i]
            let updatedChartPoints = updateChartPointsScreenLocations(line.chartPointModels)
            let updatedLine = line.copy(updatedChartPoints)
            lineModels[i] = updatedLine
        }
    }
    
    // src: http://stackoverflow.com/a/14795484/930450 (modified)
    private func findLineIntersection(p0X p0X: CGFloat , p0y: CGFloat, p1x: CGFloat, p1y: CGFloat, p2x: CGFloat, p2y: CGFloat, p3x: CGFloat, p3y: CGFloat) -> CGPoint? {
        
        var s02x: CGFloat, s02y: CGFloat, s10x: CGFloat, s10y: CGFloat, s32x: CGFloat, s32y: CGFloat, sNumer: CGFloat, tNumer: CGFloat, denom: CGFloat, t: CGFloat;
        
        s10x = p1x - p0X
        s10y = p1y - p0y
        s32x = p3x - p2x
        s32y = p3y - p2y
        
        denom = s10x * s32y - s32x * s10y
        if denom =~ 0 {
            return nil // Collinear
        }
        let denomPositive: Bool = denom > 0
        
        s02x = p0X - p2x
        s02y = p0y - p2y
        sNumer = s10x * s02y - s10y * s02x
        if (sNumer < 0) == denomPositive {
            return nil // No collision
        }
        
        tNumer = s32x * s02y - s32y * s02x
        if (tNumer < 0) == denomPositive {
            return nil // No collision
        }
        if ((sNumer > denom) == denomPositive) || ((tNumer > denom) == denomPositive) {
            return nil // No collision
        }
        
        // Collision detected
        t = tNumer / denom
        let i_x = p0X + (t * s10x)
        let i_y = p0y + (t * s10y)
        return CGPoint(x: i_x, y: i_y)
    }
    
    private func intersectsWithChartPointLines(rect: CGRect) -> Bool {
        let rectLines = rect.asLinesArray()
        return iterateLineSegments({p1, p2, _, _ in
            for rectLine in rectLines {
                if self.linesIntersection(line1P1: rectLine.p1, line1P2: rectLine.p2, line2P1: p1.screenLoc, line2P2: p2.screenLoc) != nil {
                    return true
                }
            }
            return nil
        }) ?? false
    }

    private func intersectsWithTrackerLine(rect: CGRect) -> Bool {
        
        guard let currentIntersection = currentIntersections.first else {return false}
        
        let rectLines = rect.asLinesArray()
        
        let line = toLine(currentIntersection.screenLoc)
        
        for rectLine in rectLines {
            if linesIntersection(line1P1: rectLine.p1, line1P2: rectLine.p2, line2P1: line.p1, line2P2: line.p2) != nil {
                return true
            }
        }
        
        return false
    }
   
    private func updateTrackerLineOnValidState(updateFunc updateFunc: (view: UIView) -> ()) {
        if !self.chartPointsModels.isEmpty {
            if let view = chart?.contentView {
                updateFunc(view: view)
            }
        }
    }
    
    /// f: function to be applied to each segment in the lines defined by p1, p2. Returns an object of type U to exit, returning it from the outer function, or nil to continue
    private func iterateLineSegments<V>(f: (p1: ChartPointLayerModel<T>, p2: ChartPointLayerModel<T>, lineIndex: Int, line: ChartTrackerLineLayerModel<T, U>) -> V?) -> V? {
        for (index, line) in lineModels.enumerate() {
            let lineChartPoints = line.chartPointModels
            
            guard !lineChartPoints.isEmpty else {continue}
            
            for i in 0..<(lineChartPoints.count - 1) {
                let m1 = lineChartPoints[i]
                let m2 = lineChartPoints[i + 1]
                
                if let res = f(p1: m1, p2: m2, lineIndex: index, line: line) {
                    return res
                }
            }
        }
        return nil
    }
    
    private func updateTrackerLine(touchPoint touchPoint: CGPoint) {
        
        self.updateTrackerLineOnValidState{(view) in
            
            let constantX = touchPoint.x
            
            let touchlineP1 = CGPointMake(constantX, 0)
            let touchlineP2 = CGPointMake(constantX, view.frame.size.height)
            
            var intersections: [ChartTrackerIntersection<T, U>] = []
            
            let _: Any? = self.iterateLineSegments({p1, p2, lineIndex, lineModel in
                if let intersection = self.linesIntersection(line1P1: touchlineP1, line1P2: touchlineP2, line2P1: p1.screenLoc, line2P2: p2.screenLoc) {
                    intersections.append(ChartTrackerIntersection<T, U>(screenLoc: intersection, lineIndex: lineIndex, lineModel: lineModel))
                }
                return nil
            })
            
            if !intersections.isEmpty {
                
                self.currentIntersections = self.settings.selectNearest ? touchPoint.nearest(intersections, pointMapper: {$0.screenLoc}).map{[$0.pointMappable]} ?? [] : intersections
                self.isTracking = true
                
                if self.chartPointsModels.count > 1 {
                    
                    let chartPoints: [ChartTrackerSelectedChartPoint<T, U>] = intersections.map {intersection in
                        
                        // the charpoints as well as the touch (-> intersection) use global coordinates, to draw in drawer container we have to translate to its coordinates
                        let trans = self.globalToDrawersContainerCoordinates(intersection.screenLoc)!
                        
                        let zoomedAxisX = self.xAxis.firstVisibleScreen - self.xAxis.firstScreen + trans.x
                        let zoomedAxisY = self.yAxis.lastVisibleScreen - self.yAxis.lastScreen + trans.y
                        
                        let xScalar = self.xAxis.innerScalarForScreenLoc(zoomedAxisX)
                        let yScalar = self.yAxis.innerScalarForScreenLoc(zoomedAxisY)
                        
                        let dummyModel = self.chartPointsModels[0]
                        let x = dummyModel.chartPoint.x.copy(xScalar)
                        let y = dummyModel.chartPoint.y.copy(yScalar)
                        
                        let chartPoint = T(x: x, y: y)
                        
                        return ChartTrackerSelectedChartPoint<T, U>(chartPoint: chartPoint, intersection: intersection)
                    }
                    
                    self.positionUpdateHandler?(chartPoints)
                }
                
            } else {
                self.clearIntersections()
            }
        }
    }

    private func toLine(intersection: CGPoint) -> (p1: CGPoint, p2: CGPoint) {
        return (p1: CGPointMake(intersection.x, 0), p2: CGPointMake(intersection.x, 10000000))
    }
    
    override public func chartDrawersContentViewDrawing(context context: CGContextRef, chart: Chart, view: UIView) {

        guard let firstIntersection = currentIntersections.first else {return}

        
        CGContextSetStrokeColorWithColor(context, UIColor.blackColor().CGColor)
        CGContextSetLineWidth(context, 2)
        
        let coords = globalToDrawersContainerCoordinates(firstIntersection.screenLoc)!
        let line = toLine(coords)
        
        CGContextMoveToPoint(context, line.p1.x, line.p1.y)
        CGContextAddLineToPoint(context, line.p2.x, line.p2.y)

        CGContextStrokePath(context)
        
        if let thumbSettings = settings.thumbSettings {
            
            for intersection in currentIntersections {
                let coords = globalToDrawersContainerCoordinates(intersection.screenLoc)!
                CGContextSetStrokeColorWithColor(context, UIColor.blackColor().CGColor)
                CGContextStrokeEllipseInRect(context, CGRectMake(coords.x - thumbSettings.thumbSize / 2, coords.y - thumbSettings.thumbSize / 2, thumbSettings.thumbSize, thumbSettings.thumbSize))
            }
        }
    }
    
    public override func handlePanStart(location: CGPoint) {
        guard let localLocation = toLocalCoordinates(location) else {return}
        
        updateChartPointsScreenLocations()
        
        let surroundingRect = localLocation.surroundingRect(30)
        
        if intersectsWithChartPointLines(surroundingRect) || intersectsWithTrackerLine(surroundingRect) {
            isTracking = true
        } else {
            clearIntersections()
        }
    }
    
    private func clearIntersections() {
        currentIntersections = []
        positionUpdateHandler?([])
    }
    
    public override func processPan(location location: CGPoint, deltaX: CGFloat, deltaY: CGFloat, isGesture: Bool, isDeceleration: Bool) -> Bool {
        guard let localLocation = toLocalCoordinates(location) else {return false}
        
        if isTracking {
            updateTrackerLine(touchPoint: localLocation)
            chart?.drawersContentView.setNeedsDisplay()
            return true
        } else {
            return false
        }
    }
    
    public override func handleGlobalTap(location: CGPoint) -> Any? {
        guard let localLocation = toLocalCoordinates(location) else {return nil}
        
        updateChartPointsScreenLocations()
        
        updateTrackerLine(touchPoint: localLocation)
        chart?.drawersContentView.setNeedsDisplay()

        return nil
    }
    
    public override func handlePanEnd() {
        isTracking = false
    }
    
    public override func handleZoomEnd() {
        super.handleZoomEnd()
//        updateChartPointsScreenLocations()
    }
    
    public override func modelLocToScreenLoc(x x: Double) -> CGFloat {
        return xAxis.screenLocForScalar(x) - (chart?.containerFrame.origin.x ?? 0)
    }
    
    public override func modelLocToScreenLoc(y y: Double) -> CGFloat {
        return yAxis.screenLocForScalar(y) - (chart?.containerFrame.origin.y ?? 0)
    }
    
    public override func zoom(scaleX: CGFloat, scaleY: CGFloat, centerX: CGFloat, centerY: CGFloat) {
        chart?.drawersContentView.setNeedsDisplay()
        
        clearIntersections()
    }
    
    public override func zoom(x: CGFloat, y: CGFloat, centerX: CGFloat, centerY: CGFloat) {
        super.zoom(x, y: y, centerX: centerX, centerY: centerY)
        clearIntersections()
        chart?.drawersContentView.setNeedsDisplay()
    }
    
    public override func pan(deltaX: CGFloat, deltaY: CGFloat) {
        super.pan(deltaX, deltaY: deltaY)
        chart?.drawersContentView.setNeedsDisplay()
    }
}