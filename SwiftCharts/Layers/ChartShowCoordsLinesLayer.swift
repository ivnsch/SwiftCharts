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

    public init(xAxis: ChartAxisLayer, yAxis: ChartAxisLayer, innerFrame: CGRect, chartPoints: [T]) {
        super.init(xAxis: xAxis, yAxis: yAxis, innerFrame: innerFrame, chartPoints: chartPoints)
    }
    
    public func showChartPointLines(chartPoint: T, chart: Chart) {
       
        if let view = self.view {
            
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
            
            UIView.animateWithDuration(0.2, delay: 0, options: UIViewAnimationOptions.CurveEaseOut, animations: { () -> Void in
                hLine.frame = CGRectMake(self.innerFrame.origin.x, screenLoc.y, screenLoc.x - self.innerFrame.origin.x, 1)
                vLine.frame = CGRectMake(screenLoc.x, screenLoc.y, 1, self.innerFrame.origin.y + self.innerFrame.height - screenLoc.y)
            }, completion: nil)
        }
    }

    
    override func display(chart chart: Chart) {
        let view = UIView(frame: chart.bounds)
        view.userInteractionEnabled = true
        chart.addSubview(view)
        self.view = view
    }
}
