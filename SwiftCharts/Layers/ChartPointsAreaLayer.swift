//
//  ChartPointsAreaLayer.swift
//  swiftCharts
//
//  Created by ischuetz on 15/04/15.
//  Copyright (c) 2015 ivanschuetz. All rights reserved.
//

import UIKit

public class ChartPointsAreaLayer<T: ChartPoint>: ChartPointsLayer<T> {
    
    private let areaColor: UIColor
    private let animDuration: Float
    private let animDelay: Float
    private let addContainerPoints: Bool

    private var areaViews: [UIView] = []
    
    public init(xAxis: ChartAxis, yAxis: ChartAxis, innerFrame: CGRect, chartPoints: [T], areaColor: UIColor, animDuration: Float, animDelay: Float, addContainerPoints: Bool) {
        self.areaColor = areaColor
        self.animDuration = animDuration
        self.animDelay = animDelay
        self.addContainerPoints = addContainerPoints
        
        super.init(xAxis: xAxis, yAxis: yAxis, innerFrame: innerFrame, chartPoints: chartPoints)
    }
    
    override func display(chart chart: Chart) {
        var points = self.chartPointScreenLocs
        
        let origin = chart.contentView.frame.origin
        let xLength = chart.contentView.frame.width
        
        let bottomY = origin.y + chart.contentView.frame.height
        
        if self.addContainerPoints {
            points.append(CGPointMake(origin.x + xLength, bottomY))
            points.append(CGPointMake(origin.x, bottomY))
        }
        
        let areaView = ChartAreasView(points: points, frame: chart.bounds, color: areaColor, animDuration: isTransform ? 0 : animDuration, animDelay: isTransform ? 0 : animDelay)
        areaViews.append(areaView)
        chart.addSubview(areaView)
    }
}
