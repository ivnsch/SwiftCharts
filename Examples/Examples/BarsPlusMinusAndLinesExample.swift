//
//  BarsPlusMinusAndLinesExample.swift
//  SwiftCharts
//
//  Created by ischuetz on 04/05/15.
//  Copyright (c) 2015 ivanschuetz. All rights reserved.
//

import UIKit
import SwiftCharts

class BarsPlusMinusAndLinesExample: UIViewController {

    fileprivate var chart: Chart? // arc

    override func viewDidLoad() {
        
        let labelSettings = ChartLabelSettings(font: ExamplesDefaults.labelFont)
        
        let barsData: [(title: String, min: Double, max: Double)] = [
            ("A", -65, 40),
            ("B", -30, 50),
            ("C", -40, 35),
            ("D", -50, 40),
            ("E", -60, 30),
            ("F", -35, 47),
            ("G", -30, 60),
            ("H", -46, 48)
        ]

        let lineData: [(title: String, val: Double)] = [
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
        let posColor = UIColor.green.withAlphaComponent(alpha)
        let negColor = UIColor.red.withAlphaComponent(alpha)
        let zero = ChartAxisValueDouble(0)
        let bars: [ChartBarModel] = barsData.enumerated().flatMap {index, tuple in
            [
                ChartBarModel(constant: ChartAxisValueDouble(index), axisValue1: zero, axisValue2: ChartAxisValueDouble(tuple.min), bgColor: negColor),
                ChartBarModel(constant: ChartAxisValueDouble(index), axisValue1: zero, axisValue2: ChartAxisValueDouble(tuple.max), bgColor: posColor)
            ]
        }
        
        let xGenerator = ChartAxisGeneratorMultiplier(1)
        let yGenerator = ChartAxisGeneratorMultiplier(20)
        let labelsGenerator = ChartAxisLabelsGeneratorFunc {scalar in
            return ChartAxisLabel(text: "\(scalar)", settings: labelSettings)
        }
        
        let xModel = ChartAxisModel(firstModelValue: -1, lastModelValue: Double(barsData.count), axisTitleLabels: [ChartAxisLabel(text: "Axis title", settings: labelSettings)], axisValuesGenerator: xGenerator, labelsGenerator: labelsGenerator)
        let yModel = ChartAxisModel(firstModelValue: -80, lastModelValue: 80, axisTitleLabels: [ChartAxisLabel(text: "Axis title", settings: labelSettings.defaultVertical())], axisValuesGenerator: yGenerator, labelsGenerator: labelsGenerator)
        
        let chartFrame = ExamplesDefaults.chartFrame(view.bounds)
        
        let chartSettings = ExamplesDefaults.chartSettingsWithPanZoom

        let coordsSpace = ChartCoordsSpaceLeftBottomSingleAxis(chartSettings: chartSettings, chartFrame: chartFrame, xModel: xModel, yModel: yModel)
        let (xAxisLayer, yAxisLayer, innerFrame) = (coordsSpace.xAxisLayer, coordsSpace.yAxisLayer, coordsSpace.chartInnerFrame)
        
        let barViewSettings = ChartBarViewSettings(animDuration: 0.5)
        let barsLayer = ChartBarsLayer(xAxis: xAxisLayer.axis, yAxis: yAxisLayer.axis, bars: bars, horizontal: false, barWidth: Env.iPad ? 40 : 25, settings: barViewSettings)
        
        /*
        Labels layer.
        Create chartpoints for the top and bottom of the bars, where we will show the labels.
        There are multiple ways to do this. Here we represent the labels with chartpoints at the top/bottom of the bars. We set some space using domain coordinates, in order for this to be updated properly during zoom / pan. Note that with this the spacing is also zoomed, meaning the labels will move away from the edges of the bars when we scale up, which maybe it's not wanted. More elaborate approaches involve passing a custom transform closure to the layer, or using GroupedBarsCompanionsLayer (currently only for stacked/grouped bars, though any bar chart can be represented with this).
         */
        let labelToBarSpace: Double = 3 // domain units
        let labelChartPoints = bars.map {bar in
            ChartPoint(x: bar.constant, y: bar.axisValue2.copy(bar.axisValue2.scalar + (bar.axisValue2.scalar > 0 ? labelToBarSpace : -labelToBarSpace)))
        }
        let formatter = NumberFormatter()
        formatter.maximumFractionDigits = 2
        let labelsLayer = ChartPointsViewsLayer(xAxis: xAxisLayer.axis, yAxis: yAxisLayer.axis, chartPoints: labelChartPoints, viewGenerator: {(chartPointModel, layer, chart) -> UIView? in
            let label = HandlingLabel()
            
            let pos = chartPointModel.chartPoint.y.scalar > 0
            
            label.text = "\(formatter.string(from: NSNumber(value: chartPointModel.chartPoint.y.scalar - labelToBarSpace))!)%"
            label.font = ExamplesDefaults.labelFont
            label.sizeToFit()
            label.center = CGPoint(x: chartPointModel.screenLoc.x, y: pos ? innerFrame.origin.y : innerFrame.origin.y + innerFrame.size.height)
            label.alpha = 0
            
            label.movedToSuperViewHandler = {[weak label] in
                UIView.animate(withDuration: 0.3, animations: {
                    label?.alpha = 1
                    label?.center.y = chartPointModel.screenLoc.y
                })
            }
            return label
            
        }, displayDelay: 0.5, mode: .translate) // show after bars animation
        
        // NOTE: If you need the labels from labelsLayer to stay at the same distance from the bars during zooming, i.e. that the space between them and the bars is not scaled, use mode: .custom and pass a custom transform block, in which you update manually the position. Similar to how it's done in e.g. NotificationsExample for the notifications views.
        
        // line layer
        let lineChartPoints = lineData.enumerated().map {index, tuple in ChartPoint(x: ChartAxisValueDouble(index), y: ChartAxisValueDouble(tuple.val))}
        let lineModel = ChartLineModel(chartPoints: lineChartPoints, lineColor: UIColor.black, lineWidth: 2, animDuration: 0.5, animDelay: 1)
        let lineLayer = ChartPointsLineLayer(xAxis: xAxisLayer.axis, yAxis: yAxisLayer.axis, lineModels: [lineModel])
        
        // circles layer
        let circleViewGenerator = {(chartPointModel: ChartPointLayerModel, layer: ChartPointsLayer, chart: Chart) -> UIView? in
            let color = UIColor(red: 0.7, green: 0.7, blue: 0.7, alpha: 1)
            let circleView = ChartPointEllipseView(center: chartPointModel.screenLoc, diameter: 6)
            circleView.animDuration = 0.5
            circleView.fillColor = color
            return circleView
        }
        let lineCirclesLayer = ChartPointsViewsLayer(xAxis: xAxisLayer.axis, yAxis: yAxisLayer.axis, chartPoints: lineChartPoints, viewGenerator: circleViewGenerator, displayDelay: 1.5, delayBetweenItems: 0.05, mode: .translate)
        
        
        // show a gap between positive and negative bar
        let dummyZeroYChartPoint = ChartPoint(x: ChartAxisValueDouble(0), y: ChartAxisValueDouble(0))
        let yZeroGapLayer = ChartPointsViewsLayer(xAxis: xAxisLayer.axis, yAxis: yAxisLayer.axis, chartPoints: [dummyZeroYChartPoint], viewGenerator: {(chartPointModel, layer, chart) -> UIView? in
            let height: CGFloat = 2
            let v = UIView(frame: CGRect(x: chart.contentView.frame.origin.x + 2, y: chartPointModel.screenLoc.y - height / 2, width: chart.contentView.frame.origin.x + chart.contentView.frame.height, height: height))
            v.backgroundColor = UIColor.white
            return v
        })
        
        let chart = Chart(
            frame: chartFrame,
            innerFrame: innerFrame,
            settings: chartSettings,
            layers: [
                xAxisLayer,
                yAxisLayer,
                barsLayer,
                labelsLayer,
                yZeroGapLayer,
                lineLayer,
                lineCirclesLayer
            ]
        )
        
        view.addSubview(chart.view)
        self.chart = chart
    }

}
