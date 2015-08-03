//
//  ChartPointsSingleViewLayer.swift
//  swift_charts
//
//  Created by ischuetz on 19/04/15.
//  Copyright (c) 2015 ivanschuetz. All rights reserved.
//

import UIKit

// Layer that shows only one view at a time
public class ChartPointsSingleViewLayer<T: ChartPoint, U: UIView>: ChartPointsViewsLayer<T, U> {
    
    private var addedViews: [UIView] = []
    
    public init(xAxis: ChartAxisLayer, yAxis: ChartAxisLayer, innerFrame: CGRect, chartPoints: [T], viewGenerator: ChartPointViewGenerator) {
        super.init(xAxis: xAxis, yAxis: yAxis, innerFrame: innerFrame, chartPoints: chartPoints, viewGenerator: viewGenerator)
    }

    override func display(chart chart: Chart) {
        // skip adding views - this layer manages its own list
    }
    
    public func showView(chartPoint chartPoint: T, chart: Chart) {
        
        for view in self.addedViews {
            view.removeFromSuperview()
        }
        
        let screenLoc = self.chartPointScreenLoc(chartPoint)
        let index = self.chartPointsModels.map{$0.chartPoint}.indexOf(chartPoint)!
        let model: ChartPointLayerModel = ChartPointLayerModel(chartPoint: chartPoint, index: index, screenLoc: screenLoc)
        if let view = self.viewGenerator(chartPointModel: model, layer: self, chart: chart) {
            self.addedViews.append(view)
            chart.addSubview(view)
        }
    }
}
