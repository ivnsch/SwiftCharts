//
//  BarsSelectAxisExample.swift
//  SwiftCharts
//
//  Created by ischuetz on 04/05/15.
//  Copyright (c) 2015 ivanschuetz. All rights reserved.
//

import UIKit


private enum Side {
    case Left, Right, Top, Bottom
}

class BarsSelectAxisExample: UIViewController {
    
    private var chart: Chart?
    
    let sideSelectorHeight: CGFloat = 50
    
    private func barsChart(#side: Side) -> Chart {
        let chartPoints: [ChartPoint] = [(2, 2), (4, 4), (6, 6), (8, 10), (12, 14)].map{ChartPoint(x: ChartAxisValueInt($0.0), y: ChartAxisValueInt($0.1))}
        
        let labelSettings = ChartLabelSettings(font: ExamplesDefaults.labelFont)
        
        let xValues = ChartAxisValuesGenerator.generateXAxisValuesWithChartPoints(chartPoints, minSegmentCount: 8, maxSegmentCount: 8, multiple: 2, axisValueGenerator: {ChartAxisValueFloat($0, labelSettings: labelSettings)}, addPaddingSegmentIfEdge: true)
        let yValues = ChartAxisValuesGenerator.generateYAxisValuesWithChartPoints(chartPoints, minSegmentCount: 10, maxSegmentCount: 10, multiple: 2, axisValueGenerator: {ChartAxisValueFloat($0, labelSettings: labelSettings)}, addPaddingSegmentIfEdge: true)
        
        let minBarSpacing: CGFloat = ExamplesDefaults.minBarSpacing
        
        let barViewGenerator = {[weak self] (chartPointModel: ChartPointLayerModel, layer: ChartPointsViewsLayer, chart: Chart) -> UIView? in
            let r = {CGFloat(Float(arc4random()) / Float(UINT32_MAX))}
            let randomColor: UIColor = UIColor(red: r(), green: r(), blue: r(), alpha: 0.7)
            let bottomLeft = CGPointMake(layer.innerFrame.origin.x, layer.innerFrame.origin.y + layer.innerFrame.height)
            
            let minSpace = side == .Left || side == .Right ? layer.minYScreenSpace : layer.minXScreenSpace
            let barWidth = minSpace - minBarSpacing
            
            let (p1: CGPoint, p2: CGPoint) = {
                switch side {
                    case .Left:
                        return (CGPointMake(bottomLeft.x, chartPointModel.screenLoc.y), CGPointMake(chartPointModel.screenLoc.x, chartPointModel.screenLoc.y))
                    case .Right:
                        return (CGPointMake(bottomLeft.x + layer.innerFrame.size.width, chartPointModel.screenLoc.y), CGPointMake(chartPointModel.screenLoc.x, chartPointModel.screenLoc.y))
                    case .Top:
                        return (CGPointMake(chartPointModel.screenLoc.x, layer.innerFrame.origin.y), CGPointMake(chartPointModel.screenLoc.x, chartPointModel.screenLoc.y))
                    case .Bottom:
                        return (CGPointMake(chartPointModel.screenLoc.x, bottomLeft.y), CGPointMake(chartPointModel.screenLoc.x, chartPointModel.screenLoc.y))
                }
            }()
            return ChartPointViewBar(p1: p1, p2: p2, width: barWidth, bgColor: randomColor)
        }

        let frame = ExamplesDefaults.chartFrame(self.view.bounds)
        let chartFrame = self.chart?.frame ?? CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, frame.size.height - sideSelectorHeight)
        
        
        let yLowModels: [ChartAxisModel] = [ChartAxisModel(axisValues: yValues, axisTitleLabels: [ChartAxisLabel(text: "Axis title", settings: labelSettings)])]
        let yHighModels: [ChartAxisModel] = [ChartAxisModel(axisValues: yValues, axisTitleLabels: [ChartAxisLabel(text: "Axis title", settings: labelSettings)])]
        let xLowModels: [ChartAxisModel] = [ChartAxisModel(axisValues: xValues, axisTitleLabels: [ChartAxisLabel(text: "Axis title", settings: labelSettings)])]
        let xHighModels: [ChartAxisModel] = [ChartAxisModel(axisValues: xValues, axisTitleLabels: [ChartAxisLabel(text: "Axis title", settings: labelSettings)])]
        
        let (yLow: [ChartAxisModel], yHigh: [ChartAxisModel], xLow: [ChartAxisModel], xHigh: [ChartAxisModel]) = {
            switch side {
                case .Left:
                    return (yLowModels, [], xLowModels, [])
                case .Right:
                    return ([], yHighModels, xLowModels, [])
                case .Top:
                    return (yLowModels, [], [], xHighModels)
                case .Bottom:
                    return (yLowModels, [], xLowModels, [])
            }
        }()
        
        let coordsSpace = ChartCoordsSpace(chartSettings: ExamplesDefaults.chartSettings, chartSize: chartFrame.size, yLowModels: yLow, yHighModels: yHigh, xLowModels: xLow, xHighModels: xHigh)
        let xAxis = (xLow.isEmpty ? coordsSpace.generateXHighAxes() : coordsSpace.generateXLowAxes())[0]
        let yAxis = (yLow.isEmpty ? coordsSpace.generateYHighAxes() : coordsSpace.generateYLowAxes())[0]
        let innerFrame = coordsSpace.calculateChartInnerFrame()
        
        let chartPointsLayer = ChartPointsViewsLayer(axisX: xAxis, axisY: yAxis, innerFrame: innerFrame, chartPoints: chartPoints, viewGenerator: barViewGenerator)
        
        var settings = ChartGuideLinesDottedLayerSettings(linesColor: UIColor.blackColor(), linesWidth: ExamplesDefaults.guidelinesWidth, axis: .XAndY)
        let guidelinesLayer = ChartGuideLinesDottedLayer(axisX: xAxis, yAxis: yAxis, innerFrame: innerFrame, settings: settings)
        
        return Chart(
            frame: chartFrame,
            layers: [
                xAxis,
                yAxis,
                guidelinesLayer,
                chartPointsLayer]
        )
    }
    
    private func showChart(#side: Side) {
        self.chart?.clearView()
        
        let chart = self.barsChart(side: side)
        self.view.addSubview(chart.view)
        self.chart = chart
    }
    
    override func viewDidLoad() {
        self.showChart(side: .Left)
        if let chart = self.chart {
            let sideSelector = SideSelector(frame: CGRectMake(0, chart.frame.origin.y + chart.frame.size.height, self.view.frame.size.width, self.sideSelectorHeight), controller: self)
            self.view.addSubview(sideSelector)
        }
    }
    
    
    class SideSelector: UIView {
        
        let left: UIButton
        let right: UIButton
        let top: UIButton
        let bottom: UIButton
        
        weak var controller: BarsSelectAxisExample?
        
        private let buttonSides: [UIButton : Side]
        
        init(frame: CGRect, controller: BarsSelectAxisExample) {
            
            self.controller = controller
            
            self.left = UIButton()
            self.left.setTitle("Left", forState: .Normal)
            self.right = UIButton()
            self.right.setTitle("Right", forState: .Normal)
            self.top = UIButton()
            self.top.setTitle("Top", forState: .Normal)
            self.bottom = UIButton()
            self.bottom.setTitle("Bottom", forState: .Normal)
            
            self.buttonSides = [self.left : .Left, self.right : .Right, self.top : .Top, self.bottom : .Bottom]
            
            super.init(frame: frame)
            
            self.addSubview(self.left)
            self.addSubview(self.right)
            self.addSubview(self.top)
            self.addSubview(self.bottom)
            
            for button in [self.left, self.right, self.top, self.bottom] {
                button.titleLabel?.font = ExamplesDefaults.fontWithSize(14)
                button.setTitleColor(UIColor.blueColor(), forState: .Normal)
                button.addTarget(self, action: "buttonTapped:", forControlEvents: .TouchUpInside)
            }
        }
        
        func buttonTapped(sender: UIButton) {
            if let side = self.buttonSides[sender] {
                controller?.showChart(side: side)
            }
        }
        
        override func didMoveToSuperview() {
            let views = [self.left, self.right, self.top, self.bottom]
            for v in views {
                v.setTranslatesAutoresizingMaskIntoConstraints(false)
            }
            
            let namedViews = Array(enumerate(views)).map{index, view in
                ("v\(index)", view)
            }
            
            let viewsDict = namedViews.reduce(Dictionary<String, UIView>()) {(var u, tuple) in
                u[tuple.0] = tuple.1
                return u
            }
            
            let buttonsSpace: CGFloat = Env.iPad ? 20 : 10
            
            let hConstraintStr = namedViews.reduce("H:|") {str, tuple in
                "\(str)-(\(buttonsSpace))-[\(tuple.0)]"
            }
            
            let vConstraits = namedViews.flatMap {NSLayoutConstraint.constraintsWithVisualFormat("V:|[\($0.0)]", options: NSLayoutFormatOptions.allZeros, metrics: nil, views: viewsDict)}
            
            self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat(hConstraintStr, options: NSLayoutFormatOptions.allZeros, metrics: nil, views: viewsDict)
                + vConstraits)
        }
        
        required init(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
}




