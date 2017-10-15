//
//  ChartPointsAreaLayer.swift
//  swiftCharts
//
//  Created by ischuetz on 15/04/15.
//  Copyright (c) 2015 ivanschuetz. All rights reserved.
//

import UIKit

open class ChartPointsAreaLayer<T: ChartPoint>: ChartPointsLayer<T> {
    
    fileprivate let areaColors: [UIColor]
    fileprivate let animDuration: Float
    fileprivate let animDelay: Float
    fileprivate let pathGenerator: ChartLinesViewPathGenerator
    fileprivate let addContainerPoints: Bool
    fileprivate var areaViews: [UIView] = []
    
    public init(xAxis: ChartAxis, yAxis: ChartAxis, chartPoints: [T], areaColors: [UIColor], animDuration: Float, animDelay: Float, addContainerPoints: Bool,  pathGenerator: ChartLinesViewPathGenerator) {
        self.areaColors = areaColors
        self.animDuration = animDuration
        self.animDelay = animDelay
        self.pathGenerator = pathGenerator
        self.addContainerPoints = addContainerPoints
        super.init(xAxis: xAxis, yAxis: yAxis, chartPoints: chartPoints)
    }
    
    public convenience init(xAxis: ChartAxis, yAxis: ChartAxis, chartPoints: [T], areaColor: UIColor, animDuration: Float, animDelay: Float, addContainerPoints: Bool, pathGenerator: ChartLinesViewPathGenerator) {
        self.init(xAxis: xAxis, yAxis: yAxis, chartPoints: chartPoints, areaColors: [areaColor], animDuration: animDuration, animDelay: animDelay, addContainerPoints: addContainerPoints, pathGenerator: pathGenerator)
    }
    
    open override func display(chart: Chart) {        
        let areaView = ChartAreasView(points: chartPointScreenLocs, frame: chart.bounds, colors: areaColors, animDuration: animDuration, animDelay: animDelay, addContainerPoints: addContainerPoints, pathGenerator: pathGenerator)
        areaViews.append(areaView)
        chart.addSubview(areaView)
    }
}

