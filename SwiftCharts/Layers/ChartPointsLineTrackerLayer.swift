//
//  ChartPointsTrackerLayer.swift
//  swift_charts
//
//  Created by ischuetz on 16/04/15.
//  Copyright (c) 2015 ivanschuetz. All rights reserved.
//

import UIKit

public struct ChartPointsLineTrackerLayerSettings {
    let thumbSize: CGFloat
    let thumbCornerRadius: CGFloat
    let thumbBorderWidth: CGFloat
    let thumbBGColor: UIColor
    let thumbBorderColor: UIColor
    let infoViewFont: UIFont
    let infoViewFontColor: UIColor
    let infoViewSize: CGSize
    let infoViewCornerRadius: CGFloat
    
    public init(thumbSize: CGFloat, thumbCornerRadius: CGFloat = 16, thumbBorderWidth: CGFloat = 4, thumbBorderColor: UIColor = UIColor.blackColor(), thumbBGColor: UIColor = UIColor.whiteColor(), infoViewFont: UIFont, infoViewFontColor: UIColor = UIColor.blackColor(), infoViewSize: CGSize, infoViewCornerRadius: CGFloat) {
        self.thumbSize = thumbSize
        self.thumbCornerRadius = thumbCornerRadius
        self.thumbBorderWidth = thumbBorderWidth
        self.thumbBGColor = thumbBGColor
        self.thumbBorderColor = thumbBorderColor
        self.infoViewFont = infoViewFont
        self.infoViewFontColor = infoViewFontColor
        self.infoViewSize = infoViewSize
        self.infoViewCornerRadius = infoViewCornerRadius
    }
}

public class ChartPointsLineTrackerLayer<T: ChartPoint>: ChartPointsLayer<T> {
    
    private let lineColor: UIColor
    private let animDuration: Float
    private let animDelay: Float
    
    private let settings: ChartPointsLineTrackerLayerSettings
    
    private lazy var currentPositionLineOverlay: UIView = {
        let currentPositionLineOverlay = UIView()
        currentPositionLineOverlay.backgroundColor = UIColor.grayColor()
        currentPositionLineOverlay.alpha = 0
        return currentPositionLineOverlay
    }()

    private lazy var thumb: UIView = {
        let thumb = UIView()
        thumb.layer.cornerRadius = self.settings.thumbCornerRadius
        thumb.layer.borderWidth = self.settings.thumbBorderWidth
        thumb.layer.backgroundColor = UIColor.clearColor().CGColor
        thumb.layer.borderColor = self.settings.thumbBorderColor.CGColor
        thumb.alpha = 0
        return thumb
    }()

    private var currentPositionInfoOverlay: UILabel?
    
    private var view: TrackerView?
    
    public init(xAxis: ChartAxisLayer, yAxis: ChartAxisLayer, innerFrame: CGRect, chartPoints: [T], lineColor: UIColor, animDuration: Float, animDelay: Float, settings: ChartPointsLineTrackerLayerSettings) {
        self.lineColor = lineColor
        self.animDuration = animDuration
        self.animDelay = animDelay
        self.settings = settings
        super.init(xAxis: xAxis, yAxis: yAxis, innerFrame: innerFrame, chartPoints: chartPoints)
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
        if denom == 0 {
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
  
    private func createCurrentPositionInfoOverlay(view view: UIView) -> UILabel {
        let currentPosW: CGFloat = self.settings.infoViewSize.width
        let currentPosH: CGFloat = self.settings.infoViewSize.height
        let currentPosX: CGFloat = (view.frame.size.width - currentPosW) / CGFloat(2)
        let currentPosY: CGFloat = 100
        let currentPositionInfoOverlay = UILabel(frame: CGRectMake(currentPosX, currentPosY, currentPosW, currentPosH))
        currentPositionInfoOverlay.textColor = self.settings.infoViewFontColor
        currentPositionInfoOverlay.font = self.settings.infoViewFont
        currentPositionInfoOverlay.layer.cornerRadius = self.settings.infoViewCornerRadius
        currentPositionInfoOverlay.layer.borderWidth = 1
        currentPositionInfoOverlay.textAlignment = NSTextAlignment.Center
        currentPositionInfoOverlay.layer.backgroundColor = UIColor.whiteColor().CGColor
        currentPositionInfoOverlay.layer.borderColor = UIColor.grayColor().CGColor
        currentPositionInfoOverlay.alpha = 0
        return currentPositionInfoOverlay
    }
    
    
    private func currentPositionInfoOverlay(view view: UIView) -> UILabel {
        return self.currentPositionInfoOverlay ?? {
            let currentPositionInfoOverlay = self.createCurrentPositionInfoOverlay(view: view)
            self.currentPositionInfoOverlay = currentPositionInfoOverlay
            return currentPositionInfoOverlay
        }()
    }
   
    private func updateTrackerLineOnValidState(updateFunc updateFunc: (view: UIView) -> ()) {
        if !self.chartPointsModels.isEmpty {
            if let view = self.view {
                updateFunc(view: view)
            }
        }
    }
    
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
            var intersectionMaybe: CGPoint? = {
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
                
                if self.currentPositionInfoOverlay?.superview == nil {
                    view.addSubview(self.currentPositionLineOverlay)
                    view.addSubview(self.currentPositionInfoOverlay(view: view))
                    view.addSubview(self.thumb)
                }
                
                UIView.animateWithDuration(0.3, animations: { () -> Void in
                    self.currentPositionLineOverlay.alpha = 1
                    self.currentPositionInfoOverlay(view: view).alpha = 1
                    self.thumb.alpha = 1
                    }, completion: { (Bool) -> Void in
                })
                
                var w: CGFloat = self.settings.thumbSize
                var h: CGFloat = self.settings.thumbSize
                self.currentPositionLineOverlay.frame = CGRectMake(intersection.x, 0, 1, view.frame.size.height)
                self.thumb.frame = CGRectMake(intersection.x - w/2, intersection.y - h/2, w, h)
                
                func createTmpChartPoint(firstModel: ChartPointLayerModel<T>, secondModel: ChartPointLayerModel<T>) -> ChartPoint {
                    let p1 = firstModel.chartPoint
                    let p2 = secondModel.chartPoint
                    
                    // calculate x scalar
                    let pxXDiff = secondModel.screenLoc.x - firstModel.screenLoc.x
                    let scalarXDiff = p2.x.scalar - p1.x.scalar
                    let factorX = CGFloat(scalarXDiff) / pxXDiff
                    let currentXPx = intersection.x - firstModel.screenLoc.x
                    let currentXScalar = Double(currentXPx * factorX) + p1.x.scalar

                    // calculate y scalar
                    let pxYDiff = fabs(secondModel.screenLoc.y - firstModel.screenLoc.y);
                    let scalarYDiff = p2.y.scalar - p1.y.scalar;
                    let factorY = CGFloat(scalarYDiff) / pxYDiff
                    let currentYPx = fabs(intersection.y - firstModel.screenLoc.y)
                    let currentYScalar = Double(currentYPx * factorY) + p1.y.scalar
                    
                    let x = firstModel.chartPoint.x.copy(currentXScalar)
                    let y = secondModel.chartPoint.y.copy(currentYScalar)
                    let chartPoint = T(x: x, y: y)
                    return chartPoint
                }
                
                if self.chartPointsModels.count > 1 {
                    let first = self.chartPointsModels[0]
                    let second = self.chartPointsModels[1]
                    self.currentPositionInfoOverlay(view: view).text = "Pos: \(createTmpChartPoint(first, secondModel: second).text)"
                }
            }
        }
    }
    
    override func display(chart chart: Chart) {
        let view = TrackerView(frame: chart.bounds, updateFunc: {[weak self] location in
            self?.updateTrackerLine(touchPoint: location)
        })
        view.userInteractionEnabled = true
        chart.addSubview(view)
        self.view = view
    }
}

private class TrackerView: UIView {
    
    let updateFunc: ((CGPoint) -> ())?
    
    init(frame: CGRect, updateFunc: (CGPoint) -> ()) {
        self.updateFunc = updateFunc
        
        super.init(frame: frame)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let touch = touches.first!
        let location = touch.locationInView(self)
        
        self.updateFunc?(location)
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let touch = touches.first!
        let location = touch.locationInView(self)
        
        self.updateFunc?(location)
    }
}
