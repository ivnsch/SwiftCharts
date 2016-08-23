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
    
    public init(thumbSettings: ChartPointsLineTrackerLayerThumbSettings? = nil) {
        self.thumbSettings = thumbSettings
    }
}

public class ChartPointsLineTrackerLayer<T: ChartPoint>: ChartPointsLayer<T> {
    
    private let lineColor: UIColor
    private let animDuration: Float
    private let animDelay: Float
    
    private let settings: ChartPointsLineTrackerLayerSettings

    private var isTracking: Bool = false

    public var positionUpdateHandler: (ChartPoint -> Void)?
    
    public init(xAxis: ChartAxis, yAxis: ChartAxis, innerFrame: CGRect, chartPoints: [T], lineColor: UIColor, animDuration: Float, animDelay: Float, settings: ChartPointsLineTrackerLayerSettings, positionUpdateHandler: (ChartPoint -> Void)? = nil) {
        self.lineColor = lineColor
        self.animDuration = animDuration
        self.animDelay = animDelay
        self.settings = settings
        self.positionUpdateHandler = positionUpdateHandler
        super.init(xAxis: xAxis, yAxis: yAxis, chartPoints: chartPoints)
    }

    private func linesIntersection(line1P1 line1P1: CGPoint, line1P2: CGPoint, line2P1: CGPoint, line2P2: CGPoint) -> CGPoint? {
        return self.findLineIntersection(p0X: line1P1.x, p0y: line1P1.y, p1x: line1P2.x, p1y: line1P2.y, p2x: line2P1.x, p2y: line2P1.y, p3x: line2P2.x, p3y: line2P2.y)
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
    
    private func intersect(rect: CGRect) -> Bool {

        let rectLines = rect.asLinesArray()
        
        for i in 0..<(chartPointsModels.count - 1) {
            let m1 = chartPointsModels[i]
            let m2 = chartPointsModels[i + 1]
            
            for rectLine in rectLines {
                if linesIntersection(line1P1: rectLine.p1, line1P2: rectLine.p2, line2P1: m1.screenLoc, line2P2: m2.screenLoc) != nil {
                    return true
                }
            }
        }
        
        return false
    }

    private func intersectLine(rect: CGRect) -> Bool {
        
        guard let currentIntersection = currentIntersection else {return false}
        
        let rectLines = rect.asLinesArray()
        
        let line = toLine(currentIntersection)
        
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
    
    private var currentIntersection: CGPoint?
    
    private func updateTrackerLine(touchPoint touchPoint: CGPoint) {
        
        self.updateTrackerLineOnValidState{(view) in
            
            let touchlineP1 = CGPointMake(touchPoint.x, 0)
            let touchlineP2 = CGPointMake(touchPoint.x, view.frame.size.height)
            
            var intersections: [CGPoint] = []
            for i in 0..<(self.chartPointsModels.count - 1) {
                let m1 = self.chartPointsModels[i]
                let m2 = self.chartPointsModels[i + 1]
                if let intersection = self.linesIntersection(line1P1: touchlineP1, line1P2: touchlineP2, line2P1: m1.screenLoc, line2P2: m2.screenLoc) {
                    intersections.append(intersection)
                }
            }

            // Select point with smallest distance to touch point.
            // If there's only one intersection, returns intersection. If there's no intersection returns nil.
            let intersectionMaybe: CGPoint? = {
                var minDistancePoint: (distance: Float, point: CGPoint?) = (MAXFLOAT, nil)
                for intersection in intersections {
                    let distance = hypotf(Float(intersection.x - touchPoint.x), Float(intersection.y - touchPoint.y))
                    if distance < minDistancePoint.0 {
                        minDistancePoint = (distance, intersection)
                    }
                }
                return minDistancePoint.point
            }()
            
            if let intersection = intersectionMaybe {
                self.currentIntersection = intersection
                self.isTracking = true

                if self.chartPointsModels.count > 1 {
                    // the charpoints as well as the touch (-> intersection) use global coordinates, to draw in drawer container we have to translate to its coordinates
                    let trans = self.globalToDrawersContainerCoordinates(intersection)!
                    
                    let zoomedAxisX = self.xAxis.firstVisibleScreen - self.xAxis.firstScreen + trans.x
                    let zoomedAxisY = self.yAxis.lastVisibleScreen - self.yAxis.lastScreen + trans.y
                    
                    let xScalar = self.xAxis.innerScalarForScreenLoc(zoomedAxisX)
                    let yScalar = self.yAxis.innerScalarForScreenLoc(zoomedAxisY)
                    
                    let dummyModel = self.chartPointsModels[0]
                    let x = dummyModel.chartPoint.x.copy(xScalar)
                    let y = dummyModel.chartPoint.y.copy(yScalar)
                    let chartPoint = T(x: x, y: y)
                    
                    self.positionUpdateHandler?(chartPoint)
                    
                }
            } else {
                self.currentIntersection = nil
            }
        }
    }

    private func toLine(intersection: CGPoint) -> (p1: CGPoint, p2: CGPoint) {
        return (p1: CGPointMake(intersection.x, 0), p2: CGPointMake(intersection.x, 10000000))
    }
    
    override public func chartDrawersContentViewDrawing(context context: CGContextRef, chart: Chart, view: UIView) {
        
        guard let intersection = currentIntersection else {return}

        CGContextSetStrokeColorWithColor(context, UIColor.blackColor().CGColor)
        CGContextSetLineWidth(context, 2)

        let coords = globalToDrawersContainerCoordinates(intersection)!
        let line = toLine(coords)
        
        CGContextMoveToPoint(context, line.p1.x, line.p1.y)
        CGContextAddLineToPoint(context, line.p2.x, line.p2.y)

        CGContextStrokePath(context)
        
        if let thumbSettings = settings.thumbSettings {
            CGContextSetStrokeColorWithColor(context, UIColor.blackColor().CGColor)
            CGContextStrokeEllipseInRect(context, CGRectMake(coords.x - thumbSettings.thumbSize / 2, coords.y - thumbSettings.thumbSize / 2, thumbSettings.thumbSize, thumbSettings.thumbSize))
        }
    }
    
    public override func handlePanStart(location: CGPoint) {
        guard let localLocation = toLocalCoordinates(location) else {return}
        
        updateChartPointsScreenLocations()
        
        let surroundingRect = localLocation.surroundingRect(30)
        
        if intersect(surroundingRect) || intersectLine(surroundingRect) {
            isTracking = true
        } else {
            currentIntersection = nil
        }
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
        
        currentIntersection = nil
    }
    
    public override func zoom(x: CGFloat, y: CGFloat, centerX: CGFloat, centerY: CGFloat) {
        super.zoom(x, y: y, centerX: centerX, centerY: centerY)
        currentIntersection = nil
        chart?.drawersContentView.setNeedsDisplay()
    }
    
    public override func pan(deltaX: CGFloat, deltaY: CGFloat) {
        super.pan(deltaX, deltaY: deltaY)
        chart?.drawersContentView.setNeedsDisplay()
    }
}