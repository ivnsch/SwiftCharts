//
//  ChartPointsAreaLayer.swift
//  swiftCharts
//
//  Created by ischuetz on 15/04/15.
//  Copyright (c) 2015 ivanschuetz. All rights reserved.
//

import UIKit

open class ChartPointsAreaLayer<T: ChartPoint>: ChartPointsLayer<T> {
    
    fileprivate let areaColor: UIColor
    fileprivate let animDuration: Float
    fileprivate let animDelay: Float
    fileprivate let addContainerPoints: Bool

    fileprivate var areaViews: [UIView] = []
    
    public init(xAxis: ChartAxis, yAxis: ChartAxis, chartPoints: [T], areaColor: UIColor, animDuration: Float, animDelay: Float, addContainerPoints: Bool) {
        self.areaColor = areaColor
        self.animDuration = animDuration
        self.animDelay = animDelay
        self.addContainerPoints = addContainerPoints
        
        super.init(xAxis: xAxis, yAxis: yAxis, chartPoints: chartPoints)
    }
    
    open override func display(chart: Chart) {
        var points = chartPointScreenLocs
        
        let origin = chart.contentView.frame.origin
        let xLength = modelLocToScreenLoc(x: xAxis.last) - modelLocToScreenLoc(x: xAxis.first)

        let bottomY = modelLocToScreenLoc(y: yAxis.first)
        
        if addContainerPoints {
            points.append(CGPoint(x: origin.x + xLength, y: bottomY))
            points.append(CGPoint(x: origin.x, y: bottomY))
        }
        
        let areaView = ChartAreasView(points: points, frame: chart.bounds, color: areaColor, animDuration: animDuration, animDelay: animDelay)
        areaViews.append(areaView)
        chart.addSubview(areaView)
    }
}
