//
//  ScrollExample.swift
//  SwiftCharts
//
//  Created by ischuetz on 04/05/15.
//  Copyright (c) 2015 ivanschuetz. All rights reserved.
//

import UIKit

class ScrollExample: UIViewController {

    private var chart: Chart? // arc

    override func viewDidLoad() {
        super.viewDidLoad()

        let labelSettings = ChartLabelSettings(font: ExamplesDefaults.labelFont)

        let chartPoints0 = [
            self.createChartPoint(2, 2, labelSettings),
            self.createChartPoint(4, -4, labelSettings),
            self.createChartPoint(7, 1, labelSettings),
            self.createChartPoint(8.3, 11.5, labelSettings),
            self.createChartPoint(9, 15.9, labelSettings),
            self.createChartPoint(10.8, 3, labelSettings),
            self.createChartPoint(13, 24, labelSettings),
            self.createChartPoint(15, 0, labelSettings),
            self.createChartPoint(17.2, 29, labelSettings),
            self.createChartPoint(20, 10, labelSettings),
            self.createChartPoint(22.3, 10, labelSettings),
            self.createChartPoint(27, 15, labelSettings),
            self.createChartPoint(30, 6, labelSettings),
            self.createChartPoint(40, 10, labelSettings),
            self.createChartPoint(50, 2, labelSettings),
        ]
        
        let chartPoints1 = [
            self.createChartPoint(2, 5, labelSettings),
            self.createChartPoint(3, 7, labelSettings),
            self.createChartPoint(5, 9, labelSettings),
            self.createChartPoint(8, 6, labelSettings),
            self.createChartPoint(9, 10, labelSettings),
            self.createChartPoint(10, 20, labelSettings),
            self.createChartPoint(12, 19, labelSettings),
            self.createChartPoint(13, 20, labelSettings),
            self.createChartPoint(14, 25, labelSettings),
            self.createChartPoint(16, 28, labelSettings),
            self.createChartPoint(17, 15, labelSettings),
            self.createChartPoint(19, 6, labelSettings),
            self.createChartPoint(25, 3, labelSettings),
            self.createChartPoint(30, 10, labelSettings),
            self.createChartPoint(45, 15, labelSettings),
            self.createChartPoint(50, 20, labelSettings),
        ]
        
        let xValues = Array(stride(from: 2, through: 50, by: 1)).map {ChartAxisValueFloat($0, labelSettings: labelSettings)}
        let yValues = ChartAxisValuesGenerator.generateYAxisValuesWithChartPoints(chartPoints0, minSegmentCount: 10, maxSegmentCount: 20, multiple: 2, axisValueGenerator: {ChartAxisValueFloat($0, labelSettings: labelSettings)}, addPaddingSegmentIfEdge: false)
        
        let xModel = ChartAxisModel(axisValues: xValues, axisTitleLabel: ChartAxisLabel(text: "Axis title", settings: labelSettings))
        let yModel = ChartAxisModel(axisValues: yValues, axisTitleLabel: ChartAxisLabel(text: "Axis title", settings: labelSettings.defaultVertical()))
        let scrollViewFrame = ExamplesDefaults.chartFrame(self.view.bounds)
        let chartFrame = CGRectMake(0, 0, 1400, scrollViewFrame.size.height)
        
        // calculate coords space in the background to keep UI smooth
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            let coordsSpace = ChartCoordsSpaceLeftBottomSingleAxis(chartSettings: ExamplesDefaults.chartSettings, chartFrame: chartFrame, xModel: xModel, yModel: yModel)
            
            dispatch_async(dispatch_get_main_queue()) {
                let (xAxis, yAxis, innerFrame) = (coordsSpace.xAxis, coordsSpace.yAxis, coordsSpace.chartInnerFrame)

                let lineModel0 = ChartLineModel(chartPoints: chartPoints0, lineColor: UIColor.redColor(), animDuration: 1, animDelay: 0)
                let lineModel1 = ChartLineModel(chartPoints: chartPoints1, lineColor: UIColor.blueColor(), animDuration: 1, animDelay: 0)
                let chartPointsLineLayer = ChartPointsLineLayer(xAxis: xAxis, yAxis: yAxis, innerFrame: innerFrame, lineModels: [lineModel0, lineModel1])
                
                var settings = ChartGuideLinesDottedLayerSettings(linesColor: UIColor.blackColor(), linesWidth: ExamplesDefaults.guidelinesWidth)
                let guidelinesLayer = ChartGuideLinesDottedLayer(xAxis: xAxis, yAxis: yAxis, innerFrame: innerFrame, settings: settings)
                
                let scrollView = UIScrollView(frame: scrollViewFrame)
                scrollView.contentSize = CGSizeMake(chartFrame.size.width, scrollViewFrame.size.height)
                //        self.automaticallyAdjustsScrollViewInsets = false // nested view controller - this is in parent
                
                let chart = Chart(
                    frame: chartFrame,
                    layers: [
                        xAxis,
                        yAxis,
                        guidelinesLayer,
                        chartPointsLineLayer
                    ]
                )
                
                scrollView.addSubview(chart.view)
                self.view.addSubview(scrollView)
                self.chart = chart
                
            }
        }
    }
    
    private func createChartPoint(x: CGFloat, _ y: CGFloat, _ labelSettings: ChartLabelSettings) -> ChartPoint {
        return ChartPoint(x: ChartAxisValueFloat(x, labelSettings: labelSettings), y: ChartAxisValueFloat(y))
    }
}
