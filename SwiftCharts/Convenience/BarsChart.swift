//
//  BarsChart.swift
//  Examples
//
//  Created by ischuetz on 19/07/15.
//  Copyright (c) 2015 ivanschuetz. All rights reserved.
//

import UIKit

public class BarsChartConfig: ChartConfig {
    public let valsAxisConfig: ChartAxisConfig
    public let xAxisLabelSettings: ChartLabelSettings
    public let yAxisLabelSettings: ChartLabelSettings
    
    public init(chartSettings: ChartSettings = ChartSettings(), valsAxisConfig: ChartAxisConfig, xAxisLabelSettings: ChartLabelSettings = ChartLabelSettings(), yAxisLabelSettings: ChartLabelSettings = ChartLabelSettings(), guidelinesConfig: GuidelinesConfig = GuidelinesConfig()) {
        self.valsAxisConfig = valsAxisConfig
        self.xAxisLabelSettings = xAxisLabelSettings
        self.yAxisLabelSettings = yAxisLabelSettings
        
       super.init(chartSettings: chartSettings, guidelinesConfig: guidelinesConfig)
    }
}

public class BarsChart: Chart {
    
    public init(frame: CGRect, chartConfig: BarsChartConfig, xTitle: String, yTitle: String, bars barModels: [(String, Double)], color: UIColor, barWidth: CGFloat, animDuration: Float = 0.5, horizontal: Bool = false) {
        
        let zero = ChartAxisValueFloat(0)
        let bars: [ChartBarModel] = barModels.enumerate().map {index, barModel in
            return ChartBarModel(constant: ChartAxisValueDouble(index), axisValue1: zero, axisValue2: ChartAxisValueDouble(barModel.1), bgColor: color)
        }
        
        let valAxisValues = chartConfig.valsAxisConfig.from.stride(through: chartConfig.valsAxisConfig.to, by: chartConfig.valsAxisConfig.by).map{ChartAxisValueDouble($0)}
        let labelAxisValues = [ChartAxisValueString(order: -1)] + barModels.enumerate().map{index, tuple in ChartAxisValueString(tuple.0, order: index)} + [ChartAxisValueString(order: barModels.count)]

        let (xValues, yValues): ([ChartAxisValue], [ChartAxisValue]) = horizontal ? (valAxisValues, labelAxisValues) : (labelAxisValues, valAxisValues)
        
        let xModel = ChartAxisModel(axisValues: xValues, axisTitleLabel: ChartAxisLabel(text: xTitle, settings: chartConfig.xAxisLabelSettings))
        let yModel = ChartAxisModel(axisValues: yValues, axisTitleLabel: ChartAxisLabel(text: yTitle, settings: chartConfig.xAxisLabelSettings.defaultVertical()))
        let coordsSpace = ChartCoordsSpaceLeftBottomSingleAxis(chartSettings: chartConfig.chartSettings, chartFrame: frame, xModel: xModel, yModel: yModel)
        let (xAxis, yAxis, innerFrame) = (coordsSpace.xAxis, coordsSpace.yAxis, coordsSpace.chartInnerFrame)
        
        let barsLayer: ChartLayer = ChartBarsLayer(xAxis: xAxis, yAxis: yAxis, innerFrame: innerFrame, bars: bars, horizontal: horizontal, barWidth: barWidth, animDuration: animDuration)
        
        let guidelinesLayer = GuidelinesDefaultLayerGenerator.generateOpt(xAxis: xAxis, yAxis: yAxis, chartInnerFrame: innerFrame, guidelinesConfig: chartConfig.guidelinesConfig)
        
        let view = ChartBaseView(frame: frame)
        let layers: [ChartLayer] = [xAxis, yAxis] + (guidelinesLayer.map{[$0]} ?? []) + [barsLayer]
      
        super.init(
            view: view,
            layers: layers
        )
    }
    
    public required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
