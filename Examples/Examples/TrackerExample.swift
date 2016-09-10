//
//  TrackerExample.swift
//  SwiftCharts
//
//  Created by ischuetz on 04/05/15.
//  Copyright (c) 2015 ivanschuetz. All rights reserved.
//

import UIKit
import SwiftCharts

class TrackerExample: UIViewController {

    fileprivate var chart: Chart? // arc

    override func viewDidLoad() {
        super.viewDidLoad()

        let labelSettings = ChartLabelSettings(font: ExamplesDefaults.labelFont)

        let chartPoints = [(2, 2), (4, 4), (7, 1), (8, 11), (12, 3)].map{ChartPoint(x: ChartAxisValueDouble($0.0, labelSettings: labelSettings), y: ChartAxisValueDouble($0.1))}
        
        let xValues = chartPoints.map{$0.x}
        
        let yValues = ChartAxisValuesGenerator.generateYAxisValuesWithChartPoints(chartPoints, minSegmentCount: 10, maxSegmentCount: 20, multiple: 2, axisValueGenerator: {ChartAxisValueDouble($0, labelSettings: labelSettings)}, addPaddingSegmentIfEdge: false)
        
        let xModel = ChartAxisModel(axisValues: xValues, axisTitleLabel: ChartAxisLabel(text: "Axis title", settings: labelSettings))
        let yModel = ChartAxisModel(axisValues: yValues, axisTitleLabel: ChartAxisLabel(text: "Axis title", settings: labelSettings.defaultVertical()))
        let chartFrame = ExamplesDefaults.chartFrame(self.view.bounds)
        let coordsSpace = ChartCoordsSpaceLeftBottomSingleAxis(chartSettings: ExamplesDefaults.chartSettings, chartFrame: chartFrame, xModel: xModel, yModel: yModel)
        let (xAxis, yAxis, innerFrame) = (coordsSpace.xAxis, coordsSpace.yAxis, coordsSpace.chartInnerFrame)
        
        let lineModel = ChartLineModel(chartPoints: chartPoints, lineColor: UIColor.red, animDuration: 1, animDelay: 0)
        let chartPointsLineLayer = ChartPointsLineLayer(xAxis: xAxis, yAxis: yAxis, innerFrame: innerFrame, lineModels: [lineModel])
        
        
        let trackerLayerSettings = ChartPointsLineTrackerLayerSettings(thumbSize: Env.iPad ? 30 : 20, thumbCornerRadius: Env.iPad ? 16 : 10, thumbBorderWidth: Env.iPad ? 4 : 2, infoViewFont: ExamplesDefaults.fontWithSize(Env.iPad ? 26 : 16), infoViewSize: CGSize(width: Env.iPad ? 400 : 160, height: Env.iPad ? 70 : 40), infoViewCornerRadius: Env.iPad ? 30 : 15)
        let chartPointsTrackerLayer = ChartPointsLineTrackerLayer(xAxis: xAxis, yAxis: yAxis, innerFrame: innerFrame, chartPoints: chartPoints, lineColor: UIColor.black, animDuration: 1, animDelay: 2, settings: trackerLayerSettings)
        
        let settings = ChartGuideLinesDottedLayerSettings(linesColor: UIColor.black, linesWidth: ExamplesDefaults.guidelinesWidth)
        let guidelinesLayer = ChartGuideLinesDottedLayer(xAxis: xAxis, yAxis: yAxis, innerFrame: innerFrame, settings: settings)
        
        let chart = Chart(
            frame: chartFrame,
            layers: [
                xAxis,
                yAxis,
                guidelinesLayer,
                chartPointsLineLayer,
                chartPointsTrackerLayer
            ]
        )
        
        self.view.addSubview(chart.view)
        self.chart = chart
    }

}
