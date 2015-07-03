//
//  GroupedAndStackedBarsExample.swift
//  Examples
//
//  Created by ischuetz on 20/05/15.
//  Copyright (c) 2015 ivanschuetz. All rights reserved.
//

import UIKit

class GroupedAndStackedBarsExample: UIViewController {

    private var chart: Chart?
    
    private let dirSelectorHeight: CGFloat = 50
    
    private func barsChart(#horizontal: Bool) -> Chart {
        let labelSettings = ChartLabelSettings(font: ExamplesDefaults.labelFont)
        
        let groupsData: [(title: String, bars: [(start: CGFloat, quantities: [CGFloat])])] = [
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
        
        let frameColors = [UIColor.redColor().colorWithAlphaComponent(0.6), UIColor.blueColor().colorWithAlphaComponent(0.6), UIColor.greenColor().colorWithAlphaComponent(0.6)]
        
        let groups: [ChartPointsBarGroup<ChartStackedBarModel>] = Array(enumerate(groupsData)).map {index, entry in
            let constant = ChartAxisValueFloat(CGFloat(index))
            let bars: [ChartStackedBarModel] = Array(enumerate(entry.bars)).map {index, bars in
                let items = Array(enumerate(bars.quantities)).map {index, quantity in
                    ChartStackedBarItemModel(quantity, frameColors[index])
                }
                return ChartStackedBarModel(constant: constant, start: ChartAxisValueFloat(bars.start), items: items)
            }
            return ChartPointsBarGroup(constant: constant, bars: bars)
        }
        
        let (axisValues1: [ChartAxisValue], axisValues2: [ChartAxisValue]) = (
            Array(stride(from: -60, through: 100, by: 20)).map {ChartAxisValueFloat($0, labelSettings: labelSettings)},
            [ChartAxisValueString(order: -1)] +
                Array(enumerate(groupsData)).map {index, tuple in ChartAxisValueString(tuple.0, order: index, labelSettings: labelSettings)} +
                [ChartAxisValueString(order: groupsData.count)]
        )
        let (xValues, yValues) = horizontal ? (axisValues1, axisValues2) : (axisValues2, axisValues1)
        
        let xModel = ChartAxisModel(axisValues: xValues, axisTitleLabel: ChartAxisLabel(text: "Axis title", settings: labelSettings))
        let yModel = ChartAxisModel(axisValues: yValues, axisTitleLabel: ChartAxisLabel(text: "Axis title", settings: labelSettings.defaultVertical()))
        let frame = ExamplesDefaults.chartFrame(self.view.bounds)
        let chartFrame = self.chart?.frame ?? CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, frame.size.height - self.dirSelectorHeight)
        let coordsSpace = ChartCoordsSpaceLeftBottomSingleAxis(chartSettings: ExamplesDefaults.chartSettings, chartFrame: chartFrame, xModel: xModel, yModel: yModel)
        let (xAxis, yAxis, innerFrame) = (coordsSpace.xAxis, coordsSpace.yAxis, coordsSpace.chartInnerFrame)
        
        let groupsLayer = ChartGroupedStackedBarsLayer(xAxis: xAxis, yAxis: yAxis, innerFrame: innerFrame, groups: groups, horizontal: horizontal, barSpacing: 2, groupSpacing: 30, animDuration: 0.5)
        
        var settings = ChartGuideLinesLayerSettings(linesColor: UIColor.blackColor(), linesWidth: ExamplesDefaults.guidelinesWidth)
        let guidelinesLayer = ChartGuideLinesLayer(xAxis: xAxis, yAxis: yAxis, innerFrame: innerFrame, axis: horizontal ? .X : .Y, settings: settings)
        
        let dummyZeroChartPoint = ChartPoint(x: ChartAxisValueFloat(0), y: ChartAxisValueFloat(0))
        let zeroGuidelineLayer = ChartPointsViewsLayer(xAxis: xAxis, yAxis: yAxis, innerFrame: innerFrame, chartPoints: [dummyZeroChartPoint], viewGenerator: {(chartPointModel, layer, chart) -> UIView? in
            let width: CGFloat = 2
            
            let viewFrame: CGRect = {
                if horizontal {
                    return CGRectMake(chartPointModel.screenLoc.x - width / 2, innerFrame.origin.y, width, innerFrame.size.height)
                } else {
                    return CGRectMake(innerFrame.origin.x, chartPointModel.screenLoc.y - width / 2, innerFrame.size.width, width)
                }
            }()
            
            let v = UIView(frame: viewFrame)
            v.backgroundColor = UIColor.blackColor()
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
    
    
    private func showChart(#horizontal: Bool) {
        self.chart?.clearView()
        
        let chart = self.barsChart(horizontal: horizontal)
        self.view.addSubview(chart.view)
        self.chart = chart
    }
    
    override func viewDidLoad() {
        self.showChart(horizontal: false)
        if let chart = self.chart {
            let dirSelector = DirSelector(frame: CGRectMake(0, chart.frame.origin.y + chart.frame.size.height, self.view.frame.size.width, self.dirSelectorHeight), controller: self)
            self.view.addSubview(dirSelector)
        }
    }
    
    class DirSelector: UIView {
        
        let horizontal: UIButton
        let vertical: UIButton
        
        weak var controller: GroupedAndStackedBarsExample?
        
        private let buttonDirs: [UIButton : Bool]
        
        init(frame: CGRect, controller: GroupedAndStackedBarsExample) {
            
            self.controller = controller
            
            self.horizontal = UIButton()
            self.horizontal.setTitle("Horizontal", forState: .Normal)
            self.vertical = UIButton()
            self.vertical.setTitle("Vertical", forState: .Normal)
            
            self.buttonDirs = [self.horizontal : true, self.vertical : false]
            
            super.init(frame: frame)
            
            self.addSubview(self.horizontal)
            self.addSubview(self.vertical)
            
            for button in [self.horizontal, self.vertical] {
                button.titleLabel?.font = ExamplesDefaults.fontWithSize(14)
                button.setTitleColor(UIColor.blueColor(), forState: .Normal)
                button.addTarget(self, action: "buttonTapped:", forControlEvents: .TouchUpInside)
            }
        }
        
        func buttonTapped(sender: UIButton) {
            let horizontal = sender == self.horizontal ? true : false
            controller?.showChart(horizontal: horizontal)
        }
        
        override func didMoveToSuperview() {
            let views = [self.horizontal, self.vertical]
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
