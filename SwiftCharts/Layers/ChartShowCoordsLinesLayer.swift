//
//  ChartShowCoordsLinesLayer.swift
//  swift_charts
//
//  Created by ischuetz on 19/04/15.
//  Copyright (c) 2015 ivanschuetz. All rights reserved.
//

import UIKit

open class ChartShowCoordsLinesLayer<T: ChartPoint>: ChartPointsLayer<T> {
    
    fileprivate var view: UIView?

    public init(xAxis: ChartAxisLayer, yAxis: ChartAxisLayer, innerFrame: CGRect, chartPoints: [T]) {
        super.init(xAxis: xAxis, yAxis: yAxis, innerFrame: innerFrame, chartPoints: chartPoints)
    }
    
    open func showChartPointLines(_ chartPoint: T, chart: Chart) {
       
        if let view = self.view {
            
            for v in view.subviews {
                v.removeFromSuperview()
            }
            
            let screenLoc = self.chartPointScreenLoc(chartPoint)
            
            let hLine = UIView(frame: CGRect(x: screenLoc.x, y: screenLoc.y, width: 0, height: 1))
            let vLine = UIView(frame: CGRect(x: screenLoc.x, y: screenLoc.y, width: 0, height: 1))
            
            for lineView in [hLine, vLine] {
                lineView.backgroundColor = UIColor.black
                view.addSubview(lineView)
            }
            
            UIView.animate(withDuration: 0.2, delay: 0, options: UIViewAnimationOptions.curveEaseOut, animations: { () -> Void in
                hLine.frame = CGRect(x: self.innerFrame.origin.x, y: screenLoc.y, width: screenLoc.x - self.innerFrame.origin.x, height: 1)
                vLine.frame = CGRect(x: screenLoc.x, y: screenLoc.y, width: 1, height: self.innerFrame.origin.y + self.innerFrame.height - screenLoc.y)
            }, completion: nil)
        }
    }

    
    override func display(chart: Chart) {
        let view = UIView(frame: chart.bounds)
        view.isUserInteractionEnabled = true
        chart.addSubview(view)
        self.view = view
    }
}
