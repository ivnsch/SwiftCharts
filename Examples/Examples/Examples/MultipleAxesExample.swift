//
//  MultipleAxesExample.swift
//  SwiftCharts
//
//  Created by ischuetz on 05/05/15.
//  Copyright (c) 2015 ivanschuetz. All rights reserved.
//

import UIKit

class MultipleAxesExample: UIViewController {

    private var chart: Chart? // arc

    override func viewDidLoad() {
        super.viewDidLoad()

        let labelSettings = ChartLabelSettings(font: ExamplesDefaults.labelFontSmall)

        let bgColors = [UIColor.redColor(), UIColor.blueColor(), UIColor(red: 0, green: 0.7, blue: 0, alpha: 1), UIColor(red: 1, green: 0.5, blue: 0, alpha: 1)]
        
        func createChartPoints0(color: UIColor) -> [ChartPoint] {
            return [
                self.createChartPoint(0, 0, color),
                self.createChartPoint(2, 2, color),
                self.createChartPoint(5, 2, color),
                self.createChartPoint(8, 11, color),
                self.createChartPoint(10, 2, color),
                self.createChartPoint(12, 3, color),
                self.createChartPoint(16, 22, color),
                self.createChartPoint(20, 5, color)
            ]
        }
        
        func createChartPoints1(color: UIColor) -> [ChartPoint] {
            return [
                self.createChartPoint(0, 7, color),
                self.createChartPoint(1, 10, color),
                self.createChartPoint(3, 9, color),
                self.createChartPoint(9, 2, color),
                self.createChartPoint(10, -5, color),
                self.createChartPoint(13, -12, color)
            ]
        }
        
        func createChartPoints2(color: UIColor) -> [ChartPoint] {
            return [
                self.createChartPoint(-200, -10, color),
                self.createChartPoint(-160, -30, color),
                self.createChartPoint(-110, -10, color),
                self.createChartPoint(-40, -80, color),
                self.createChartPoint(-10, -50, color),
                self.createChartPoint(20, 10, color)
            ]
        }
        
        func createChartPoints3(color: UIColor) -> [ChartPoint] {
            return [
                self.createChartPoint(10000, 70, color),
                self.createChartPoint(20000, 100, color),
                self.createChartPoint(30000, 160, color)
            ]
        }
        
        let chartPoints0 = createChartPoints0(bgColors[0])
        let chartPoints1 = createChartPoints1(bgColors[1])
        let chartPoints2 = createChartPoints2(bgColors[2])
        let chartPoints3 = createChartPoints3(bgColors[3])
        
        let xValues0 = chartPoints0.map{$0.x}
        let xValues1 = chartPoints1.map{$0.x}
        let xValues2 = chartPoints2.map{$0.x}
        let xValues3 = chartPoints3.map{$0.x}
        
        let chartFrame = ExamplesDefaults.chartFrame(self.view.bounds)
        let chartBounds = CGRectMake(0, 0, chartFrame.width, chartFrame.height)
        let chartSettings = ExamplesDefaults.chartSettings
        
        
        let top: CGFloat = 80
        let viewFrame = CGRectMake(0, top, self.view.frame.size.width, self.view.frame.size.height - top - 10)
        
        let yValues1 = ChartAxisValuesGenerator.generateYAxisValuesWithChartPoints(chartPoints0, minSegmentCount: 10, maxSegmentCount: 20, multiple: 2, axisValueGenerator: {ChartAxisValueFloat($0, labelSettings: ChartLabelSettings(font: ExamplesDefaults.labelFontSmall, fontColor: bgColors[0]))}, addPaddingSegmentIfEdge: false)
        
        let yValues2 = ChartAxisValuesGenerator.generateYAxisValuesWithChartPoints(chartPoints1, minSegmentCount: 10, maxSegmentCount: 20, multiple: 2, axisValueGenerator: {ChartAxisValueFloat($0, labelSettings: ChartLabelSettings(font: ExamplesDefaults.labelFontSmall, fontColor: bgColors[1]))}, addPaddingSegmentIfEdge: false)
        
        let yValues4 = ChartAxisValuesGenerator.generateYAxisValuesWithChartPoints(chartPoints2, minSegmentCount: 10, maxSegmentCount: 20, multiple: 2, axisValueGenerator: {ChartAxisValueFloat($0, labelSettings: ChartLabelSettings(font: ExamplesDefaults.labelFontSmall, fontColor: bgColors[2]))}, addPaddingSegmentIfEdge: false)
        
        let yValues5 = ChartAxisValuesGenerator.generateYAxisValuesWithChartPoints(chartPoints3, minSegmentCount: 10, maxSegmentCount: 20, multiple: 2, axisValueGenerator: {ChartAxisValueFloat($0, labelSettings: ChartLabelSettings(font: ExamplesDefaults.labelFontSmall, fontColor: bgColors[3]))}, addPaddingSegmentIfEdge: false)
        
        let axisTitleFont = ExamplesDefaults.labelFontSmall
        
        let yLowModels: [ChartAxisModel] = [
            ChartAxisModel(axisValues: yValues2, lineColor: bgColors[1], axisTitleLabels: [ChartAxisLabel(text: "Axis title", settings: ChartLabelSettings(fontColor: bgColors[1], font: axisTitleFont).defaultVertical())]),
            ChartAxisModel(axisValues: yValues1, lineColor: bgColors[0], axisTitleLabels: [ChartAxisLabel(text: "Axis title", settings: ChartLabelSettings(fontColor: bgColors[0], font: axisTitleFont).defaultVertical())])
        ]
        let yHighModels: [ChartAxisModel] = [
            ChartAxisModel(axisValues: yValues4, lineColor: bgColors[2], axisTitleLabels: [ChartAxisLabel(text: "Axis title", settings: ChartLabelSettings(fontColor: bgColors[2], font: axisTitleFont).defaultVertical())]),
            ChartAxisModel(axisValues: yValues5, lineColor: bgColors[3], axisTitleLabels: [ChartAxisLabel(text: "Axis title", settings: ChartLabelSettings(fontColor: bgColors[3], font: axisTitleFont).defaultVertical())])
        ]
        let xLowModels: [ChartAxisModel] = [
            ChartAxisModel(axisValues: xValues0, lineColor: bgColors[0], axisTitleLabels: [ChartAxisLabel(text: "Axis title", settings: ChartLabelSettings(fontColor: bgColors[0], font: axisTitleFont))]),
            ChartAxisModel(axisValues: xValues1, lineColor: bgColors[1], axisTitleLabels: [ChartAxisLabel(text: "Axis title", settings: ChartLabelSettings(fontColor: bgColors[1], font: axisTitleFont))])
        ]
        let xHighModels: [ChartAxisModel] = [
            ChartAxisModel(axisValues: xValues3, lineColor: bgColors[3], axisTitleLabels: [ChartAxisLabel(text: "Axis title", settings: ChartLabelSettings(fontColor: bgColors[3], font: axisTitleFont))]),
            ChartAxisModel(axisValues: xValues2, lineColor: bgColors[2], axisTitleLabels: [ChartAxisLabel(text: "Axis title", settings: ChartLabelSettings(fontColor: bgColors[2], font: axisTitleFont))])
        ]
        
        // calculate coords space in the background to keep UI smooth
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            
            let coordsSpace = ChartCoordsSpace(chartSettings: chartSettings, chartSize: viewFrame.size, yLowModels: yLowModels, yHighModels: yHighModels, xLowModels: xLowModels, xHighModels: xHighModels)
            
            dispatch_async(dispatch_get_main_queue()) {
                
                
                let coordsSpace = ChartCoordsSpace(chartSettings: chartSettings, chartSize: viewFrame.size, yLowModels: yLowModels, yHighModels: yHighModels, xLowModels: xLowModels, xHighModels: xHighModels)
                let chartInnerFrame = coordsSpace.chartInnerFrame
                
                // create axes
                let yLowAxes = coordsSpace.yLowAxes
                let yHighAxes = coordsSpace.yHighAxes
                let xLowAxes = coordsSpace.xLowAxes
                let xHighAxes = coordsSpace.xHighAxes
                
                // create layers with references to axes
                let lineModel0 = ChartLineModel(chartPoints: chartPoints0, lineColor: bgColors[0], animDuration: 1, animDelay: 0)
                let lineModel1 = ChartLineModel(chartPoints: chartPoints1, lineColor: bgColors[1], animDuration: 1, animDelay: 0)
                let lineModel2 = ChartLineModel(chartPoints: chartPoints2, lineColor: bgColors[2], animDuration: 1, animDelay: 0)
                let lineModel3 = ChartLineModel(chartPoints: chartPoints3, lineColor: bgColors[3], animDuration: 1, animDelay: 0)
                
                let chartPointsLineLayer0 = ChartPointsLineLayer<ChartPoint>(xAxis: xLowAxes[0], yAxis: yLowAxes[1], innerFrame: chartInnerFrame, lineModels: [lineModel0])
                let chartPointsLineLayer1 = ChartPointsLineLayer<ChartPoint>(xAxis: xLowAxes[1], yAxis: yLowAxes[0], innerFrame: chartInnerFrame, lineModels: [lineModel1])
                let chartPointsLineLayer3 = ChartPointsLineLayer<ChartPoint>(xAxis: xHighAxes[1], yAxis: yHighAxes[0], innerFrame: chartInnerFrame, lineModels: [lineModel2])
                let chartPointsLineLayer4 = ChartPointsLineLayer<ChartPoint>(xAxis: xHighAxes[0], yAxis: yHighAxes[1], innerFrame: chartInnerFrame, lineModels: [lineModel3])
                
                let lineLayers = [chartPointsLineLayer0, chartPointsLineLayer1, chartPointsLineLayer3, chartPointsLineLayer4]
                
                let layers: [ChartLayer] = [
                    yLowAxes[1], xLowAxes[0], lineLayers[0],
                    yLowAxes[0], xLowAxes[1], lineLayers[1],
                    yHighAxes[0], xHighAxes[1], lineLayers[2],
                    yHighAxes[1], xHighAxes[0], lineLayers[3],
                ]
                
                let chart = Chart(
                    frame: viewFrame,
                    layers: layers
                )
                
                self.view.addSubview(chart.view)
                self.chart = chart
                
            }
        }

    }
    
    private func createChartPoint(x: CGFloat, _ y: CGFloat, _ labelColor: UIColor) -> ChartPoint {
        let labelSettings = ChartLabelSettings(font: ExamplesDefaults.labelFontSmall, fontColor: labelColor)
        return ChartPoint(x: ChartAxisValueFloat(x, labelSettings: labelSettings), y: ChartAxisValueFloat(y, labelSettings: labelSettings))
    }
}
