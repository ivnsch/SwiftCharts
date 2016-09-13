//
//  AreasExample.swift
//  SwiftCharts
//
//  Created by ischuetz on 04/05/15.
//  Copyright (c) 2015 ivanschuetz. All rights reserved.
//

import UIKit
import SwiftCharts

class AreasExample: UIViewController {

    fileprivate var chart: Chart? // arc

    override func viewDidLoad() {
        super.viewDidLoad()

        let labelSettings = ChartLabelSettings(font: ExamplesDefaults.labelFont)

        let chartPoints1 = [(0, 50), (2, 65), (4, 125), (6, 140)].map{ChartPoint(x: ChartAxisValueInt($0.0, labelSettings: labelSettings), y: ChartAxisValueInt($0.1))}
        let chartPoints2 = [(0, 150), (2, 100), (4, 200), (6, 60)].map{ChartPoint(x: ChartAxisValueInt($0.0, labelSettings: labelSettings), y: ChartAxisValueInt($0.1))}
        let chartPoints3 = [(0, 200), (2, 210), (4, 260), (6, 290)].map{ChartPoint(x: ChartAxisValueInt($0.0, labelSettings: labelSettings), y: ChartAxisValueInt($0.1))}
        
        let allChartPoints = (chartPoints1 + chartPoints2 + chartPoints3).sorted {(obj1, obj2) in return obj1.x.scalar < obj2.x.scalar}
        
        let xValues: [ChartAxisValue] = (NSOrderedSet(array: allChartPoints).array as! [ChartPoint]).map{$0.x}
        let yValues = ChartAxisValuesGenerator.generateYAxisValuesWithChartPoints(allChartPoints, minSegmentCount: 5, maxSegmentCount: 20, multiple: 50, axisValueGenerator: {ChartAxisValueDouble($0, labelSettings: labelSettings)}, addPaddingSegmentIfEdge: false)
        
        let xModel = ChartAxisModel(axisValues: xValues, axisTitleLabel: ChartAxisLabel(text: "Axis title", settings: labelSettings))
        let yModel = ChartAxisModel(axisValues: yValues, axisTitleLabel: ChartAxisLabel(text: "Axis title", settings: labelSettings.defaultVertical()))
        let chartFrame = ExamplesDefaults.chartFrame(self.view.bounds)
        let chartSettings = ExamplesDefaults.chartSettings
        chartSettings.trailing = 20
        chartSettings.labelsToAxisSpacingX = 20
        chartSettings.labelsToAxisSpacingY = 20
        let coordsSpace = ChartCoordsSpaceLeftBottomSingleAxis(chartSettings: chartSettings, chartFrame: chartFrame, xModel: xModel, yModel: yModel)
        let (xAxis, yAxis, innerFrame) = (coordsSpace.xAxis, coordsSpace.yAxis, coordsSpace.chartInnerFrame)
        
        let c1 = UIColor(red: 0.1, green: 0.1, blue: 0.9, alpha: 0.4)
        let c2 = UIColor(red: 0.9, green: 0.1, blue: 0.1, alpha: 0.4)
        let c3 = UIColor(red: 0.1, green: 0.9, blue: 0.1, alpha: 0.4)
        
        
        let chartPointsLayer1 = ChartPointsAreaLayer(xAxis: xAxis, yAxis: yAxis, innerFrame: innerFrame, chartPoints: chartPoints1, areaColor: c1, animDuration: 3, animDelay: 0, addContainerPoints: true)
        let chartPointsLayer2 = ChartPointsAreaLayer(xAxis: xAxis, yAxis: yAxis, innerFrame: innerFrame, chartPoints: chartPoints2, areaColor: c2, animDuration: 3, animDelay: 0, addContainerPoints: true)
        let chartPointsLayer3 = ChartPointsAreaLayer(xAxis: xAxis, yAxis: yAxis, innerFrame: innerFrame, chartPoints: chartPoints3, areaColor: c3, animDuration: 3, animDelay: 0, addContainerPoints: true)
        
        let lineModel1 = ChartLineModel(chartPoints: chartPoints1, lineColor: UIColor.black, animDuration: 1, animDelay: 0)
        let lineModel2 = ChartLineModel(chartPoints: chartPoints2, lineColor: UIColor.black, animDuration: 1, animDelay: 0)
        let lineModel3 = ChartLineModel(chartPoints: chartPoints3, lineColor: UIColor.black, animDuration: 1, animDelay: 0)
        
        let chartPointsLineLayer = ChartPointsLineLayer(xAxis: xAxis, yAxis: yAxis, innerFrame: innerFrame, lineModels: [lineModel1, lineModel2, lineModel3])
        
        var popups: [UIView] = []
        var selectedView: ChartPointTextCircleView?
        
        let circleViewGenerator = {(chartPointModel: ChartPointLayerModel, layer: ChartPointsLayer, chart: Chart) -> UIView? in
            
            let (chartPoint, screenLoc) = (chartPointModel.chartPoint, chartPointModel.screenLoc)
            
            let v = ChartPointTextCircleView(chartPoint: chartPoint, center: screenLoc, diameter: Env.iPad ? 50 : 30, cornerRadius: Env.iPad ? 24: 15, borderWidth: Env.iPad ? 2 : 1, font: ExamplesDefaults.fontWithSize(Env.iPad ? 14 : 8))
            v.viewTapped = {view in
                for p in popups {p.removeFromSuperview()}
                selectedView?.selected = false
                
                let w: CGFloat = Env.iPad ? 250 : 150
                let h: CGFloat = Env.iPad ? 100 : 80
                
                let x: CGFloat = {
                    let attempt = screenLoc.x - (w/2)
                    let leftBound: CGFloat = chart.bounds.origin.x
                    let rightBound = chart.bounds.size.width - 5
                    if attempt < leftBound {
                        return view.frame.origin.x
                    } else if attempt + w > rightBound {
                        return rightBound - w
                    }
                    return attempt
                }()
                
                let frame = CGRect(x: x, y: screenLoc.y - (h + (Env.iPad ? 30 : 12)), width: w, height: h)
                
                let bubbleView = InfoBubble(frame: frame, arrowWidth: Env.iPad ? 40 : 28, arrowHeight: Env.iPad ? 20 : 14, bgColor: UIColor.black, arrowX: screenLoc.x - x)
                chart.addSubview(bubbleView)
                
                bubbleView.transform = CGAffineTransform(scaleX: 0, y: 0).concatenating(CGAffineTransform(translationX: 0, y: 100))
                let infoView = UILabel(frame: CGRect(x: 0, y: 10, width: w, height: h - 30))
                infoView.textColor = UIColor.white
                infoView.backgroundColor = UIColor.black
                infoView.text = "Some text about \(chartPoint)"
                infoView.font = ExamplesDefaults.fontWithSize(Env.iPad ? 14 : 12)
                infoView.textAlignment = NSTextAlignment.center
                
                bubbleView.addSubview(infoView)
                popups.append(bubbleView)
                
                UIView.animate(withDuration: 0.2, delay: 0, options: UIViewAnimationOptions(), animations: {
                    view.selected = true
                    selectedView = view
                    
                    bubbleView.transform = CGAffineTransform.identity
                    }, completion: {finished in})
            }
            
            return v
        }
        
        let itemsDelay: Float = 0.08
        let chartPointsCircleLayer1 = ChartPointsViewsLayer(xAxis: xAxis, yAxis: yAxis, innerFrame: innerFrame, chartPoints: chartPoints1, viewGenerator: circleViewGenerator, displayDelay: 0.9, delayBetweenItems: itemsDelay)
        
        let chartPointsCircleLayer2 = ChartPointsViewsLayer(xAxis: xAxis, yAxis: yAxis, innerFrame: innerFrame, chartPoints: chartPoints2, viewGenerator: circleViewGenerator, displayDelay: 1.8, delayBetweenItems: itemsDelay)
        
        let chartPointsCircleLayer3 = ChartPointsViewsLayer(xAxis: xAxis, yAxis: yAxis, innerFrame: innerFrame, chartPoints: chartPoints3, viewGenerator: circleViewGenerator, displayDelay: 2.7, delayBetweenItems: itemsDelay)
        
        let settings = ChartGuideLinesDottedLayerSettings(linesColor: UIColor.black, linesWidth: ExamplesDefaults.guidelinesWidth)
        let guidelinesLayer = ChartGuideLinesDottedLayer(xAxis: xAxis, yAxis: yAxis, innerFrame: innerFrame, settings: settings)
        
        let chart = Chart(
            frame: chartFrame,
            layers: [
                xAxis,
                yAxis,
                guidelinesLayer,
                chartPointsLayer1,
                chartPointsLayer2,
                chartPointsLayer3,
                chartPointsLineLayer,
                chartPointsCircleLayer1,
                chartPointsCircleLayer2,
                chartPointsCircleLayer3
            ]
        )
        
        self.view.addSubview(chart.view)
        self.chart = chart
    }

}
