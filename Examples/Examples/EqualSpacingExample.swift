//
//  EqualSpacingExample.swift
//  SwiftCharts
//
//  Created by ischuetz on 04/05/15.
//  Copyright (c) 2015 ivanschuetz. All rights reserved.
//

import UIKit
import SwiftCharts

class EqualSpacingExample: UIViewController {

    fileprivate var chart: Chart? // arc

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let labelSettings = ChartLabelSettings(font: ExamplesDefaults.labelFont)

        let chartPoints = [
            ChartPoint(x: ChartAxisValueDoubleScreenLoc(screenLocDouble: 1, actualDouble: 2, labelSettings: labelSettings), y: ChartAxisValueDouble(2)),
            ChartPoint(x: ChartAxisValueDoubleScreenLoc(screenLocDouble: 2, actualDouble: 100, labelSettings: labelSettings), y: ChartAxisValueDouble(5)),
            ChartPoint(x: ChartAxisValueDoubleScreenLoc(screenLocDouble: 3, actualDouble: 100.1, labelSettings: labelSettings), y: ChartAxisValueDouble(1)),
            ChartPoint(x: ChartAxisValueDoubleScreenLoc(screenLocDouble: 4, actualDouble: 900000, labelSettings: labelSettings), y: ChartAxisValueDouble(10))
        ]
        
        let xValues = chartPoints.map{$0.x}
        let yValues = ChartAxisValuesStaticGenerator.generateYAxisValuesWithChartPoints(chartPoints, minSegmentCount: 10, maxSegmentCount: 20, multiple: 2, axisValueGenerator: {ChartAxisValueDouble($0, labelSettings: labelSettings)}, addPaddingSegmentIfEdge: false)
        
        let xModel = ChartAxisModel(axisValues: xValues, axisTitleLabel: ChartAxisLabel(text: "Axis title", settings: labelSettings))
        let yModel = ChartAxisModel(axisValues: yValues, axisTitleLabel: ChartAxisLabel(text: "Axis title", settings: labelSettings.defaultVertical()))
        let chartFrame = ExamplesDefaults.chartFrame(view.bounds)
        var chartSettings = ExamplesDefaults.chartSettingsWithPanZoom
        chartSettings.trailing = 40
        let coordsSpace = ChartCoordsSpaceLeftBottomSingleAxis(chartSettings: chartSettings, chartFrame: chartFrame, xModel: xModel, yModel: yModel)
        let (xAxisLayer, yAxisLayer, innerFrame) = (coordsSpace.xAxisLayer, coordsSpace.yAxisLayer, coordsSpace.chartInnerFrame)
    
        let lineModel = ChartLineModel(chartPoints: chartPoints, lineColor: UIColor.red, animDuration: 1, animDelay: 0)
        let chartPointsLineLayer = ChartPointsLineLayer(xAxis: xAxisLayer.axis, yAxis: yAxisLayer.axis, lineModels: [lineModel])
        
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
                chartPointsLineLayer
            ]
        )
        
        view.addSubview(chart.view)
        self.chart = chart
    }
}
