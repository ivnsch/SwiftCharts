//
//  BarsExample.swift
//  SwiftCharts
//
//  Created by ischuetz on 04/05/15.
//  Copyright (c) 2015 ivanschuetz. All rights reserved.
//

import UIKit
import SwiftCharts

class BarsExample: UIViewController {
   
    let horizontalBars: Bool
    
    private var chart: Chart? // arc
    
    init(horizontalBars: Bool = false) {
        self.horizontalBars = horizontalBars
        super.init(nibName: nil, bundle: nil)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        
        let chartPoints: [ChartPoint] = [(2, 2), (4, 4), (6, 6), (8, 10), (12, 14)].map{ChartPoint(x: ChartAxisValueInt($0.0), y: ChartAxisValueInt($0.1))}
        
        let labelSettings = ChartLabelSettings(font: ExamplesDefaults.labelFont)

        let xValues = ChartAxisValuesGenerator.generateXAxisValuesWithChartPoints(chartPoints, minSegmentCount: 8, maxSegmentCount: 8, multiple: 2, axisValueGenerator: {ChartAxisValueFloat($0, labelSettings: labelSettings)}, addPaddingSegmentIfEdge: true)
        let yValues = ChartAxisValuesGenerator.generateYAxisValuesWithChartPoints(chartPoints, minSegmentCount: 10, maxSegmentCount: 10, multiple: 2, axisValueGenerator: {ChartAxisValueFloat($0, labelSettings: labelSettings)}, addPaddingSegmentIfEdge: true)
        
        let minBarSpacing: CGFloat = ExamplesDefaults.minBarSpacing
        
        let barViewGenerator = {[weak self] (chartPointModel: ChartPointLayerModel, layer: ChartPointsViewsLayer, chart: Chart) -> UIView? in
            let r = {CGFloat(Float(arc4random()) / Float(UINT32_MAX))}
            let randomColor: UIColor = UIColor(red: r(), green: r(), blue: r(), alpha: 0.7)
            let bottomLeft = CGPointMake(layer.innerFrame.origin.x, layer.innerFrame.origin.y + layer.innerFrame.height)
            
            let minSpace = self!.horizontalBars ? layer.minYScreenSpace : layer.minXScreenSpace
            let barWidth = minSpace - minBarSpacing
            
            return ChartPointViewBar(chartPoint: chartPointModel.chartPoint, screenLoc: chartPointModel.screenLoc, barWidth: barWidth, bottomLeft: bottomLeft, color: randomColor, horizontal: self!.horizontalBars)
        }
        
        let xModel = ChartAxisModel(axisValues: xValues, axisTitleLabel: ChartAxisLabel(text: "Axis title", settings: labelSettings))
        let yModel = ChartAxisModel(axisValues: yValues, axisTitleLabel: ChartAxisLabel(text: "Axis title", settings: labelSettings))
        let chartFrame = ExamplesDefaults.chartFrame(self.view.bounds)
        let coordsSpace = ChartCoordsSpaceLeftBottomSingleAxis(chartSettings: ExamplesDefaults.chartSettings, chartFrame: chartFrame, xModel: xModel, yModel: yModel)
        let (xAxis, yAxis, innerFrame) = (coordsSpace.xAxis, coordsSpace.yAxis, coordsSpace.chartInnerFrame)

        let chartPointsLayer = ChartPointsViewsLayer(axisX: xAxis, axisY: yAxis, innerFrame: innerFrame, chartPoints: chartPoints, viewGenerator: barViewGenerator)
        
        var settings = ChartGuideLinesDottedLayerSettings(linesColor: UIColor.blackColor(), linesWidth: ExamplesDefaults.guidelinesWidth, axis: .XAndY)
        let guidelinesLayer = ChartGuideLinesDottedLayer(axisX: xAxis, yAxis: yAxis, innerFrame: innerFrame, settings: settings)
        
        let chart = Chart(
            frame: chartFrame,
            layers: [
                coordsSpace.xAxis,
                coordsSpace.yAxis,
                guidelinesLayer,
                chartPointsLayer]
        )
        
        self.view.addSubview(chart.view)
        self.chart = chart
    }
}
