//
//  ChartShowCoordsLinesLayer.swift
//  swift_charts
//
//  Created by ischuetz on 19/04/15.
//  Copyright (c) 2015 ivanschuetz. All rights reserved.
//

import UIKit

public class ChartShowCoordsLinesLayer<T: ChartPoint>: ChartPointsLayer<T> {
    
    private var view: UIView?

    private var activeChartPoint: T?
    
    public init(xAxis: ChartAxis, yAxis: ChartAxis, chartPoints: [T]) {
        super.init(xAxis: xAxis, yAxis: yAxis, chartPoints: chartPoints)
    }
    
    public func showChartPointLines(chartPoint: T, chart: Chart) {
       
        if let view = self.view {
            
            activeChartPoint = chartPoint
            
            for v in view.subviews {
                v.removeFromSuperview()
            }
            
            let screenLoc = self.chartPointScreenLoc(chartPoint)
            
            let hLine = UIView(frame: CGRectMake(screenLoc.x, screenLoc.y, 0, 1))
            let vLine = UIView(frame: CGRectMake(screenLoc.x, screenLoc.y, 0, 1))
            
            for lineView in [hLine, vLine] {
                lineView.backgroundColor = UIColor.blackColor()
                view.addSubview(lineView)
            }
            
            func finalState() {
                
                let axisOriginX = modelLocToScreenLoc(x: xAxis.first)
                let axisOriginY = modelLocToScreenLoc(y: yAxis.first)
                let axisLengthY = axisOriginY - modelLocToScreenLoc(y: yAxis.last)
                
                hLine.frame = CGRectMake(axisOriginX, screenLoc.y, screenLoc.x - axisOriginX, 1)
                vLine.frame = CGRectMake(screenLoc.x, screenLoc.y, 1, axisLengthY - screenLoc.y)
                
            }
            if isTransform {
                finalState()
            } else {
                UIView.animateWithDuration(0.2, delay: 0, options: .CurveEaseOut, animations: {
                    finalState()
                }, completion: nil)
            }
        }
    }
    
    override func display(chart chart: Chart) {
        let view = UIView(frame: chart.bounds)
        view.userInteractionEnabled = true
        chart.addSubview(view)
        self.view = view
    }
    
    public override func zoom(x: CGFloat, y: CGFloat, centerX: CGFloat, centerY: CGFloat) {
        super.zoom(x, y: y, centerX: centerX, centerY: centerY)
        updateChartPointsScreenLocations()
    }
    
    public override func pan(deltaX: CGFloat, deltaY: CGFloat) {
        super.pan(deltaX, deltaY: deltaY)
        updateChartPointsScreenLocations()
    }
}
