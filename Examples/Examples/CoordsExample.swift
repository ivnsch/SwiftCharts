//
//  CoordsExample.swift
//  SwiftCharts
//
//  Created by ischuetz on 04/05/15.
//  Copyright (c) 2015 ivanschuetz. All rights reserved.
//

import UIKit
import SwiftCharts

class CoordsExample: UIViewController {
    
    fileprivate var chart: Chart? // arc
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let labelSettings = ChartLabelSettings(font: ExamplesDefaults.labelFont)
        
        let chartPoints = [(2, 2), (3, 1), (5, 9), (6, 7), (8, 10), (9, 9), (10, 15), (13, 8), (15, 20), (16, 17)].map{ChartPoint(x: ChartAxisValueInt($0.0), y: ChartAxisValueInt($0.1))}
        
        let xValues = ChartAxisValuesStaticGenerator.generateXAxisValuesWithChartPoints(chartPoints, minSegmentCount: 7, maxSegmentCount: 7, multiple: 2, axisValueGenerator: {ChartAxisValueDouble($0, labelSettings: labelSettings)}, addPaddingSegmentIfEdge: false)
        let yValues = ChartAxisValuesStaticGenerator.generateYAxisValuesWithChartPoints(chartPoints, minSegmentCount: 10, maxSegmentCount: 20, multiple: 2, axisValueGenerator: {ChartAxisValueDouble($0, labelSettings: labelSettings)}, addPaddingSegmentIfEdge: true)
        
        let xModel = ChartAxisModel(axisValues: xValues, axisTitleLabel: ChartAxisLabel(text: "Axis title", settings: labelSettings))
        let yModel = ChartAxisModel(axisValues: yValues, axisTitleLabel: ChartAxisLabel(text: "Axis title", settings: labelSettings.defaultVertical()))
        let chartFrame = ExamplesDefaults.chartFrame(view.bounds)
        
        var chartSettings = ExamplesDefaults.chartSettings // for now no zooming and panning here until ChartShowCoordsLinesLayer is improved to not scale the lines during zooming.
        chartSettings.trailing = 20
        chartSettings.labelsToAxisSpacingX = 15
        chartSettings.labelsToAxisSpacingY = 15
        let coordsSpace = ChartCoordsSpaceLeftBottomSingleAxis(chartSettings: chartSettings, chartFrame: chartFrame, xModel: xModel, yModel: yModel)
        let (xAxisLayer, yAxisLayer, innerFrame) = (coordsSpace.xAxisLayer, coordsSpace.yAxisLayer, coordsSpace.chartInnerFrame)
    

        let labelWidth: CGFloat = 70
        let labelHeight: CGFloat = 30
        
        let showCoordsTextViewsGenerator = {(chartPointModel: ChartPointLayerModel, layer: ChartPointsLayer, chart: Chart) -> UIView? in
            let (chartPoint, screenLoc) = (chartPointModel.chartPoint, chartPointModel.screenLoc)
            let text = chartPoint.description
            let font = ExamplesDefaults.labelFont
            let x = min(screenLoc.x + 5, chart.bounds.width - text.width(font) - 5)
            let view = UIView(frame: CGRect(x: x, y: screenLoc.y - labelHeight, width: labelWidth, height: labelHeight))
            let label = UILabel(frame: view.bounds)
            label.text = text
            label.font = ExamplesDefaults.labelFont
            view.addSubview(label)
            view.alpha = 0

            UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut, animations: {
                view.alpha = 1
            }, completion: nil)
            
            return view
        }
        
        let showCoordsLinesLayer = ChartShowCoordsLinesLayer<ChartPoint>(xAxis: xAxisLayer.axis, yAxis: yAxisLayer.axis, chartPoints: chartPoints)
        
        let showCoordsTextLayer = ChartPointsSingleViewLayer<ChartPoint, UIView>(xAxis: xAxisLayer.axis, yAxis: yAxisLayer.axis, innerFrame: innerFrame, chartPoints: chartPoints, viewGenerator: showCoordsTextViewsGenerator, mode: .custom, keepOnFront: true)
        // To preserve the offset of the notification views from the chart point they represent, during transforms, we need to pass mode: .custom along with this custom transformer.
        showCoordsTextLayer.customTransformer = {(model, view, layer) -> Void in
            guard let chart = layer.chart else {return}
            
            let text = model.chartPoint.description

            let screenLoc = layer.modelLocToScreenLoc(x: model.chartPoint.x.scalar, y: model.chartPoint.y.scalar)
            let x = min(screenLoc.x + 5, chart.bounds.width - text.width(ExamplesDefaults.labelFont) - 5)
            
            view.frame.origin = CGPoint(x: x, y: screenLoc.y - labelHeight)
        }
        
        let touchViewsGenerator = {(chartPointModel: ChartPointLayerModel, layer: ChartPointsLayer, chart: Chart) -> UIView? in
            let (chartPoint, screenLoc) = (chartPointModel.chartPoint, chartPointModel.screenLoc)
            let s: CGFloat = 30
            let view = HandlingView(frame: CGRect(x: screenLoc.x - s/2, y: screenLoc.y - s/2, width: s, height: s))
            view.touchHandler = {[weak showCoordsLinesLayer, weak showCoordsTextLayer, weak chartPoint, weak chart] in
                guard let chartPoint = chartPoint, let chart = chart else {return}
                showCoordsLinesLayer?.showChartPointLines(chartPoint, chart: chart)
                showCoordsTextLayer?.showView(chartPoint: chartPoint, chart: chart)
            }
            return view
        }
        
        let touchLayer = ChartPointsViewsLayer(xAxis: xAxisLayer.axis, yAxis: yAxisLayer.axis, chartPoints: chartPoints, viewGenerator: touchViewsGenerator, mode: .translate, keepOnFront: true)
        
        let lineModel = ChartLineModel(chartPoints: chartPoints, lineColor: UIColor(red: 0.4, green: 0.4, blue: 1, alpha: 0.2), lineWidth: 3, animDuration: 0.7, animDelay: 0)
        let chartPointsLineLayer = ChartPointsLineLayer(xAxis: xAxisLayer.axis, yAxis: yAxisLayer.axis, lineModels: [lineModel])
        
        let circleViewGenerator = {(chartPointModel: ChartPointLayerModel, layer: ChartPointsLayer, chart: Chart) -> UIView? in
            let circleView = ChartPointEllipseView(center: chartPointModel.screenLoc, diameter: 24)
            circleView.animDuration = 1.5
            circleView.fillColor = UIColor.white
            circleView.borderWidth = 5
            circleView.borderColor = UIColor.blue
            return circleView
        }
        let chartPointsCircleLayer = ChartPointsViewsLayer(xAxis: xAxisLayer.axis, yAxis: yAxisLayer.axis, chartPoints: chartPoints, viewGenerator: circleViewGenerator, displayDelay: 0, delayBetweenItems: 0.05, mode: .translate)
        
        let settings = ChartGuideLinesDottedLayerSettings(linesColor: UIColor.black, linesWidth: ExamplesDefaults.guidelinesWidth)
        let guidelinesLayer = ChartGuideLinesDottedLayer(xAxisLayer: xAxisLayer, yAxisLayer: yAxisLayer, settings: settings)
        
        
        let chart = Chart(
            frame: chartFrame,
            innerFrame: innerFrame,
            settings: chartSettings,
            layers: [
                xAxisLayer,
                yAxisLayer,
                guidelinesLayer,
                showCoordsLinesLayer,
                chartPointsLineLayer,
                chartPointsCircleLayer,
                showCoordsTextLayer,
                touchLayer,
                
            ]
        )
        
        view.addSubview(chart.view)
        self.chart = chart
    }
    
}
