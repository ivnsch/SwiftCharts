//
//  TrendlineExample.swift
//  Examples
//
//  Created by ischuetz on 03/08/15.
//  Copyright (c) 2015 ivanschuetz. All rights reserved.
//

import UIKit
import SwiftCharts

class TrendlineExample: UIViewController {
    
    fileprivate var chart: Chart? // arc
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let labelSettings = ChartLabelSettings(font: ExamplesDefaults.labelFont)
        
        let chartPoints: [ChartPoint] = [(1, 3), (2, 5), (3, 7.5), (4, 10), (5, 6), (6, 12)].map{ChartPoint(x: ChartAxisValueDouble($0.0, labelSettings: labelSettings), y: ChartAxisValueDouble($0.1))}

        let xValues = chartPoints.map{$0.x}
        let yValues = ChartAxisValuesStaticGenerator.generateYAxisValuesWithChartPoints(chartPoints, minSegmentCount: 10, maxSegmentCount: 20, multiple: 2, axisValueGenerator: {ChartAxisValueDouble($0, labelSettings: labelSettings)}, addPaddingSegmentIfEdge: false)
        
        let lineModel = ChartLineModel(chartPoints: chartPoints, lineColor: UIColor.red, animDuration: 1, animDelay: 0)

        let trendLineModel = ChartLineModel(chartPoints: TrendlineGenerator.trendline(chartPoints), lineColor: UIColor.blue, animDuration: 0.5, animDelay: 1)
        
        let xModel = ChartAxisModel(axisValues: xValues, axisTitleLabel: ChartAxisLabel(text: "Axis title", settings: labelSettings))
        let yModel = ChartAxisModel(axisValues: yValues, axisTitleLabel: ChartAxisLabel(text: "Axis title", settings: labelSettings.defaultVertical()))
        let chartFrame = ExamplesDefaults.chartFrame(view.bounds)
        
        let chartSettings = ExamplesDefaults.chartSettingsWithPanZoom

        let coordsSpace = ChartCoordsSpaceLeftBottomSingleAxis(chartSettings: chartSettings, chartFrame: chartFrame, xModel: xModel, yModel: yModel)
        let (xAxisLayer, yAxisLayer, innerFrame) = (coordsSpace.xAxisLayer, coordsSpace.yAxisLayer, coordsSpace.chartInnerFrame)
        
        let chartPointsLineLayer = ChartPointsLineLayer(xAxis: xAxisLayer.axis, yAxis: yAxisLayer.axis, lineModels: [lineModel])

        let trendLineLayer = ChartPointsLineLayer(xAxis: xAxisLayer.axis, yAxis: yAxisLayer.axis, lineModels: [trendLineModel])

        let settings = ChartGuideLinesDottedLayerSettings(linesColor: UIColor.black, linesWidth: ExamplesDefaults.guidelinesWidth)
        let guidelinesLayer = ChartGuideLinesDottedLayer(xAxisLayer: xAxisLayer, yAxisLayer: yAxisLayer, settings: settings)
        
        let chart = Chart(
            frame: chartFrame,
            innerFrame: innerFrame,
            settings: chartSettings,
            layers: [
                xAxisLayer,
                yAxisLayer,
                guidelinesLayer,
                chartPointsLineLayer,
                trendLineLayer
            ]
        )
        
        view.addSubview(chart.view)
        self.chart = chart
    }
}
