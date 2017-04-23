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

    fileprivate var chart: Chart? // arc

    override func viewDidLoad() {
        super.viewDidLoad()

        let labelSettings = ChartLabelSettings(font: ExamplesDefaults.labelFont)
        
        let chartPoints: [ChartPoint] = [(1, 3), (2, 4), (4, 1), (5, 6), (6, 4), (7, 9), (8, 0), (10, 4), (12, 2)].map{ChartPoint(x: ChartAxisValueInt($0.0, labelSettings: labelSettings), y: ChartAxisValueInt($0.1))}
        
        let xValues = chartPoints.map{$0.x}
        let yValues = ChartAxisValuesStaticGenerator.generateYAxisValuesWithChartPoints(chartPoints, minSegmentCount: 10, maxSegmentCount: 20, multiple: 2, axisValueGenerator: {ChartAxisValueDouble($0, labelSettings: labelSettings)}, addPaddingSegmentIfEdge: false)
        
        let lineModel = ChartLineModel(chartPoints: chartPoints, lineColor: UIColor.red, animDuration: 1, animDelay: 0)
        
        let notificationViewWidth: CGFloat = Env.iPad ? 30 : 20
        let notificationViewHeight: CGFloat = Env.iPad ? 30 : 20
        
        let notificationGenerator = {[weak self] (chartPointModel: ChartPointLayerModel, layer: ChartPointsLayer, chart: Chart) -> UIView? in
            let (chartPoint, screenLoc) = (chartPointModel.chartPoint, chartPointModel.screenLoc)
            
            if chartPoint.y.scalar <= 1 {

                let chartPointView = HandlingView(frame: CGRect(x: screenLoc.x + 5, y: screenLoc.y - notificationViewHeight - 5, width: notificationViewWidth, height: notificationViewHeight))
                let label = UILabel(frame: chartPointView.bounds)
                label.layer.cornerRadius = Env.iPad ? 15 : 10
                label.clipsToBounds = true
                label.backgroundColor = UIColor.red
                label.textColor = UIColor.white
                label.textAlignment = NSTextAlignment.center
                label.font = UIFont.boldSystemFont(ofSize: Env.iPad ? 22 : 18)
                label.text = "!"
                chartPointView.addSubview(label)
                label.transform = CGAffineTransform(scaleX: 0, y: 0)
                
                chartPointView.movedToSuperViewHandler = {
                    UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0, options: UIViewAnimationOptions(), animations: {
                        label.transform = CGAffineTransform(scaleX: 1, y: 1)
                    }, completion: nil)
                }
                
                chartPointView.touchHandler = {
                    
                    let title = "Lorem"
                    let message = "Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua."
                    let ok = "Ok"
                    
                        if #available(iOS 8.0, *) {
                            let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
                            alert.addAction(UIAlertAction(title: ok, style: UIAlertActionStyle.default, handler: nil))
                            self!.present(alert, animated: true, completion: nil)

                        } else {
                            let alert = UIAlertView()
                            alert.title = title
                            alert.message = message
                            alert.addButton(withTitle: ok)
                            alert.show()
                        }
                }
                
                return chartPointView
            }
            return nil
        }
        
        let xModel = ChartAxisModel(axisValues: xValues, axisTitleLabel: ChartAxisLabel(text: "Axis title", settings: labelSettings))
        let yModel = ChartAxisModel(axisValues: yValues, axisTitleLabel: ChartAxisLabel(text: "Axis title", settings: labelSettings.defaultVertical()))
        let chartFrame = ExamplesDefaults.chartFrame(view.bounds)
        
        let chartSettings = ExamplesDefaults.chartSettingsWithPanZoom

        let coordsSpace = ChartCoordsSpaceLeftBottomSingleAxis(chartSettings: chartSettings, chartFrame: chartFrame, xModel: xModel, yModel: yModel)
        let (xAxisLayer, yAxisLayer, innerFrame) = (coordsSpace.xAxisLayer, coordsSpace.yAxisLayer, coordsSpace.chartInnerFrame)

        let chartPointsNotificationsLayer = ChartPointsViewsLayer(xAxis: xAxisLayer.axis, yAxis: yAxisLayer.axis, chartPoints: chartPoints, viewGenerator: notificationGenerator, displayDelay: 1, mode: .custom)
        // To preserve the offset of the notification views from the chart point they represent, during transforms, we need to pass mode: .custom along with this custom transformer.
        chartPointsNotificationsLayer.customTransformer = {(model, view, layer) -> Void in
            let screenLoc = layer.modelLocToScreenLoc(x: model.chartPoint.x.scalar, y: model.chartPoint.y.scalar)
            view.frame.origin = CGPoint(x: screenLoc.x + 5, y: screenLoc.y - notificationViewHeight - 5)
        }
        
        let chartPointsLineLayer = ChartPointsLineLayer(xAxis: xAxisLayer.axis, yAxis: yAxisLayer.axis, lineModels: [lineModel])
        
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
                chartPointsLineLayer,
                chartPointsNotificationsLayer]
        )
        
        view.addSubview(chart.view)
        self.chart = chart
    }
}
