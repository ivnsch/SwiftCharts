//
//  BarsPlusMinusAndLinesExample.swift
//  SwiftCharts
//
//  Created by ischuetz on 04/05/15.
//  Copyright (c) 2015 ivanschuetz. All rights reserved.
//

import UIKit

class BarsPlusMinusAndLinesExample: UIViewController {

    private var chart: Chart? // arc

    override func viewDidLoad() {
        
        let labelSettings = ChartLabelSettings(font: ExamplesDefaults.labelFont)
        
        let barsData: [(title: String, min: CGFloat, max: CGFloat)] = [
            ("A", -65, 40),
            ("B", -30, 50),
            ("C", -40, 35),
            ("D", -50, 40),
            ("E", -60, 30),
            ("F", -35, 47),
            ("G", -30, 60),
            ("H", -46, 48)
        ]

        let lineData: [(title: String, val: CGFloat)] = [
            ("A", -10),
            ("B", 20),
            ("C", -20),
            ("D", 10),
            ("E", -20),
            ("F", 23),
            ("G", 10),
            ("H", 45)
        ]
        
        let alpha: CGFloat = 0.5
        let posColor = UIColor.greenColor().colorWithAlphaComponent(alpha)
        let negColor = UIColor.redColor().colorWithAlphaComponent(alpha)
        let zero = ChartAxisValueFloat(0)
        let bars: [ChartBarModel] = Array(enumerate(barsData)).flatMap {index, tuple in
            [
                ChartBarModel(constant: ChartAxisValueFloat(CGFloat(index)), axisValue1: zero, axisValue2: ChartAxisValueFloat(tuple.min), bgColor: negColor),
                ChartBarModel(constant: ChartAxisValueFloat(CGFloat(index)), axisValue1: zero, axisValue2: ChartAxisValueFloat(tuple.max), bgColor: posColor)
            ]
        }
        
        let yValues = Array(stride(from: -80, through: 80, by: 20)).map {ChartAxisValueFloat($0, labelSettings: labelSettings)}
        let xValues =
            [ChartAxisValueString(order: -1)] +
            Array(enumerate(barsData)).map {index, tuple in ChartAxisValueString(tuple.0, order: index, labelSettings: labelSettings)} +
            [ChartAxisValueString(order: barsData.count)]

        
        let xModel = ChartAxisModel(axisValues: xValues, axisTitleLabel: ChartAxisLabel(text: "Axis title", settings: labelSettings))
        let yModel = ChartAxisModel(axisValues: yValues, axisTitleLabel: ChartAxisLabel(text: "Axis title", settings: labelSettings.defaultVertical()))
        let chartFrame = ExamplesDefaults.chartFrame(self.view.bounds)
        let coordsSpace = ChartCoordsSpaceLeftBottomSingleAxis(chartSettings: ExamplesDefaults.chartSettings, chartFrame: chartFrame, xModel: xModel, yModel: yModel)
        let (xAxis, yAxis, innerFrame) = (coordsSpace.xAxis, coordsSpace.yAxis, coordsSpace.chartInnerFrame)
        
        let barsLayer = ChartBarsLayer(xAxis: xAxis, yAxis: yAxis, innerFrame: innerFrame, bars: bars, horizontal: false, barWidth: Env.iPad ? 40 : 25, animDuration: 0.5)
        
        // labels layer
        // create chartpoints for the top and bottom of the bars, where we will show the labels
        let labelChartPoints = bars.map {bar in
            ChartPoint(x: bar.constant, y: bar.axisValue2)
        }
        let formatter = NSNumberFormatter()
        formatter.maximumFractionDigits = 2
        let labelsLayer = ChartPointsViewsLayer(xAxis: xAxis, yAxis: yAxis, innerFrame: innerFrame, chartPoints: labelChartPoints, viewGenerator: {(chartPointModel, layer, chart) -> UIView? in
            let label = HandlingLabel()
            let posOffset: CGFloat = 10
            
            let pos = chartPointModel.chartPoint.y.scalar > 0
            
            let yOffset = pos ? -posOffset : posOffset
            label.text = "\(formatter.stringFromNumber(chartPointModel.chartPoint.y.scalar)!)%"
            label.font = ExamplesDefaults.labelFont
            label.sizeToFit()
            label.center = CGPointMake(chartPointModel.screenLoc.x, pos ? innerFrame.origin.y : innerFrame.origin.y + innerFrame.size.height)
            label.alpha = 0

            label.movedToSuperViewHandler = {[weak label] in
                UIView.animateWithDuration(0.3, animations: {
                    label?.alpha = 1
                    label?.center.y = chartPointModel.screenLoc.y + yOffset
                })
            }
            return label
            
        }, displayDelay: 0.5) // show after bars animation
        
        // line layer
        let lineChartPoints = Array(enumerate(lineData)).map {index, tuple in ChartPoint(x: ChartAxisValueFloat(CGFloat(index)), y: ChartAxisValueFloat(tuple.val))}
        let lineModel = ChartLineModel(chartPoints: lineChartPoints, lineColor: UIColor.blackColor(), lineWidth: 2, animDuration: 0.5, animDelay: 1)
        let lineLayer = ChartPointsLineLayer(xAxis: xAxis, yAxis: yAxis, innerFrame: innerFrame, lineModels: [lineModel])
        
        let circleViewGenerator = {(chartPointModel: ChartPointLayerModel, layer: ChartPointsLayer, chart: Chart) -> UIView? in
            let color = UIColor(red: 0.7, green: 0.7, blue: 0.7, alpha: 1)
            let circleView = ChartPointEllipseView(center: chartPointModel.screenLoc, diameter: 6)
            circleView.animDuration = 0.5
            circleView.fillColor = color
            return circleView
        }
        let lineCirclesLayer = ChartPointsViewsLayer(xAxis: xAxis, yAxis: yAxis, innerFrame: innerFrame, chartPoints: lineChartPoints, viewGenerator: circleViewGenerator, displayDelay: 1.5, delayBetweenItems: 0.05)
        
        
        // show a gap between positive and negative bar
        let dummyZeroYChartPoint = ChartPoint(x: ChartAxisValueFloat(0), y: ChartAxisValueFloat(0))
        let yZeroGapLayer = ChartPointsViewsLayer(xAxis: xAxis, yAxis: yAxis, innerFrame: innerFrame, chartPoints: [dummyZeroYChartPoint], viewGenerator: {(chartPointModel, layer, chart) -> UIView? in
            let height: CGFloat = 2
            let v = UIView(frame: CGRectMake(innerFrame.origin.x + 2, chartPointModel.screenLoc.y - height / 2, innerFrame.origin.x + innerFrame.size.height, height))
            v.backgroundColor = UIColor.whiteColor()
            return v
        })
        
        let chart = Chart(
            frame: chartFrame,
            layers: [
                xAxis,
                yAxis,
                barsLayer,
                labelsLayer,
                yZeroGapLayer,
                lineLayer,
                lineCirclesLayer
            ]
        )
        
        self.view.addSubview(chart.view)
        self.chart = chart
    }

}
