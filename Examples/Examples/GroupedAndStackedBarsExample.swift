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

    private var chart: Chart?
    
    private let dirSelectorHeight: CGFloat = 50
    
    private func barsChart(horizontal horizontal: Bool) -> Chart {
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
        
        let frameColors = [UIColor.redColor().colorWithAlphaComponent(0.6), UIColor.blueColor().colorWithAlphaComponent(0.6), UIColor.greenColor().colorWithAlphaComponent(0.6)]
        
        let groups: [ChartPointsBarGroup<ChartStackedBarModel>] = groupsData.enumerate().map {index, entry in
            let constant = ChartAxisValueDouble(Double(index))
            let bars: [ChartStackedBarModel] = entry.bars.enumerate().map {index, bars in
                let items = bars.quantities.enumerate().map {index, quantity in
                    ChartStackedBarItemModel(quantity, frameColors[index])
                }
                return ChartStackedBarModel(constant: constant, start: ChartAxisValueDouble(bars.start), items: items)
            }
            return ChartPointsBarGroup(constant: constant, bars: bars)
        }
        
        let letterAxisValues = [ChartAxisValueString(order: -1)] +
            groupsData.enumerate().map {index, tuple in ChartAxisValueString(tuple.0, order: index, labelSettings: labelSettings)} +
            [ChartAxisValueString(order: groupsData.count)]
        
        
        let numberAxisValuesGenerator = ChartAxisGeneratorMultiplier(20)
        let numberAxisLabelsGenerator = ChartAxisLabelsGeneratorFunc {scalar in
            return ChartAxisLabel(text: "\(scalar)", settings: labelSettings)
        }
        
        let m1 = ChartAxisModel(firstModelValue: -60, lastModelValue: 100, axisTitleLabels: [ChartAxisLabel(text: "Axis title", settings: horizontal ? labelSettings : labelSettings.defaultVertical())], axisValuesGenerator: numberAxisValuesGenerator, labelsGenerator: numberAxisLabelsGenerator)
        
        let m2 = ChartAxisModel(axisValues: letterAxisValues, axisTitleLabel: ChartAxisLabel(text: "Axis title", settings: horizontal ? labelSettings.defaultVertical() : labelSettings))
        
        let (xModel, yModel) = horizontal ? (m1, m2) : (m2, m1)
        
        
        let frame = ExamplesDefaults.chartFrame(self.view.bounds)
        let chartFrame = self.chart?.frame ?? CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, frame.size.height - self.dirSelectorHeight)
        
        let chartSettings = ExamplesDefaults.chartSettingsWithPanZoom

        let coordsSpace = ChartCoordsSpaceLeftBottomSingleAxis(chartSettings: chartSettings, chartFrame: chartFrame, xModel: xModel, yModel: yModel)
        let (xAxisLayer, yAxisLayer, innerFrame) = (coordsSpace.xAxisLayer, coordsSpace.yAxisLayer, coordsSpace.chartInnerFrame)
        
        let groupsLayer = ChartGroupedStackedBarsLayer(xAxis: xAxisLayer.axis, yAxis: yAxisLayer.axis, groups: groups, horizontal: horizontal, barSpacing: 2, groupSpacing: 30, animDuration: 0.5)
        
        let settings = ChartGuideLinesLayerSettings(linesColor: UIColor.blackColor(), linesWidth: ExamplesDefaults.guidelinesWidth)
        let guidelinesLayer = ChartGuideLinesLayer(xAxisLayer: xAxisLayer, yAxisLayer: yAxisLayer, axis: horizontal ? .X : .Y, settings: settings)
        
        let dummyZeroChartPoint = ChartPoint(x: ChartAxisValueDouble(0), y: ChartAxisValueDouble(0))
        let zeroGuidelineLayer = ChartPointsViewsLayer(xAxis: xAxisLayer.axis, yAxis: yAxisLayer.axis, chartPoints: [dummyZeroChartPoint], viewGenerator: {(chartPointModel, layer, chart, isTransform: Bool) -> UIView? in
            let width: CGFloat = 2
            
            let viewFrame: CGRect = {
                if horizontal {
                    return CGRectMake(chartPointModel.screenLoc.x - width / 2, chart.contentView.frame.origin.y, width, chart.contentView.frame.size.height)
                } else {
                    return CGRectMake(0, chartPointModel.screenLoc.y - width / 2, chart.contentView.frame.size.width, width)
                }
            }()
            
            let v = UIView(frame: viewFrame)
            v.backgroundColor = UIColor.blackColor()
            return v
        })
        
        return Chart(
            frame: chartFrame,
            innerFrame: innerFrame,
            settings: chartSettings,
            layers: [
                xAxisLayer,
                yAxisLayer,
                guidelinesLayer,
                groupsLayer,
                zeroGuidelineLayer
            ]
        )
    }
    
    
    private func showChart(horizontal horizontal: Bool) {
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
                button.addTarget(self, action: #selector(DirSelector.buttonTapped(_:)), forControlEvents: .TouchUpInside)
            }
        }
        
        func buttonTapped(sender: UIButton) {
            let horizontal = sender == self.horizontal ? true : false
            controller?.showChart(horizontal: horizontal)
        }
        
        override func didMoveToSuperview() {
            let views = [self.horizontal, self.vertical]
            for v in views {
                v.translatesAutoresizingMaskIntoConstraints = false
            }
            
            let namedViews = views.enumerate().map{index, view in
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
            
            let vConstraits = namedViews.flatMap {NSLayoutConstraint.constraintsWithVisualFormat("V:|[\($0.0)]", options: NSLayoutFormatOptions(), metrics: nil, views: viewsDict)}
            
            self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat(hConstraintStr, options: NSLayoutFormatOptions(), metrics: nil, views: viewsDict)
                + vConstraits)
        }
        
        required init(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
}
