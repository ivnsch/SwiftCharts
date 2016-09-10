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
    
    public init(thumbSize: CGFloat, thumbCornerRadius: CGFloat = 16, thumbBorderWidth: CGFloat = 4, thumbBorderColor: UIColor = UIColor.black, thumbBGColor: UIColor = UIColor.white, infoViewFont: UIFont, infoViewFontColor: UIColor = UIColor.black, infoViewSize: CGSize, infoViewCornerRadius: CGFloat) {
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

open class ChartPointsLineTrackerLayer<T: ChartPoint>: ChartPointsLayer<T> {
    
    fileprivate let lineColor: UIColor
    fileprivate let animDuration: Float
    fileprivate let animDelay: Float
    
    fileprivate let settings: ChartPointsLineTrackerLayerSettings
    
    fileprivate lazy var currentPositionLineOverlay: UIView = {
        let currentPositionLineOverlay = UIView()
        currentPositionLineOverlay.backgroundColor = UIColor.gray
        currentPositionLineOverlay.alpha = 0
        return currentPositionLineOverlay
    }()

    fileprivate lazy var thumb: UIView = {
        let thumb = UIView()
        thumb.layer.cornerRadius = self.settings.thumbCornerRadius
        thumb.layer.borderWidth = self.settings.thumbBorderWidth
        thumb.layer.backgroundColor = UIColor.clear.cgColor
        thumb.layer.borderColor = self.settings.thumbBorderColor.cgColor
        thumb.alpha = 0
        return thumb
    }()

    fileprivate var currentPositionInfoOverlay: UILabel?
    
    fileprivate var view: TrackerView?
    
    public init(xAxis: ChartAxisLayer, yAxis: ChartAxisLayer, innerFrame: CGRect, chartPoints: [T], lineColor: UIColor, animDuration: Float, animDelay: Float, settings: ChartPointsLineTrackerLayerSettings) {
        self.lineColor = lineColor
        self.animDuration = animDuration
        self.animDelay = animDelay
        self.settings = settings
        super.init(xAxis: xAxis, yAxis: yAxis, innerFrame: innerFrame, chartPoints: chartPoints)
    }

    fileprivate func linesIntersection(line1P1: CGPoint, line1P2: CGPoint, line2P1: CGPoint, line2P2: CGPoint) -> CGPoint? {
        return self.findLineIntersection(p0X: line1P1.x, p0y: line1P1.y, p1x: line1P2.x, p1y: line1P2.y, p2x: line2P1.x, p2y: line2P1.y, p3x: line2P2.x, p3y: line2P2.y)
    }
    
    // src: http://stackoverflow.com/a/14795484/930450 (modified)
    fileprivate func findLineIntersection(p0X: CGFloat , p0y: CGFloat, p1x: CGFloat, p1y: CGFloat, p2x: CGFloat, p2y: CGFloat, p3x: CGFloat, p3y: CGFloat) -> CGPoint? {
        
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
  
    fileprivate func createCurrentPositionInfoOverlay(view: UIView) -> UILabel {
        let currentPosW: CGFloat = self.settings.infoViewSize.width
        let currentPosH: CGFloat = self.settings.infoViewSize.height
        let currentPosX: CGFloat = (view.frame.size.width - currentPosW) / CGFloat(2)
        let currentPosY: CGFloat = 100
        let currentPositionInfoOverlay = UILabel(frame: CGRect(x: currentPosX, y: currentPosY, width: currentPosW, height: currentPosH))
        currentPositionInfoOverlay.textColor = self.settings.infoViewFontColor
        currentPositionInfoOverlay.font = self.settings.infoViewFont
        currentPositionInfoOverlay.layer.cornerRadius = self.settings.infoViewCornerRadius
        currentPositionInfoOverlay.layer.borderWidth = 1
        currentPositionInfoOverlay.textAlignment = NSTextAlignment.center
        currentPositionInfoOverlay.layer.backgroundColor = UIColor.white.cgColor
        currentPositionInfoOverlay.layer.borderColor = UIColor.gray.cgColor
        currentPositionInfoOverlay.alpha = 0
        return currentPositionInfoOverlay
    }
    
    
    fileprivate func currentPositionInfoOverlay(view: UIView) -> UILabel {
        return self.currentPositionInfoOverlay ?? {
            let currentPositionInfoOverlay = self.createCurrentPositionInfoOverlay(view: view)
            self.currentPositionInfoOverlay = currentPositionInfoOverlay
            return currentPositionInfoOverlay
        }()
    }
   
    fileprivate func updateTrackerLineOnValidState(updateFunc: (_ view: UIView) -> ()) {
        if !self.chartPointsModels.isEmpty {
            if let view = self.view {
                updateFunc(view)
            }
        }
    }
    
    fileprivate func updateTrackerLine(touchPoint: CGPoint) {
        
        self.updateTrackerLineOnValidState{(view) in
            
            let touchlineP1 = CGPoint(x: touchPoint.x, y: 0)
            let touchlineP2 = CGPoint(x: touchPoint.x, y: view.frame.size.height)
            
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
                
                UIView.animate(withDuration: 0.3, animations: { () -> Void in
                    self.currentPositionLineOverlay.alpha = 1
                    self.currentPositionInfoOverlay(view: view).alpha = 1
                    self.thumb.alpha = 1
                    }, completion: { (Bool) -> Void in
                })
                
                var w: CGFloat = self.settings.thumbSize
                var h: CGFloat = self.settings.thumbSize
                self.currentPositionLineOverlay.frame = CGRect(x: intersection.x, y: 0, width: 1, height: view.frame.size.height)
                self.thumb.frame = CGRect(x: intersection.x - w/2, y: intersection.y - h/2, width: w, height: h)
                
                // Calculate scalar corresponding to intersection screen location along axis
                func scalar(_ axis: ChartAxisLayer, intersection: CGFloat) -> Double {
                    let s1 = axis.axisValues[0].scalar
                    let sl1 = axis.screenLocForScalar(s1)
                    let s2 = axis.axisValues[1].scalar
                    let sl2 = axis.screenLocForScalar(s2)
                    
                    let factor = (s2 - s1) / Double(sl2 - sl1)
                    let sl = Double(intersection - sl1)
                    return sl * Double(factor) + Double(s1)
                }
                
                if self.chartPointsModels.count > 1 {

                    let xScalar = scalar(self.xAxis, intersection: intersection.x)
                    let yScalar = scalar(self.yAxis, intersection: intersection.y)
                    
                    let dummyModel = self.chartPointsModels[0]
                    let x = dummyModel.chartPoint.x.copy(xScalar)
                    let y = dummyModel.chartPoint.y.copy(yScalar)
                    let chartPoint = T(x: x, y: y)
                    
                    self.currentPositionInfoOverlay(view: view).text = "Pos: \(chartPoint)"
                }
            }
        }
    }
    
    override func display(chart: Chart) {
        let view = TrackerView(frame: chart.bounds, updateFunc: {[weak self] location in
            self?.updateTrackerLine(touchPoint: location)
        })
        view.isUserInteractionEnabled = true
        chart.addSubview(view)
        self.view = view
    }
}

private class TrackerView: UIView {
    
    let updateFunc: ((CGPoint) -> ())?
    
    init(frame: CGRect, updateFunc: @escaping (CGPoint) -> ()) {
        self.updateFunc = updateFunc
        
        super.init(frame: frame)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first!
        let location = touch.location(in: self)
        
        self.updateFunc?(location)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first!
        let location = touch.location(in: self)
        
        self.updateFunc?(location)
    }
}
