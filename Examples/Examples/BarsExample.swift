//
//  BarsExample.swift
//  SwiftCharts
//
//  Created by ischuetz on 04/05/15.
//  Copyright (c) 2015 ivanschuetz. All rights reserved.
//

import UIKit
import SwiftCharts

// This example uses a normal view generator to create bars. This allows a high degree of customization at view level, since any UIView can be used.
// Alternatively it's possible to use ChartBarsLayer (see e.g. implementation of BarsChart for a simple example), which provides more ready to use, bar-specific functionality, but is accordingly more constrained.
class BarsExample: UIViewController {
    
    fileprivate var chart: Chart?
    
    let sideSelectorHeight: CGFloat = 50
    
    fileprivate func barsChart(horizontal: Bool) -> Chart {
        let tuplesXY = [(2, 8), (4, 9), (6, 10), (8, 12), (12, 17)]

        func reverseTuples(_ tuples: [(Int, Int)]) -> [(Int, Int)] {
            return tuples.map{($0.1, $0.0)}
        }
        
        let chartPoints = (horizontal ? reverseTuples(tuplesXY) : tuplesXY).map{ChartPoint(x: ChartAxisValueInt($0.0), y: ChartAxisValueInt($0.1))}
        
        let labelSettings = ChartLabelSettings(font: ExamplesDefaults.labelFont)
        
        let (axisValues1, axisValues2) = (
            stride(from: 0, through: 20, by: 2).map {ChartAxisValueDouble(Double($0), labelSettings: labelSettings)},
            stride(from: 0, through: 14, by: 2).map {ChartAxisValueDouble(Double($0), labelSettings: labelSettings)}
        )
        let (xValues, yValues) = horizontal ? (axisValues1, axisValues2) : (axisValues2, axisValues1)
        
        let xModel = ChartAxisModel(axisValues: xValues, axisTitleLabel: ChartAxisLabel(text: "Axis title", settings: labelSettings))
        let yModel = ChartAxisModel(axisValues: yValues, axisTitleLabel: ChartAxisLabel(text: "Axis title", settings: labelSettings.defaultVertical()))
        
        let barViewGenerator = {(chartPointModel: ChartPointLayerModel, layer: ChartPointsViewsLayer, chart: Chart) -> UIView? in
            let bottomLeft = CGPoint(x: layer.innerFrame.origin.x, y: layer.innerFrame.origin.y + layer.innerFrame.height)
            
            let barWidth: CGFloat = Env.iPad ? 60 : 30
            
            let (p1, p2): (CGPoint, CGPoint) = {
                if horizontal {
                    return (CGPoint(x: bottomLeft.x, y: chartPointModel.screenLoc.y), CGPoint(x: chartPointModel.screenLoc.x, y: chartPointModel.screenLoc.y))
                } else {
                    return (CGPoint(x: chartPointModel.screenLoc.x, y: bottomLeft.y), CGPoint(x: chartPointModel.screenLoc.x, y: chartPointModel.screenLoc.y))
                }
            }()
            return ChartPointViewBar(p1: p1, p2: p2, width: barWidth, bgColor: UIColor.blue.withAlphaComponent(0.6))
        }
        
        let frame = ExamplesDefaults.chartFrame(self.view.bounds)
        let chartFrame = self.chart?.frame ?? CGRect(x: frame.origin.x, y: frame.origin.y, width: frame.size.width, height: frame.size.height - sideSelectorHeight)
        let coordsSpace = ChartCoordsSpaceLeftBottomSingleAxis(chartSettings: ExamplesDefaults.chartSettings, chartFrame: chartFrame, xModel: xModel, yModel: yModel)
        let (xAxis, yAxis, innerFrame) = (coordsSpace.xAxis, coordsSpace.yAxis, coordsSpace.chartInnerFrame)
        
        let chartPointsLayer = ChartPointsViewsLayer(xAxis: xAxis, yAxis: yAxis, innerFrame: innerFrame, chartPoints: chartPoints, viewGenerator: barViewGenerator)
        
        let settings = ChartGuideLinesDottedLayerSettings(linesColor: UIColor.black, linesWidth: ExamplesDefaults.guidelinesWidth)
        let guidelinesLayer = ChartGuideLinesDottedLayer(xAxis: xAxis, yAxis: yAxis, innerFrame: innerFrame, settings: settings)
        
        return Chart(
            frame: chartFrame,
            layers: [
                xAxis,
                yAxis,
                guidelinesLayer,
                chartPointsLayer]
        )
    }
    
    fileprivate func showChart(horizontal: Bool) {
        self.chart?.clearView()
        
        let chart = self.barsChart(horizontal: horizontal)
        self.view.addSubview(chart.view)
        self.chart = chart
    }
    
    override func viewDidLoad() {
        self.showChart(horizontal: false)
        if let chart = self.chart {
            let sideSelector = DirSelector(frame: CGRect(x: 0, y: chart.frame.origin.y + chart.frame.size.height, width: self.view.frame.size.width, height: self.sideSelectorHeight), controller: self)
            self.view.addSubview(sideSelector)
        }
    }
    
    
    class DirSelector: UIView {
        
        let horizontal: UIButton
        let vertical: UIButton
        
        weak var controller: BarsExample?
        
        fileprivate let buttonDirs: [UIButton : Bool]
        
        init(frame: CGRect, controller: BarsExample) {
            
            self.controller = controller
            
            self.horizontal = UIButton()
            self.horizontal.setTitle("Horizontal", for: UIControlState())
            self.vertical = UIButton()
            self.vertical.setTitle("Vertical", for: UIControlState())
            
            self.buttonDirs = [self.horizontal : true, self.vertical : false]
            
            super.init(frame: frame)
            
            self.addSubview(self.horizontal)
            self.addSubview(self.vertical)
            
            for button in [self.horizontal, self.vertical] {
                button.titleLabel?.font = ExamplesDefaults.fontWithSize(14)
                button.setTitleColor(UIColor.blue, for: UIControlState())
                button.addTarget(self, action: #selector(DirSelector.buttonTapped(_:)), for: .touchUpInside)
            }
        }
        
        func buttonTapped(_ sender: UIButton) {
            let horizontal = sender == self.horizontal ? true : false
            controller?.showChart(horizontal: horizontal)
        }
        
        override func didMoveToSuperview() {
            let views = [self.horizontal, self.vertical]
            for v in views {
                v.translatesAutoresizingMaskIntoConstraints = false
            }
            
            let namedViews = views.enumerated().map{index, view in
                ("v\(index)", view)
            }
            
            var viewsDict = Dictionary<String, UIView>()
            for namedView in namedViews {
                viewsDict[namedView.0] = namedView.1
            }
            
            let buttonsSpace: CGFloat = Env.iPad ? 20 : 10
            
            let hConstraintStr = namedViews.reduce("H:|") {str, tuple in
                "\(str)-(\(buttonsSpace))-[\(tuple.0)]"
            }
            
            let vConstraits = namedViews.flatMap {NSLayoutConstraint.constraints(withVisualFormat: "V:|[\($0.0)]", options: NSLayoutFormatOptions(), metrics: nil, views: viewsDict)}
            
            self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: hConstraintStr, options: NSLayoutFormatOptions(), metrics: nil, views: viewsDict)
                + vConstraits)
        }
        
        required init(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
}




