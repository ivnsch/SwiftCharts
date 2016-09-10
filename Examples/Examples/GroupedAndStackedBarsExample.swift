//
//  GroupedAndStackedBarsExample.swift
//  Examples
//
//  Created by ischuetz on 20/05/15.
//  Copyright (c) 2015 ivanschuetz. All rights reserved.
//

import UIKit
import SwiftCharts

class GroupedAndStackedBarsExample: UIViewController {

    fileprivate var chart: Chart?
    
    fileprivate let dirSelectorHeight: CGFloat = 50
    
    fileprivate func barsChart(horizontal: Bool) -> Chart {
        let labelSettings = ChartLabelSettings(font: ExamplesDefaults.labelFont)
        
        let groupsData: [(title: String, bars: [(start: Double, quantities: [Double])])] = [
            ("A", [
                (0,
                    [-20, -5, -10]
                ),
                (0,
                    [10, 20, 30]
                ),
                (0,
                    [30, 14, 5]
                )
            ]),
            ("B", [
                (0,
                    [-10, -15, -5]
                ),
                (0,
                    [30, 25, 40]
                ),
                (0,
                    [25, 40, 10]
                )
            ]),
            ("C", [
                (0,
                    [-15, -30, -10]
                ),
                (0,
                    [-10, -10, -5]
                ),
                (0,
                    [15, 30, 10]
                )
            ]),
            ("D", [
                (0,
                    [-20, -10, -10]
                ),
                (0,
                    [30, 15, 27]
                ),
                (0,
                    [8, 10, 25]
                )
            ])
        ]
        
        let frameColors = [UIColor.red.withAlphaComponent(0.6), UIColor.blue.withAlphaComponent(0.6), UIColor.green.withAlphaComponent(0.6)]
        
        let groups: [ChartPointsBarGroup<ChartStackedBarModel>] = groupsData.enumerated().map {index, entry in
            let constant = ChartAxisValueDouble(Double(index))
            let bars: [ChartStackedBarModel] = entry.bars.enumerated().map {index, bars in
                let items = bars.quantities.enumerated().map {index, quantity in
                    ChartStackedBarItemModel(quantity, frameColors[index])
                }
                return ChartStackedBarModel(constant: constant, start: ChartAxisValueDouble(bars.start), items: items)
            }
            return ChartPointsBarGroup(constant: constant, bars: bars)
        }
        
        let (axisValues1, axisValues2): ([ChartAxisValue], [ChartAxisValue]) = (
            stride(from: (-60), through: 100, by: 20).map {ChartAxisValueDouble(Double($0), labelSettings: labelSettings)},
            [ChartAxisValueString(order: -1)] +
                groupsData.enumerated().map {index, tuple in ChartAxisValueString(tuple.0, order: index, labelSettings: labelSettings)} +
                [ChartAxisValueString(order: groupsData.count)]
        )
        let (xValues, yValues) = horizontal ? (axisValues1, axisValues2) : (axisValues2, axisValues1)
        
        let xModel = ChartAxisModel(axisValues: xValues, axisTitleLabel: ChartAxisLabel(text: "Axis title", settings: labelSettings))
        let yModel = ChartAxisModel(axisValues: yValues, axisTitleLabel: ChartAxisLabel(text: "Axis title", settings: labelSettings.defaultVertical()))
        let frame = ExamplesDefaults.chartFrame(self.view.bounds)
        let chartFrame = self.chart?.frame ?? CGRect(x: frame.origin.x, y: frame.origin.y, width: frame.size.width, height: frame.size.height - self.dirSelectorHeight)
        let coordsSpace = ChartCoordsSpaceLeftBottomSingleAxis(chartSettings: ExamplesDefaults.chartSettings, chartFrame: chartFrame, xModel: xModel, yModel: yModel)
        let (xAxis, yAxis, innerFrame) = (coordsSpace.xAxis, coordsSpace.yAxis, coordsSpace.chartInnerFrame)
        
        let groupsLayer = ChartGroupedStackedBarsLayer(xAxis: xAxis, yAxis: yAxis, innerFrame: innerFrame, groups: groups, horizontal: horizontal, barSpacing: 2, groupSpacing: 30, animDuration: 0.5)
        
        let settings = ChartGuideLinesLayerSettings(linesColor: UIColor.black, linesWidth: ExamplesDefaults.guidelinesWidth)
        let guidelinesLayer = ChartGuideLinesLayer(xAxis: xAxis, yAxis: yAxis, innerFrame: innerFrame, axis: horizontal ? .x : .y, settings: settings)
        
        let dummyZeroChartPoint = ChartPoint(x: ChartAxisValueDouble(0), y: ChartAxisValueDouble(0))
        let zeroGuidelineLayer = ChartPointsViewsLayer(xAxis: xAxis, yAxis: yAxis, innerFrame: innerFrame, chartPoints: [dummyZeroChartPoint], viewGenerator: {(chartPointModel, layer, chart) -> UIView? in
            let width: CGFloat = 2
            
            let viewFrame: CGRect = {
                if horizontal {
                    return CGRect(x: chartPointModel.screenLoc.x - width / 2, y: innerFrame.origin.y, width: width, height: innerFrame.size.height)
                } else {
                    return CGRect(x: innerFrame.origin.x, y: chartPointModel.screenLoc.y - width / 2, width: innerFrame.size.width, height: width)
                }
            }()
            
            let v = UIView(frame: viewFrame)
            v.backgroundColor = UIColor.black
            return v
        })
        
        return Chart(
            frame: chartFrame,
            layers: [
                xAxis,
                yAxis,
                guidelinesLayer,
                groupsLayer,
                zeroGuidelineLayer
            ]
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
            let dirSelector = DirSelector(frame: CGRect(x: 0, y: chart.frame.origin.y + chart.frame.size.height, width: self.view.frame.size.width, height: self.dirSelectorHeight), controller: self)
            self.view.addSubview(dirSelector)
        }
    }
    
    class DirSelector: UIView {
        
        let horizontal: UIButton
        let vertical: UIButton
        
        weak var controller: GroupedAndStackedBarsExample?
        
        fileprivate let buttonDirs: [UIButton : Bool]
        
        init(frame: CGRect, controller: GroupedAndStackedBarsExample) {
            
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
