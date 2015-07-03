//
//  MultipleLabelsExample.swift
//  SwiftCharts
//
//  Created by ischuetz on 04/05/15.
//  Copyright (c) 2015 ivanschuetz. All rights reserved.
//

import UIKit

class MultipleLabelsExample: UIViewController {

    private var chart: Chart? // arc

    override func viewDidLoad() {
        super.viewDidLoad()

        let labelSettings = ChartLabelSettings(font: ExamplesDefaults.labelFont)

        let cp1 = ChartPoint(x: MyMultiLabelAxisValue(myVal: 2), y: ChartAxisValueFloat(2))
        let cp2 = ChartPoint(x: MyMultiLabelAxisValue(myVal: 4), y: ChartAxisValueFloat(6))
        let cp3 = ChartPoint(x: MyMultiLabelAxisValue(myVal: 5), y: ChartAxisValueFloat(12))
        let cp4 = ChartPoint(x: MyMultiLabelAxisValue(myVal: 8), y: ChartAxisValueFloat(4))
        
        let chartPoints = [cp1, cp2, cp3, cp4]
        
        let xValues = chartPoints.map{$0.x}
        let yValues = ChartAxisValuesGenerator.generateYAxisValuesWithChartPoints(chartPoints, minSegmentCount: 10, maxSegmentCount: 20, multiple: 2, axisValueGenerator: {ChartAxisValueFloat($0, labelSettings: labelSettings)}, addPaddingSegmentIfEdge: false)
        
        let xModel = ChartAxisModel(axisValues: xValues, axisTitleLabel: ChartAxisLabel(text: "Axis title", settings: labelSettings))
        let yModel = ChartAxisModel(axisValues: yValues, axisTitleLabel: ChartAxisLabel(text: "Axis title", settings: labelSettings.defaultVertical()))
        let chartFrame = ExamplesDefaults.chartFrame(self.view.bounds)
        let chartSettings = ExamplesDefaults.chartSettings
        chartSettings.trailing = 20
        let coordsSpace = ChartCoordsSpaceLeftBottomSingleAxis(chartSettings: chartSettings, chartFrame: chartFrame, xModel: xModel, yModel: yModel)
        let (xAxis, yAxis, innerFrame) = (coordsSpace.xAxis, coordsSpace.yAxis, coordsSpace.chartInnerFrame)
    
        let lineModel = ChartLineModel(chartPoints: chartPoints, lineColor: UIColor.redColor(), lineWidth: 1, animDuration: 1, animDelay: 0)
        let chartPointsLineLayer = ChartPointsLineLayer(xAxis: xAxis, yAxis: yAxis, innerFrame: innerFrame, lineModels: [lineModel])
        
        var settings = ChartGuideLinesDottedLayerSettings(linesColor: UIColor.blackColor(), linesWidth: ExamplesDefaults.guidelinesWidth)
        let guidelinesLayer = ChartGuideLinesDottedLayer(xAxis: xAxis, yAxis: yAxis, innerFrame: innerFrame, settings: settings)
        
        let chart = Chart(
            frame: chartFrame,
            layers: [
                xAxis,
                yAxis,
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
    private let derivedVal: CGFloat
    
    init(myVal: Int) {
        self.myVal = myVal
        self.derivedVal = CGFloat(myVal) / 5.0
        super.init(scalar: CGFloat(myVal))
    }
    
    override var labels:[ChartAxisLabel] {
        return [
            ChartAxisLabel(text: "\(self.myVal)", settings: ChartLabelSettings(font: UIFont.systemFontOfSize(18), fontColor: UIColor.blackColor())),
            ChartAxisLabel(text: "blabla", settings: ChartLabelSettings(font: UIFont.systemFontOfSize(10), fontColor: UIColor.blueColor())),
            ChartAxisLabel(text: "\(self.derivedVal)", settings: ChartLabelSettings(font: UIFont.systemFontOfSize(14), fontColor: UIColor.purpleColor()))
        ]
    }
}

