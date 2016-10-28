//
//  GroupedBarsExample.swift
//  Examples
//
//  Created by ischuetz on 19/05/15.
//  Copyright (c) 2015 ivanschuetz. All rights reserved.
//

import UIKit
import SwiftCharts

class GroupedBarsExample: UIViewController {

    fileprivate var chart: Chart?

    fileprivate let dirSelectorHeight: CGFloat = 50

    fileprivate func barsChart(horizontal: Bool) -> Chart {
        let labelSettings = ChartLabelSettings(font: ExamplesDefaults.labelFont)
        
        let groupsData: [(title: String, [(min: Double, max: Double)])] = [
            ("A", [
                (0, 40),
                (0, 50),
                (0, 35)
                ]),
            ("B", [
                (0, 20),
                (0, 30),
                (0, 25)
                ]),
            ("C", [
                (0, 30),
                (0, 50),
                (0, 5)
                ]),
            ("D", [
                (0, 55),
                (0, 30),
                (0, 25)
                ])
        ]
        
        let groupColors = [UIColor.red.withAlphaComponent(0.6), UIColor.blue.withAlphaComponent(0.6), UIColor.green.withAlphaComponent(0.6)]
        
        let groups: [ChartPointsBarGroup] = groupsData.enumerated().map {index, entry in
            let constant = ChartAxisValueDouble(index)
            let bars = entry.1.enumerated().map {index, tuple in
                ChartBarModel(constant: constant, axisValue1: ChartAxisValueDouble(tuple.min), axisValue2: ChartAxisValueDouble(tuple.max), bgColor: groupColors[index])
            }
            return ChartPointsBarGroup(constant: constant, bars: bars)
        }
        
        let (axisValues1, axisValues2): ([ChartAxisValue], [ChartAxisValue]) = (
            stride(from: 0, through: 60, by: 5).map {ChartAxisValueDouble(Double($0), labelSettings: labelSettings)},
            [ChartAxisValueString(order: -1)] +
                groupsData.enumerated().map {index, tuple in ChartAxisValueString(tuple.0, order: index, labelSettings: labelSettings)} +
                [ChartAxisValueString(order: groupsData.count)]
        )
        let (xValues, yValues) = horizontal ? (axisValues1, axisValues2) : (axisValues2, axisValues1)
        
        let xModel = ChartAxisModel(axisValues: xValues, axisTitleLabel: ChartAxisLabel(text: "Axis title", settings: labelSettings))
        let yModel = ChartAxisModel(axisValues: yValues, axisTitleLabel: ChartAxisLabel(text: "Axis title", settings: labelSettings.defaultVertical()))
        let frame = ExamplesDefaults.chartFrame(view.bounds)
        let chartFrame = chart?.frame ?? CGRect(x: frame.origin.x, y: frame.origin.y, width: frame.size.width, height: frame.size.height - dirSelectorHeight)
        
        let chartSettings = ExamplesDefaults.chartSettingsWithPanZoom

        let coordsSpace = ChartCoordsSpaceLeftBottomSingleAxis(chartSettings: chartSettings, chartFrame: chartFrame, xModel: xModel, yModel: yModel)
        let (xAxisLayer, yAxisLayer, innerFrame) = (coordsSpace.xAxisLayer, coordsSpace.yAxisLayer, coordsSpace.chartInnerFrame)
        
        let barViewSettings = ChartBarViewSettings(animDuration: 0.5, selectionViewUpdater: ChartViewSelectorBrightness(selectedFactor: 0.5))
        
        let groupsLayer = ChartGroupedPlainBarsLayer(xAxis: xAxisLayer.axis, yAxis: yAxisLayer.axis, groups: groups, horizontal: horizontal, barSpacing: 2, groupSpacing: 25, settings: barViewSettings, tapHandler: { tappedGroupBar /*ChartTappedGroupBar*/ in
            
            let barPoint = horizontal ? CGPoint(x: tappedGroupBar.tappedBar.view.frame.maxX, y: tappedGroupBar.tappedBar.view.frame.midY) : CGPoint(x: tappedGroupBar.tappedBar.view.frame.midX, y: tappedGroupBar.tappedBar.view.frame.minY)
            
            guard let chart = self.chart, let chartViewPoint = tappedGroupBar.layer.contentToGlobalCoordinates(barPoint) else {return}
            
            let viewPoint = CGPoint(x: chartViewPoint.x, y: chartViewPoint.y)
            
            let infoBubble = InfoBubble(point: viewPoint, preferredSize: CGSize(width: 50, height: 40), superview: self.chart!.view, text: tappedGroupBar.tappedBar.model.axisValue2.description, font: ExamplesDefaults.labelFont, textColor: UIColor.white, bgColor: UIColor.black, horizontal: horizontal)

            let anchor: CGPoint = {
                switch (horizontal, infoBubble.inverted(chart.view)) {
                case (true, true): return CGPoint(x: 1, y: 0.5)
                case (true, false): return CGPoint(x: 0, y: 0.5)
                case (false, true): return CGPoint(x: 0.5, y: 0)
                case (false, false): return CGPoint(x: 0.5, y: 1)
                }
            }()
            
            let animatorsSettings = ChartViewAnimatorsSettings(animInitSpringVelocity: 5)
            let animators = ChartViewAnimators(view: infoBubble, animators: ChartViewGrowAnimator(anchor: anchor), settings: animatorsSettings, invertSettings: animatorsSettings.withoutDamping(), onFinishInverts: {
                infoBubble.removeFromSuperview()
            })
            
            chart.view.addSubview(infoBubble)
            
            infoBubble.tapHandler = {
                animators.invert()
            }
            
            animators.animate()
        })
        
        let guidelinesSettings = ChartGuideLinesLayerSettings(linesColor: UIColor.black, linesWidth: ExamplesDefaults.guidelinesWidth)
        let guidelinesLayer = ChartGuideLinesLayer(xAxisLayer: xAxisLayer, yAxisLayer: yAxisLayer, axis: horizontal ? .x : .y, settings: guidelinesSettings)
        
        return Chart(
            frame: chartFrame,
            innerFrame: innerFrame,
            settings: chartSettings,
            layers: [
                xAxisLayer,
                yAxisLayer,
                guidelinesLayer,
                groupsLayer
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
        
        weak var controller: GroupedBarsExample?
        
        fileprivate let buttonDirs: [UIButton : Bool]
        
        init(frame: CGRect, controller: GroupedBarsExample) {
            
            self.controller = controller
            
            horizontal = UIButton()
            horizontal.setTitle("Horizontal", for: UIControlState())
            vertical = UIButton()
            vertical.setTitle("Vertical", for: UIControlState())
            
            buttonDirs = [horizontal : true, vertical : false]
            
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
