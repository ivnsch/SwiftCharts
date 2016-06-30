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
    
    public init(xAxis: ChartAxis, yAxis: ChartAxis, innerFrame: CGRect, chartPoints: [T]) {
        super.init(xAxis: xAxis, yAxis: yAxis, innerFrame: innerFrame, chartPoints: chartPoints)
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
                hLine.frame = CGRectMake(self.innerFrame.origin.x, screenLoc.y, screenLoc.x - self.innerFrame.origin.x, 1)
                vLine.frame = CGRectMake(screenLoc.x, screenLoc.y, 1, self.innerFrame.origin.y + self.innerFrame.height - screenLoc.y)
                
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
    
    private func reloadViews() {
        guard let chart = chart, chartPoint = activeChartPoint else {return}

        isTransform = true
        showChartPointLines(chartPoint, chart: chart)
        isTransform = false
    }

    public override func zoom(x: CGFloat, y: CGFloat, centerX: CGFloat, centerY: CGFloat) {
        super.zoom(x, y: y, centerX: centerX, centerY: centerY)
        reloadViews()
    }
    
    public override func pan(deltaX: CGFloat, deltaY: CGFloat) {
        super.pan(deltaX, deltaY: deltaY)
        reloadViews()
    }
}
