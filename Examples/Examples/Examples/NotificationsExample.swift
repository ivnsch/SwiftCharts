//
//  NotificationsExample.swift
//  SwiftCharts
//
//  Created by ischuetz on 04/05/15.
//  Copyright (c) 2015 ivanschuetz. All rights reserved.
//

import UIKit
import SwiftCharts

class NotificationsExample: UIViewController {

    private var chart: Chart? // arc

    override func viewDidLoad() {
        super.viewDidLoad()

        let labelSettings = ChartLabelSettings(font: ExamplesDefaults.labelFont)
        
        let chartPoints: [ChartPoint] = [(1, 3), (2, 4), (4, 1), (5, 6), (6, 4), (7, 9), (8, 0), (10, 4), (12, 2)].map{ChartPoint(x: ChartAxisValueInt($0.0, labelSettings: labelSettings), y: ChartAxisValueInt($0.1))}
        
        let xValues = chartPoints.map{$0.x}
        let yValues = ChartAxisValuesGenerator.generateYAxisValuesWithChartPoints(chartPoints, minSegmentCount: 10, maxSegmentCount: 20, multiple: 2, axisValueGenerator: {ChartAxisValueFloat($0, labelSettings: labelSettings)}, addPaddingSegmentIfEdge: false)
        
        let lineModel = ChartLineModel(chartPoints: chartPoints, lineColor: UIColor.redColor(), animDuration: 1, animDelay: 0)
        
        let notificationGenerator = {[weak self] (chartPointModel: ChartPointLayerModel, layer: ChartPointsLayer, chart: Chart) -> UIView? in
            let (chartPoint, screenLoc) = (chartPointModel.chartPoint, chartPointModel.screenLoc)
            if chartPoint.y.scalar <= 1 {
                let w: CGFloat = Env.iPad ? 30 : 20
                let h: CGFloat = Env.iPad ? 30 : 20
                let chartPointView = HandlingView(frame: CGRectMake(screenLoc.x + 5, screenLoc.y - h - 5, w, h))
                let label = UILabel(frame: chartPointView.bounds)
                label.layer.cornerRadius = Env.iPad ? 15 : 10
                label.clipsToBounds = true
                label.backgroundColor = UIColor.redColor()
                label.textColor = UIColor.whiteColor()
                label.textAlignment = NSTextAlignment.Center
                label.font = UIFont.boldSystemFontOfSize(Env.iPad ? 22 : 18)
                label.text = "!"
                chartPointView.addSubview(label)
                label.transform = CGAffineTransformMakeScale(0, 0)
                
                chartPointView.movedToSuperViewHandler = {
                    UIView.animateWithDuration(0.5, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0, options: UIViewAnimationOptions.allZeros, animations: {() -> Void in
                        label.transform = CGAffineTransformMakeScale(1, 1)
                        }, completion: {(Bool) -> Void in})
                }
                
                var currentAlert: UIAlertController? = nil
                chartPointView.touchHandler = {
                    let alert = UIAlertController(title: "Lorem", message: "Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua.", preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
                    self!.presentViewController(alert, animated: true, completion: nil)
                    currentAlert?.removeFromParentViewController()
                    currentAlert = alert
                }
                
                return chartPointView
            }
            return nil
        }
        
        let xModel = ChartAxisModel(axisValues: xValues, axisTitleLabel: ChartAxisLabel(text: "Axis title", settings: labelSettings))
        let yModel = ChartAxisModel(axisValues: yValues, axisTitleLabel: ChartAxisLabel(text: "Axis title", settings: labelSettings))
        let chartFrame = ExamplesDefaults.chartFrame(self.view.bounds)
        let coordsSpace = ChartCoordsSpaceLeftBottomSingleAxis(chartSettings: ExamplesDefaults.chartSettings, chartFrame: chartFrame, xModel: xModel, yModel: yModel)
        let (xAxis, yAxis, innerFrame) = (coordsSpace.xAxis, coordsSpace.yAxis, coordsSpace.chartInnerFrame)

        let chartPointsNotificationsLayer = ChartPointsViewsLayer(axisX: xAxis, axisY: yAxis, innerFrame: innerFrame, chartPoints: chartPoints, viewGenerator: notificationGenerator, displayDelay: 1)
        
        let chartPointsLineLayer = ChartPointsLineLayer(axisX: xAxis, axisY: yAxis, innerFrame: innerFrame, lineModels: [lineModel])
        
        var settings = ChartGuideLinesDottedLayerSettings(linesColor: UIColor.blackColor(), linesWidth: ExamplesDefaults.guidelinesWidth, axis: .XAndY)
        let guidelinesLayer = ChartGuideLinesDottedLayer(axisX: xAxis, yAxis: yAxis, innerFrame: innerFrame, settings: settings)
        
        let chart = Chart(
            frame: chartFrame,
            layers: [
                xAxis,
                yAxis,
                guidelinesLayer,
                chartPointsLineLayer,
                chartPointsNotificationsLayer]
        )
        
        self.view.addSubview(chart.view)
        self.chart = chart
    }
}
