//
//  ChartPointsCandleStickViewsLayer.swift
//  SwiftCharts
//
//  Created by ischuetz on 29/04/15.
//  Copyright (c) 2015 ivanschuetz. All rights reserved.
//

import UIKit

public class ChartPointsCandleStickViewsLayer<T: ChartPointCandleStick, U: ChartCandleStickView>: ChartPointsViewsLayer<ChartPointCandleStick, ChartCandleStickView> {

    public init(axisX: ChartAxisLayer, axisY: ChartAxisLayer, innerFrame: CGRect, chartPoints: [T], viewGenerator: ChartPointViewGenerator) {
        super.init(axisX: axisX, axisY: axisY, innerFrame: innerFrame, chartPoints: chartPoints, viewGenerator: viewGenerator)
    }
    
    public func highlightChartpointView(#screenLoc: CGPoint) {
        let  x = screenLoc.x
        for viewWithChartPoint in self.viewsWithChartPoints {
            let view = viewWithChartPoint.view
            let originX = view.frame.origin.x
            view.highlighted = x > originX && x < originX + view.frame.width
        }
    }
}
