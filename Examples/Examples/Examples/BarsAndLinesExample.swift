//
//  BarsAndLinesExample.swift
//  SwiftCharts
//
//  Created by ischuetz on 04/05/15.
//  Copyright (c) 2015 ivanschuetz. All rights reserved.
//

import UIKit

class BarsAndLinesExample: UIViewController {

    private var chart: Chart? // arc

    override func viewDidLoad() {
        
        let labelSettings = ChartLabelSettings(font: ExamplesDefaults.labelFont)
        
        let chartPoints = [(2, 7), (4, 9), (7, 15), (8, 5),(12, 20)].map{ChartPoint(x: ChartAxisValueInt($0.0), y: ChartAxisValueInt($0.1))}
        let chartPoints2 = [(2, 4), (4, 3), (7, 10), (8, 2), (12, 17)].map{ChartPoint(x: ChartAxisValueInt($0.0), y: ChartAxisValueInt($0.1))}
        
        let xValues = ChartAxisValuesGenerator.generateXAxisValuesWithChartPoints(chartPoints, minSegmentCount: 8, maxSegmentCount: 8, multiple: 2, axisValueGenerator: {ChartAxisValueFloat($0)}, addPaddingSegmentIfEdge: true)
        let yValues = ChartAxisValuesGenerator.generateYAxisValuesWithChartPoints(chartPoints + chartPoints2, minSegmentCount: 10, maxSegmentCount: 20, multiple: 2, axisValueGenerator: {ChartAxisValueFloat($0)}, addPaddingSegmentIfEdge: true)
        
        let xModel = ChartAxisModel(axisValues: xValues, axisTitleLabel: ChartAxisLabel(text: "Axis title", settings: labelSettings))
        let yModel = ChartAxisModel(axisValues: yValues, axisTitleLabel: ChartAxisLabel(text: "Axis title", settings: labelSettings))
        let chartFrame = ExamplesDefaults.chartFrame(self.view.bounds)
        let coordsSpace = ChartCoordsSpaceLeftBottomSingleAxis(chartSettings: ExamplesDefaults.chartSettings, chartFrame: chartFrame, xModel: xModel, yModel: yModel)
        let (xAxis, yAxis, innerFrame) = (coordsSpace.xAxis, coordsSpace.yAxis, coordsSpace.chartInnerFrame)
        
        let minBarSpacing: CGFloat = ExamplesDefaults.minBarSpacing

        let barViewGenerator = {(chartPointModel: ChartPointLayerModel, layer: ChartPointsLayer, chart: Chart) -> UIView? in
            let bottomLeft = CGPointMake(layer.innerFrame.origin.x, layer.innerFrame.origin.y + layer.innerFrame.height)
            let barWidth = layer.minXScreenSpace - minBarSpacing
            
            let (p1: CGPoint, p2: CGPoint) = (CGPointMake(chartPointModel.screenLoc.x, bottomLeft.y), CGPointMake(chartPointModel.screenLoc.x, chartPointModel.screenLoc.y))
            return ChartPointViewBarGreyOut(chartPoint: chartPointModel.chartPoint, p1: p1, p2: p2, width: barWidth, color: UIColor.redColor(), greyOut: true)
        }
        
        let chartPointsLayer = ChartPointsViewsLayer(axisX: xAxis, axisY: yAxis, innerFrame: innerFrame, chartPoints: chartPoints, viewGenerator: barViewGenerator)
        
        let lineModel = ChartLineModel(chartPoints: chartPoints2, lineColor: UIColor.blueColor(), lineWidth: 2, animDuration: 1, animDelay: 0)
        let chartPointsLineLayer = ChartPointsLineLayer(axisX: xAxis, axisY: yAxis, innerFrame: innerFrame, lineModels: [lineModel], displayDelay: 1.4)
        
        let circleViewGenerator = {(chartPointModel: ChartPointLayerModel, layer: ChartPointsLayer, chart: Chart) -> UIView? in
            let circleSize: CGFloat = Env.iPad ? 20 : 10
            let settings = ChartPointCircleViewSettings(cornerRadius: Env.iPad ? 11 : 5, borderWidth: Env.iPad ? 3 : 2)
            return ChartPointCircleView(center: chartPointModel.screenLoc, size: CGSizeMake(circleSize, circleSize), settings: settings)
        }
        let chartPointsCircleLayer = ChartPointsViewsLayer(axisX: xAxis, axisY: yAxis, innerFrame: innerFrame, chartPoints: chartPoints2, viewGenerator: circleViewGenerator, displayDelay: 1.4, delayBetweenItems: 0.1)
        
        var settings = ChartGuideLinesDottedLayerSettings(linesColor: UIColor.blackColor(), linesWidth: ExamplesDefaults.guidelinesWidth, axis: .XAndY)
        let guidelinesLayer = ChartGuideLinesDottedLayer(axisX: xAxis, yAxis: yAxis, innerFrame: innerFrame, settings: settings)
        
        
        let chart = Chart(
            frame: chartFrame,
            layers: [
                xAxis,
                yAxis,
                guidelinesLayer,
                chartPointsLayer,
                chartPointsLineLayer,
                chartPointsCircleLayer
            ]
        )
        
        self.view.addSubview(chart.view)
        self.chart = chart
    }

}
