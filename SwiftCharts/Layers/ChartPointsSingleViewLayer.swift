//
//  ChartPointsSingleViewLayer.swift
//  swift_charts
//
//  Created by ischuetz on 19/04/15.
//  Copyright (c) 2015 ivanschuetz. All rights reserved.
//

import UIKit

// Layer that shows only one view at a time
// TODO remember to use "public" everywhere, this is probably necessary for pod
public class ChartPointsSingleViewLayer<T: ChartPoint, U: UIView>: ChartPointsViewsLayer<T, U> {
    
    private var addedViews: [UIView] = []
    
    public init(axisX: ChartAxisLayer, axisY: ChartAxisLayer, innerFrame: CGRect, chartPoints: [T], viewGenerator: ChartPointViewGenerator) {
        super.init(axisX: axisX, axisY: axisY, innerFrame: innerFrame, chartPoints: chartPoints, viewGenerator: viewGenerator)
    }

    override func display(#chart: Chart) {
        // skip adding views - this layer manages its own list
    }
    
    public func showView(#chartPoint: T, chart: Chart) {
        
        for view in self.addedViews {
            view.removeFromSuperview()
        }
        
        let screenLoc = self.chartPointScreenLoc(chartPoint)
        let index = find(self.chartPointsModels.map{$0.chartPoint}, chartPoint)!
        let model: ChartPointLayerModel = ChartPointLayerModel(chartPoint: chartPoint, index: index, screenLoc: screenLoc)
        if let view = self.viewGenerator(chartPointModel: model, layer: self, chart: chart) {
            self.addedViews.append(view)
            chart.addSubview(view)
        }
    }
}
