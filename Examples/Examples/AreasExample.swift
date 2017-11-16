//
//  AreasExample.swift
//  SwiftCharts
//
//  Created by ischuetz on 04/05/15.
//  Copyright (c) 2015 ivanschuetz. All rights reserved.
//

import UIKit
import SwiftCharts

class AreasExample: UIViewController, ChartDelegate {

    fileprivate var chart: Chart? // arc

    fileprivate var popups: [UIView] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        let labelSettings = ChartLabelSettings(font: ExamplesDefaults.labelFont)

        let chartPoints1 = [(0, 50), (2, 65), (4, 125), (6, 140)].map{ChartPoint(x: ChartAxisValueInt($0.0, labelSettings: labelSettings), y: ChartAxisValueInt($0.1))}
        let chartPoints2 = [(0, 150), (2, 100), (4, 200), (6, 60)].map{ChartPoint(x: ChartAxisValueInt($0.0, labelSettings: labelSettings), y: ChartAxisValueInt($0.1))}
        let chartPoints3 = [(0, 200), (2, 210), (4, 260), (6, 290)].map{ChartPoint(x: ChartAxisValueInt($0.0, labelSettings: labelSettings), y: ChartAxisValueInt($0.1))}
        
        let allChartPoints = (chartPoints1 + chartPoints2 + chartPoints3).sorted {(obj1, obj2) in return obj1.x.scalar < obj2.x.scalar}
        
        let xValues: [ChartAxisValue] = (NSOrderedSet(array: allChartPoints).array as! [ChartPoint]).map{$0.x}
        let yValues = ChartAxisValuesStaticGenerator.generateYAxisValuesWithChartPoints(allChartPoints, minSegmentCount: 5, maxSegmentCount: 20, multiple: 50, axisValueGenerator: {ChartAxisValueDouble($0, labelSettings: labelSettings)}, addPaddingSegmentIfEdge: false)
        
        let xModel = ChartAxisModel(axisValues: xValues, axisTitleLabel: ChartAxisLabel(text: "Axis title", settings: labelSettings))
        let yModel = ChartAxisModel(axisValues: yValues, axisTitleLabel: ChartAxisLabel(text: "Axis title", settings: labelSettings.defaultVertical()))
        let chartFrame = ExamplesDefaults.chartFrame(view.bounds)
        var chartSettings = ExamplesDefaults.chartSettingsWithPanZoom
        chartSettings.trailing = 20
        chartSettings.labelsToAxisSpacingX = 20
        chartSettings.labelsToAxisSpacingY = 20
        let coordsSpace = ChartCoordsSpaceLeftBottomSingleAxis(chartSettings: chartSettings, chartFrame: chartFrame, xModel: xModel, yModel: yModel)
        let (xAxisLayer, yAxisLayer, innerFrame) = (coordsSpace.xAxisLayer, coordsSpace.yAxisLayer, coordsSpace.chartInnerFrame)
        
        let c1 = UIColor(red: 0.1, green: 0.1, blue: 0.9, alpha: 0.4)
        let c2 = UIColor(red: 0.9, green: 0.1, blue: 0.1, alpha: 0.4)
        let c3 = UIColor(red: 0.1, green: 0.9, blue: 0.1, alpha: 0.4)
        
        let lineModel1 = ChartLineModel(chartPoints: chartPoints1, lineColor: UIColor.black, animDuration: 1, animDelay: 0)
        let lineModel2 = ChartLineModel(chartPoints: chartPoints2, lineColor: UIColor.black, animDuration: 1, animDelay: 0)
        let lineModel3 = ChartLineModel(chartPoints: chartPoints3, lineColor: UIColor.black, animDuration: 1, animDelay: 0)
        
        let chartPointsLineLayer = ChartPointsLineLayer(xAxis: xAxisLayer.axis, yAxis: yAxisLayer.axis, lineModels: [lineModel1, lineModel2, lineModel3], pathGenerator: CatmullPathGenerator())
        
        let chartPointsLayer1 = ChartPointsAreaLayer(xAxis: xAxisLayer.axis, yAxis: yAxisLayer.axis, chartPoints: chartPoints1, areaColors: [c1], animDuration: 3, animDelay: 0, addContainerPoints: true, pathGenerator: chartPointsLineLayer.pathGenerator)
        let chartPointsLayer2 = ChartPointsAreaLayer(xAxis: xAxisLayer.axis, yAxis: yAxisLayer.axis, chartPoints: chartPoints2, areaColors: [c2], animDuration: 3, animDelay: 0, addContainerPoints: true, pathGenerator: chartPointsLineLayer.pathGenerator)
        let chartPointsLayer3 = ChartPointsAreaLayer(xAxis: xAxisLayer.axis, yAxis: yAxisLayer.axis, chartPoints: chartPoints3, areaColors: [c3], animDuration: 3, animDelay: 0, addContainerPoints: true, pathGenerator: chartPointsLineLayer.pathGenerator)
        
        var selectedView: ChartPointTextCircleView?
        
        let circleViewGenerator = {[weak self] (chartPointModel: ChartPointLayerModel, layer: ChartPointsLayer, chart: Chart) -> UIView? in guard let weakSelf = self else {return nil}
            
            let (chartPoint, screenLoc) = (chartPointModel.chartPoint, chartPointModel.screenLoc)
            
            let v = ChartPointTextCircleView(chartPoint: chartPoint, center: screenLoc, diameter: Env.iPad ? 50 : 30, cornerRadius: Env.iPad ? 24: 15, borderWidth: Env.iPad ? 2 : 1, font: ExamplesDefaults.fontWithSize(Env.iPad ? 14 : 8))
            v.viewTapped = {view in
                for p in weakSelf.popups {p.removeFromSuperview()}
                selectedView?.selected = false
                
                let w: CGFloat = Env.iPad ? 250 : 150
                let h: CGFloat = Env.iPad ? 100 : 80
                
                if let chartViewScreenLoc = layer.containerToGlobalScreenLoc(chartPoint) {
                    let x: CGFloat = {
                        let attempt = chartViewScreenLoc.x - (w/2)
                        let leftBound: CGFloat = chart.bounds.origin.x
                        let rightBound = chart.bounds.size.width - 5
                        if attempt < leftBound {
                            return view.frame.origin.x
                        } else if attempt + w > rightBound {
                            return rightBound - w
                        }
                        return attempt
                    }()

                    let frame = CGRect(x: x, y: chartViewScreenLoc.y - (h + (Env.iPad ? 30 : 12)), width: w, height: h)
                    
                    let bubbleView = InfoBubble(point: chartViewScreenLoc, frame: frame, arrowWidth: Env.iPad ? 40 : 28, arrowHeight: Env.iPad ? 20 : 14, bgColor: UIColor.black, arrowX: chartViewScreenLoc.x - x, arrowY: -1) // TODO don't calculate this here
                    chart.view.addSubview(bubbleView)
                    
                    bubbleView.transform = CGAffineTransform(scaleX: 0, y: 0).concatenating(CGAffineTransform(translationX: 0, y: 100))
                    let infoView = UILabel(frame: CGRect(x: 0, y: 10, width: w, height: h - 30))
                    infoView.textColor = UIColor.white
                    infoView.backgroundColor = UIColor.black
                    infoView.text = "Some text about \(chartPoint)"
                    infoView.font = ExamplesDefaults.fontWithSize(Env.iPad ? 14 : 12)
                    infoView.textAlignment = NSTextAlignment.center
                    
                    bubbleView.addSubview(infoView)
                    weakSelf.popups.append(bubbleView)
                    
                    UIView.animate(withDuration: 0.2, delay: 0, options: UIViewAnimationOptions(), animations: {
                        view.selected = true
                        selectedView = view
                        
                        bubbleView.transform = CGAffineTransform.identity
                    }, completion: {finished in})
                }
            }
            
            UIView.animate(withDuration: 0.7, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0, options: UIViewAnimationOptions(), animations: {
                let w: CGFloat = v.frame.size.width
                let h: CGFloat = v.frame.size.height
                let frame = CGRect(x: screenLoc.x - (w/2), y: screenLoc.y - (h/2), width: w, height: h)
                v.frame = frame
            }, completion: nil)
        
            return v
        }
        
        let itemsDelay: Float = 0.08

        // To not have circles clipped by the chart bounds, pass clipViews: false (and ChartSettings.customClipRect in case you want to clip them by other bounds)
        let chartPointsCircleLayer1 = ChartPointsViewsLayer(xAxis: xAxisLayer.axis, yAxis: yAxisLayer.axis, chartPoints: chartPoints1, viewGenerator: circleViewGenerator, displayDelay: 0.9, delayBetweenItems: itemsDelay, mode: .translate)
        
        let chartPointsCircleLayer2 = ChartPointsViewsLayer(xAxis: xAxisLayer.axis, yAxis: yAxisLayer.axis, chartPoints: chartPoints2, viewGenerator: circleViewGenerator, displayDelay: 1.8, delayBetweenItems: itemsDelay, mode: .translate)
        
        let chartPointsCircleLayer3 = ChartPointsViewsLayer(xAxis: xAxisLayer.axis, yAxis: yAxisLayer.axis, chartPoints: chartPoints3, viewGenerator: circleViewGenerator, displayDelay: 2.7, delayBetweenItems: itemsDelay, mode: .translate)
        
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
                chartPointsLayer1,
                chartPointsLayer2,
                chartPointsLayer3,
                chartPointsLineLayer,
                chartPointsCircleLayer1,
                chartPointsCircleLayer2,
                chartPointsCircleLayer3
            ]
        )
        
        chart.delegate = self
        
        view.addSubview(chart.view)
        self.chart = chart
    }

    fileprivate func removePopups() {
        for popup in popups {
            popup.removeFromSuperview()
        }
    }
    
    // MARK: - ChartDelegate
    
    func onZoom(scaleX: CGFloat, scaleY: CGFloat, deltaX: CGFloat, deltaY: CGFloat, centerX: CGFloat, centerY: CGFloat, isGesture: Bool) {
        removePopups()
    }
    
    func onPan(transX: CGFloat, transY: CGFloat, deltaX: CGFloat, deltaY: CGFloat, isGesture: Bool, isDeceleration: Bool) {
        removePopups()
    }
    
    func onTap(_ models: [TappedChartPointLayerModels<ChartPoint>]) {
    }
}
