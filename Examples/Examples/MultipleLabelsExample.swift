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

    fileprivate var chart: Chart? // arc

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
        let chartFrame = ExamplesDefaults.chartFrame(view.bounds)
        var chartSettings = ExamplesDefaults.chartSettingsWithPanZoom
        chartSettings.trailing = 20
        let coordsSpace = ChartCoordsSpaceLeftBottomSingleAxis(chartSettings: chartSettings, chartFrame: chartFrame, xModel: xModel, yModel: yModel)
        let (xAxisLayer, yAxisLayer, innerFrame) = (coordsSpace.xAxisLayer, coordsSpace.yAxisLayer, coordsSpace.chartInnerFrame)
    
        let lineModel = ChartLineModel(chartPoints: chartPoints, lineColor: UIColor.red, lineWidth: 1, animDuration: 1, animDelay: 0)
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

private class MyMultiLabelAxisValue: ChartAxisValue {
    
    fileprivate let myVal: Int
    fileprivate let derivedVal: Double
    
    init(myVal: Int) {
        self.myVal = myVal
        self.derivedVal = Double(myVal) / 5.0
        super.init(scalar: Double(myVal))
    }
    
    override var labels:[ChartAxisLabel] {
        return [
            ChartAxisLabel(text: "\(myVal)", settings: ChartLabelSettings(font: UIFont.systemFont(ofSize: 18), fontColor: UIColor.black)),
            ChartAxisLabel(text: "blabla", settings: ChartLabelSettings(font: UIFont.systemFont(ofSize: 10), fontColor: UIColor.blue)),
            ChartAxisLabel(text: "\(derivedVal)", settings: ChartLabelSettings(font: UIFont.systemFont(ofSize: 14), fontColor: UIColor.purple))
        ]
    }
}

