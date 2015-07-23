//
//  LineChart.swift
//  Examples
//
//  Created by ischuetz on 19/07/15.
//  Copyright (c) 2015 ivanschuetz. All rights reserved.
//

import UIKit

public class LineChart: Chart {
    
    public typealias ChartLine = (chartPoints: [(CGFloat, CGFloat)], color: UIColor)
    
    // Initializer for single line
    public convenience init(frame: CGRect, chartConfig: ChartConfig, xTitle: String, yTitle: String, line: ChartLine) {
        self.init(frame: frame, chartConfig: chartConfig, xTitle: xTitle, yTitle: yTitle, lines: [line])
    }
    
    // Initializer for multiple lines
    public init(frame: CGRect, chartConfig: ChartConfig, xTitle: String, yTitle: String, lines: [ChartLine]) {
        
        let labelSettings = ChartLabelSettings(font: ExamplesDefaults.labelFont)
        
        let xValues = Array(stride(from: chartConfig.xAxisConfig.from, through: chartConfig.xAxisConfig.to, by: chartConfig.xAxisConfig.by)).map{ChartAxisValueFloat($0)}
        let yValues = Array(stride(from: chartConfig.yAxisConfig.from, through: chartConfig.yAxisConfig.to, by: chartConfig.yAxisConfig.by)).map{ChartAxisValueFloat($0)}
        
        let xModel = ChartAxisModel(axisValues: xValues, axisTitleLabel: ChartAxisLabel(text: xTitle, settings: labelSettings))
        let yModel = ChartAxisModel(axisValues: yValues, axisTitleLabel: ChartAxisLabel(text: yTitle, settings: labelSettings.defaultVertical()))
        let coordsSpace = ChartCoordsSpaceLeftBottomSingleAxis(chartSettings: ExamplesDefaults.chartSettings, chartFrame: frame, xModel: xModel, yModel: yModel)
        let (xAxis, yAxis, innerFrame) = (coordsSpace.xAxis, coordsSpace.yAxis, coordsSpace.chartInnerFrame)
        
        let lineLayers: [ChartLayer] = lines.map {line in
            let chartPoints = line.chartPoints.map {chartPointScalar in
                ChartPoint(x: ChartAxisValueFloat(chartPointScalar.0, labelSettings: labelSettings), y: ChartAxisValueFloat(chartPointScalar.1))
            }
            
            let lineModel = ChartLineModel(chartPoints: chartPoints, lineColor: line.color, animDuration: 0.5, animDelay: 0)
            return ChartPointsLineLayer(xAxis: xAxis, yAxis: yAxis, innerFrame: innerFrame, lineModels: [lineModel])
        }
        
        let settings = ChartGuideLinesDottedLayerSettings(linesColor: UIColor.blackColor(), linesWidth: ExamplesDefaults.guidelinesWidth)
        let guidelinesLayer = ChartGuideLinesDottedLayer(xAxis: xAxis, yAxis: yAxis, innerFrame: innerFrame, settings: settings)
        
        let view = ChartBaseView(frame: frame)
        
        super.init(
            view: view,
            layers: [xAxis, yAxis, guidelinesLayer] + lineLayers
        )
    }
    
    public required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
