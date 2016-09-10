//
//  ChartPointsSingleViewLayer.swift
//  swift_charts
//
//  Created by ischuetz on 19/04/15.
//  Copyright (c) 2015 ivanschuetz. All rights reserved.
//

import UIKit

// Layer that shows only one view at a time
open class ChartPointsSingleViewLayer<T: ChartPoint, U: UIView>: ChartPointsViewsLayer<T, U> {
    
    fileprivate var addedViews: [UIView] = []
    
    public init(xAxis: ChartAxisLayer, yAxis: ChartAxisLayer, innerFrame: CGRect, chartPoints: [T], viewGenerator: @escaping ChartPointViewGenerator) {
        super.init(xAxis: xAxis, yAxis: yAxis, innerFrame: innerFrame, chartPoints: chartPoints, viewGenerator: viewGenerator)
    }

    override func display(chart: Chart) {
        // skip adding views - this layer manages its own list
    }
    
    open func showView(chartPoint: T, chart: Chart) {
        
        for view in self.addedViews {
            view.removeFromSuperview()
        }
        
        let screenLoc = self.chartPointScreenLoc(chartPoint)
        let index = self.chartPointsModels.map{$0.chartPoint}.index(of: chartPoint)!
        let model: ChartPointLayerModel = ChartPointLayerModel(chartPoint: chartPoint, index: index, screenLoc: screenLoc)
        if let view = self.viewGenerator(model, self, chart) {
            self.addedViews.append(view)
            chart.addSubview(view)
        }
    }
}
