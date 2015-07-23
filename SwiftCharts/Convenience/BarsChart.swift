//
//  BarsChart.swift
//  Examples
//
//  Created by ischuetz on 19/07/15.
//  Copyright (c) 2015 ivanschuetz. All rights reserved.
//

import UIKit

public struct BarsChartConfig {
    public let chartSettings: ChartSettings
    public let valsAxisConfig: ChartAxisConfig
    public let xAxisLabelSettings: ChartLabelSettings
    public let yAxisLabelSettings: ChartLabelSettings
    
    public init(chartSettings: ChartSettings = ChartSettings(), valsAxisConfig: ChartAxisConfig, xAxisLabelSettings: ChartLabelSettings = ChartLabelSettings(), yAxisLabelSettings: ChartLabelSettings = ChartLabelSettings()) {
        self.chartSettings = chartSettings
        self.valsAxisConfig = valsAxisConfig
        self.xAxisLabelSettings = xAxisLabelSettings
        self.yAxisLabelSettings = yAxisLabelSettings
    }
}

public class BarsChart: Chart {
    
    public init(frame: CGRect, chartConfig: BarsChartConfig, xTitle: String, yTitle: String, bars barModels: [(String, CGFloat)], color: UIColor, barWidth: CGFloat, animDuration: Float = 0.5, horizontal: Bool = false) {
        
        let zero = ChartAxisValueFloat(0)
        let bars: [ChartBarModel] = barModels.enumerate().map {index, barModel in
            return ChartBarModel(constant: ChartAxisValueFloat(CGFloat(index)), axisValue1: zero, axisValue2: ChartAxisValueFloat(barModel.1), bgColor: color)
        }
        
        let labelSettings = ChartLabelSettings(font: ExamplesDefaults.labelFont)
        
        let valAxisValues = stride(from: chartConfig.valsAxisConfig.from, through: chartConfig.valsAxisConfig.to, by: chartConfig.valsAxisConfig.by).map{ChartAxisValueFloat($0)}
        let labelAxisValues = [ChartAxisValueString(order: -1)] + barModels.enumerate().map{index, tuple in ChartAxisValueString(tuple.0, order: index)} + [ChartAxisValueString(order: barModels.count)]

        let (xValues, yValues): ([ChartAxisValue], [ChartAxisValue]) = horizontal ? (valAxisValues, labelAxisValues) : (labelAxisValues, valAxisValues)
        
        let xModel = ChartAxisModel(axisValues: xValues, axisTitleLabel: ChartAxisLabel(text: xTitle, settings: labelSettings))
        let yModel = ChartAxisModel(axisValues: yValues, axisTitleLabel: ChartAxisLabel(text: yTitle, settings: labelSettings.defaultVertical()))
        let coordsSpace = ChartCoordsSpaceLeftBottomSingleAxis(chartSettings: ExamplesDefaults.chartSettings, chartFrame: frame, xModel: xModel, yModel: yModel)
        let (xAxis, yAxis, innerFrame) = (coordsSpace.xAxis, coordsSpace.yAxis, coordsSpace.chartInnerFrame)
        
        let barsLayer = ChartBarsLayer(xAxis: xAxis, yAxis: yAxis, innerFrame: innerFrame, bars: bars, horizontal: horizontal, barWidth: barWidth, animDuration: animDuration)
        
        let settings = ChartGuideLinesDottedLayerSettings(linesColor: UIColor.blackColor(), linesWidth: ExamplesDefaults.guidelinesWidth)
        let guidelinesLayer = ChartGuideLinesDottedLayer(xAxis: xAxis, yAxis: yAxis, innerFrame: innerFrame, settings: settings)
        
        let view = ChartBaseView(frame: frame)
        
        super.init(
            view: view,
            layers: [xAxis, yAxis, guidelinesLayer, barsLayer]
        )
    }
    
    public required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
