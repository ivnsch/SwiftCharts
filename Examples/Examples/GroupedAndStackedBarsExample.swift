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
        
        let letterAxisValues = [ChartAxisValueString(order: -1)] +
            groupsData.enumerated().map {index, tuple in ChartAxisValueString(tuple.0, order: index, labelSettings: labelSettings)} +
            [ChartAxisValueString(order: groupsData.count)]
        
        
        let numberAxisValuesGenerator = ChartAxisGeneratorMultiplier(20)
        let numberAxisLabelsGenerator = ChartAxisLabelsGeneratorFunc {scalar in
            return ChartAxisLabel(text: "\(scalar)", settings: labelSettings)
        }
        
        let m1 = ChartAxisModel(firstModelValue: -60, lastModelValue: 100, axisTitleLabels: [ChartAxisLabel(text: "Axis title", settings: horizontal ? labelSettings : labelSettings.defaultVertical())], axisValuesGenerator: numberAxisValuesGenerator, labelsGenerator: numberAxisLabelsGenerator)
        
        let m2 = ChartAxisModel(axisValues: letterAxisValues, axisTitleLabel: ChartAxisLabel(text: "Axis title", settings: horizontal ? labelSettings.defaultVertical() : labelSettings))
        
        let (xModel, yModel) = horizontal ? (m1, m2) : (m2, m1)
        
        
        let frame = ExamplesDefaults.chartFrame(view.bounds)
        let chartFrame = chart?.frame ?? CGRect(x: frame.origin.x, y: frame.origin.y, width: frame.size.width, height: frame.size.height - dirSelectorHeight)
        
        let chartSettings = ExamplesDefaults.chartSettingsWithPanZoom

        let coordsSpace = ChartCoordsSpaceLeftBottomSingleAxis(chartSettings: chartSettings, chartFrame: chartFrame, xModel: xModel, yModel: yModel)
        let (xAxisLayer, yAxisLayer, innerFrame) = (coordsSpace.xAxisLayer, coordsSpace.yAxisLayer, coordsSpace.chartInnerFrame)
        
        let groupsLayer = ChartGroupedStackedBarsLayer(xAxis: xAxisLayer.axis, yAxis: yAxisLayer.axis, groups: groups, horizontal: horizontal, barSpacing: 2, groupSpacing: 30, settings: ChartBarViewSettings(animDuration: 0.5))
        
        let settings = ChartGuideLinesLayerSettings(linesColor: UIColor.black, linesWidth: ExamplesDefaults.guidelinesWidth)
        let guidelinesLayer = ChartGuideLinesLayer(xAxisLayer: xAxisLayer, yAxisLayer: yAxisLayer, axis: horizontal ? .x : .y, settings: settings)
        
        let dummyZeroChartPoint = ChartPoint(x: ChartAxisValueDouble(0), y: ChartAxisValueDouble(0))
        let zeroGuidelineLayer = ChartPointsViewsLayer(xAxis: xAxisLayer.axis, yAxis: yAxisLayer.axis, chartPoints: [dummyZeroChartPoint], viewGenerator: {(chartPointModel, layer, chart) -> UIView? in
            let width: CGFloat = 2
            
            let viewFrame: CGRect = {
                if horizontal {
                    return CGRect(x: chartPointModel.screenLoc.x - width / 2, y: 0, width: width, height: layer.modelLocToScreenLoc(y: -1))
                } else {
                    return CGRect(x: 0, y: chartPointModel.screenLoc.y - width / 2, width: layer.modelLocToScreenLoc(x: Double(groups.count)), height: width)
                }
            }()
            
            let v = UIView(frame: viewFrame)
            v.backgroundColor = UIColor.black
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
    
    
    fileprivate func showChart(horizontal: Bool) {
        self.chart?.clearView()
        
        let chart = barsChart(horizontal: horizontal)
        view.addSubview(chart.view)
        self.chart = chart
    }
    
    override func viewDidLoad() {
        showChart(horizontal: false)
        if let chart = chart {
            let dirSelector = DirSelector(frame: CGRect(x: 0, y: chart.frame.origin.y + chart.frame.size.height, width: view.frame.size.width, height: dirSelectorHeight), controller: self)
            view.addSubview(dirSelector)
        }
    }
    
    class DirSelector: UIView {
        
        let horizontal: UIButton
        let vertical: UIButton
        
        weak var controller: GroupedAndStackedBarsExample?
        
        fileprivate let buttonDirs: [UIButton : Bool]
        
        init(frame: CGRect, controller: GroupedAndStackedBarsExample) {
            
            self.controller = controller
            
            horizontal = UIButton()
            horizontal.setTitle("Horizontal", for: UIControlState())
            vertical = UIButton()
            vertical.setTitle("Vertical", for: UIControlState())
            
            buttonDirs = [horizontal: true, vertical: false]
            
            super.init(frame: frame)
            
            addSubview(horizontal)
            addSubview(vertical)
            
            for button in [horizontal, vertical] {
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
            let views = [horizontal, vertical]
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
            
            addConstraints(NSLayoutConstraint.constraints(withVisualFormat: hConstraintStr, options: NSLayoutFormatOptions(), metrics: nil, views: viewsDict)
                + vConstraits)
        }
        
        required init(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
}
