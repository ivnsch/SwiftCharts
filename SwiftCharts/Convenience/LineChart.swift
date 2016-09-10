//
//  LineChart.swift
//  Examples
//
//  Created by ischuetz on 19/07/15.
//  Copyright (c) 2015 ivanschuetz. All rights reserved.
//

import UIKit

open class LineChart: Chart {
    
    public typealias ChartLine = (chartPoints: [(Double, Double)], color: UIColor)
    
    // Initializer for single line
    public convenience init(frame: CGRect, chartConfig: ChartConfigXY, xTitle: String, yTitle: String, line: ChartLine) {
        self.init(frame: frame, chartConfig: chartConfig, xTitle: xTitle, yTitle: yTitle, lines: [line])
    }
    
    // Initializer for multiple lines
    public init(frame: CGRect, chartConfig: ChartConfigXY, xTitle: String, yTitle: String, lines: [ChartLine]) {
        
        let xValues = stride(from: chartConfig.xAxisConfig.from, through: chartConfig.xAxisConfig.to, by: chartConfig.xAxisConfig.by).map{ChartAxisValueDouble($0)}
        let yValues = stride(from: chartConfig.yAxisConfig.from, through: chartConfig.yAxisConfig.to, by: chartConfig.yAxisConfig.by).map{ChartAxisValueDouble($0)}
        
        let xModel = ChartAxisModel(axisValues: xValues, axisTitleLabel: ChartAxisLabel(text: xTitle, settings: chartConfig.xAxisLabelSettings))
        let yModel = ChartAxisModel(axisValues: yValues, axisTitleLabel: ChartAxisLabel(text: yTitle, settings: chartConfig.yAxisLabelSettings.defaultVertical()))
        let coordsSpace = ChartCoordsSpaceLeftBottomSingleAxis(chartSettings: chartConfig.chartSettings, chartFrame: frame, xModel: xModel, yModel: yModel)
        let (xAxis, yAxis, innerFrame) = (coordsSpace.xAxis, coordsSpace.yAxis, coordsSpace.chartInnerFrame)
        
        let lineLayers: [ChartLayer] = lines.map {line in
            let chartPoints = line.chartPoints.map {chartPointScalar in
                ChartPoint(x: ChartAxisValueDouble(chartPointScalar.0), y: ChartAxisValueDouble(chartPointScalar.1))
            }
            
            let lineModel = ChartLineModel(chartPoints: chartPoints, lineColor: line.color, animDuration: 0.5, animDelay: 0)
            return ChartPointsLineLayer(xAxis: xAxis, yAxis: yAxis, innerFrame: innerFrame, lineModels: [lineModel])
        }
        
        let guidelinesLayer = GuidelinesDefaultLayerGenerator.generateOpt(xAxis: xAxis, yAxis: yAxis, chartInnerFrame: innerFrame, guidelinesConfig: chartConfig.guidelinesConfig)
        
        let view = ChartBaseView(frame: frame)
        let layers: [ChartLayer] = [xAxis, yAxis] + (guidelinesLayer.map{[$0]} ?? []) + lineLayers
        
        super.init(
            view: view,
            layers: layers
        )
    }
    
    public required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
