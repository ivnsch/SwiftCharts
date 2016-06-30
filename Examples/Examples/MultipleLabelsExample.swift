//
//  MultipleLabelsExample.swift
//  SwiftCharts
//
//  Created by ischuetz on 04/05/15.
//  Copyright (c) 2015 ivanschuetz. All rights reserved.
//

import UIKit
import SwiftCharts

class MultipleLabelsExample: UIViewController {

    private var chart: Chart? // arc

    override func viewDidLoad() {
        super.viewDidLoad()

        let labelSettings = ChartLabelSettings(font: ExamplesDefaults.labelFont)

        let cp1 = ChartPoint(x: MyMultiLabelAxisValue(myVal: 2), y: ChartAxisValueDouble(2))
        let cp2 = ChartPoint(x: MyMultiLabelAxisValue(myVal: 4), y: ChartAxisValueDouble(6))
        let cp3 = ChartPoint(x: MyMultiLabelAxisValue(myVal: 5), y: ChartAxisValueDouble(12))
        let cp4 = ChartPoint(x: MyMultiLabelAxisValue(myVal: 8), y: ChartAxisValueDouble(4))
        
        let chartPoints = [cp1, cp2, cp3, cp4]
        
        let xValues = chartPoints.map{$0.x}
        let yValues = ChartAxisValuesStaticGenerator.generateYAxisValuesWithChartPoints(chartPoints, minSegmentCount: 10, maxSegmentCount: 20, multiple: 2, axisValueGenerator: {ChartAxisValueDouble($0, labelSettings: labelSettings)}, addPaddingSegmentIfEdge: false)
        
        let xModel = ChartAxisModel(axisValues: xValues, axisTitleLabel: ChartAxisLabel(text: "Axis title", settings: labelSettings))
        let yModel = ChartAxisModel(axisValues: yValues, axisTitleLabel: ChartAxisLabel(text: "Axis title", settings: labelSettings.defaultVertical()))
        let chartFrame = ExamplesDefaults.chartFrame(self.view.bounds)
        let chartSettings = ExamplesDefaults.chartSettingsWithPanZoom
        chartSettings.trailing = 20
        let coordsSpace = ChartCoordsSpaceLeftBottomSingleAxis(chartSettings: chartSettings, chartFrame: chartFrame, xModel: xModel, yModel: yModel)
        let (xAxisLayer, yAxisLayer, innerFrame) = (coordsSpace.xAxisLayer, coordsSpace.yAxisLayer, coordsSpace.chartInnerFrame)
    
        let lineModel = ChartLineModel(chartPoints: chartPoints, lineColor: UIColor.redColor(), lineWidth: 1, animDuration: 1, animDelay: 0)
        let chartPointsLineLayer = ChartPointsLineLayer(xAxis: xAxisLayer.axis, yAxis: yAxisLayer.axis, innerFrame: innerFrame, lineModels: [lineModel])
        
        let settings = ChartGuideLinesDottedLayerSettings(linesColor: UIColor.blackColor(), linesWidth: ExamplesDefaults.guidelinesWidth)
        let guidelinesLayer = ChartGuideLinesDottedLayer(xAxisLayer: xAxisLayer, yAxisLayer: yAxisLayer, innerFrame: innerFrame, settings: settings)
        
        let chart = Chart(
            frame: chartFrame,
            settings: chartSettings,
            layers: [
                xAxisLayer,
                yAxisLayer,
                guidelinesLayer,
                chartPointsLineLayer
            ]
        )
        
        self.view.addSubview(chart.view)
        self.chart = chart
    }
}

private class MyMultiLabelAxisValue: ChartAxisValue {
    
    private let myVal: Int
    private let derivedVal: Double
    
    init(myVal: Int) {
        self.myVal = myVal
        self.derivedVal = Double(myVal) / 5.0
        super.init(scalar: Double(myVal))
    }
    
    override var labels:[ChartAxisLabel] {
        return [
            ChartAxisLabel(text: "\(self.myVal)", settings: ChartLabelSettings(font: UIFont.systemFontOfSize(18), fontColor: UIColor.blackColor())),
            ChartAxisLabel(text: "blabla", settings: ChartLabelSettings(font: UIFont.systemFontOfSize(10), fontColor: UIColor.blueColor())),
            ChartAxisLabel(text: "\(self.derivedVal)", settings: ChartLabelSettings(font: UIFont.systemFontOfSize(14), fontColor: UIColor.purpleColor()))
        ]
    }
}

