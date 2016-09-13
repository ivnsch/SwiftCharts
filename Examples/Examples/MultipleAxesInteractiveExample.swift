//
//  MultipleAxesInteractiveExample.swift
//  SwiftCharts
//
//  Created by ischuetz on 04/05/15.
//  Copyright (c) 2015 ivanschuetz. All rights reserved.
//

import UIKit
import SwiftCharts

class MultipleAxesInteractiveExample: UIViewController {

    fileprivate var chart: Chart?

    let bgColors = [UIColor.red, UIColor.blue, UIColor(red: 0, green: 0.7, blue: 0, alpha: 1), UIColor(red: 1, green: 0.5, blue: 0, alpha: 1)]

    fileprivate var showGuides: Bool = false
    fileprivate var selectedLayersFlags = [true, true, true, true]
    
    fileprivate let chartPoints0: [ChartPoint]
    fileprivate let chartPoints1: [ChartPoint]
    fileprivate let chartPoints2: [ChartPoint]
    fileprivate let chartPoints3: [ChartPoint]

    fileprivate var viewFrame: CGRect!
    fileprivate var chartInnerFrame: CGRect!
    
    fileprivate var yLowAxes: [ChartAxisLayer]!
    fileprivate var yHighAxes: [ChartAxisLayer]!
    fileprivate var xLowAxes: [ChartAxisLayer]!
    fileprivate var xHighAxes: [ChartAxisLayer]!
    
    fileprivate var guideLinesLayer0: ChartLayer!
    fileprivate var guideLinesLayer1: ChartLayer!
    fileprivate var guideLinesLayer2: ChartLayer!
    fileprivate var guideLinesLayer3: ChartLayer!
    
    fileprivate let selectionViewH: CGFloat = 100
    fileprivate let showGuidesViewH: CGFloat = 50
    
    init() {
        let labelSettings = ChartLabelSettings(font: ExamplesDefaults.labelFontSmall)
        
        func createChartPoint(x: Double, y: Double, labelColor: UIColor) -> ChartPoint {
            let labelSettings = ChartLabelSettings(font: ExamplesDefaults.labelFontSmall, fontColor: labelColor)
            return ChartPoint(x: ChartAxisValueDouble(x, labelSettings: labelSettings), y: ChartAxisValueDouble(y, labelSettings: labelSettings))
        }
        
        func createChartPoints0(_ color: UIColor) -> [ChartPoint] {
            return [
                createChartPoint(x: 0, y: 0, labelColor: color),
                createChartPoint(x: 2, y: 2, labelColor: color),
                createChartPoint(x: 5, y: 2, labelColor: color),
                createChartPoint(x: 8, y: 11, labelColor: color),
                createChartPoint(x: 10, y: 2, labelColor: color),
                createChartPoint(x: 12, y: 3, labelColor: color),
                createChartPoint(x: 16, y: 22, labelColor: color),
                createChartPoint(x: 20, y: 5, labelColor: color)
            ]
        }
        
        func createChartPoints1(_ color: UIColor) -> [ChartPoint] {
            return [
                createChartPoint(x: 0, y: 7, labelColor: color),
                createChartPoint(x: 1, y: 10, labelColor: color),
                createChartPoint(x: 3, y: 9, labelColor: color),
                createChartPoint(x: 9, y: 2, labelColor: color),
                createChartPoint(x: 10, y: -5, labelColor: color),
                createChartPoint(x: 13, y: -12, labelColor: color)
            ]
        }
        
        func createChartPoints2(_ color: UIColor) -> [ChartPoint] {
            return [
                createChartPoint(x: -200, y: -10, labelColor: color),
                createChartPoint(x: -160, y: -30, labelColor: color),
                createChartPoint(x: -110, y: -10, labelColor: color),
                createChartPoint(x: -40, y: -80, labelColor: color),
                createChartPoint(x: -10, y: -50, labelColor: color),
                createChartPoint(x: 20, y: 10, labelColor: color)
            ]
        }
        
        func createChartPoints3(_ color: UIColor) -> [ChartPoint] {
            return [
                createChartPoint(x: 10000, y: 70, labelColor: color),
                createChartPoint(x: 20000, y: 100, labelColor: color),
                createChartPoint(x: 30000, y: 160, labelColor: color)
            ]
        }
        
        self.chartPoints0 = createChartPoints0(bgColors[0])
        self.chartPoints1 = createChartPoints1(bgColors[1])
        self.chartPoints2 = createChartPoints2(bgColors[2])
        self.chartPoints3 = createChartPoints3(bgColors[3])

        
        super.init(nibName: nil, bundle: nil)

    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let xValues0 = self.chartPoints0.map{$0.x}
        let xValues1 = self.chartPoints1.map{$0.x}
        let xValues2 = self.chartPoints2.map{$0.x}
        let xValues3 = self.chartPoints3.map{$0.x}
        
        let chartSettings = ExamplesDefaults.chartSettings
        
        let top: CGFloat = 80
        
        self.viewFrame = CGRect(x: 0, y: top, width: self.view.frame.size.width, height: self.view.frame.size.height - selectionViewH - showGuidesViewH - top - 10)
        
        let yValues0 = ChartAxisValuesGenerator.generateYAxisValuesWithChartPoints(self.chartPoints0, minSegmentCount: 10, maxSegmentCount: 20, multiple: 2, axisValueGenerator: {ChartAxisValueDouble($0, labelSettings: ChartLabelSettings(font: ExamplesDefaults.labelFontSmall, fontColor: self.bgColors[0]))}, addPaddingSegmentIfEdge: false)
        
        let yValues1 = ChartAxisValuesGenerator.generateYAxisValuesWithChartPoints(self.chartPoints1, minSegmentCount: 10, maxSegmentCount: 20, multiple: 2, axisValueGenerator: {ChartAxisValueDouble($0, labelSettings: ChartLabelSettings(font: ExamplesDefaults.labelFontSmall, fontColor: self.bgColors[1]))}, addPaddingSegmentIfEdge: false)
        
        let yValues2 = ChartAxisValuesGenerator.generateYAxisValuesWithChartPoints(self.chartPoints2, minSegmentCount: 10, maxSegmentCount: 20, multiple: 2, axisValueGenerator: {ChartAxisValueDouble($0, labelSettings: ChartLabelSettings(font: ExamplesDefaults.labelFontSmall, fontColor: self.bgColors[2]))}, addPaddingSegmentIfEdge: false)
        
        let yValues3 = ChartAxisValuesGenerator.generateYAxisValuesWithChartPoints(self.chartPoints3, minSegmentCount: 10, maxSegmentCount: 20, multiple: 2, axisValueGenerator: {ChartAxisValueDouble($0, labelSettings: ChartLabelSettings(font: ExamplesDefaults.labelFontSmall, fontColor: self.bgColors[3]))}, addPaddingSegmentIfEdge: false)
        
        let axisTitleFont = ExamplesDefaults.labelFontSmall
        
        let yLowModels: [ChartAxisModel] = [
            ChartAxisModel(axisValues: yValues1, lineColor: self.bgColors[1], axisTitleLabels: [ChartAxisLabel(text: "Axis title", settings: ChartLabelSettings(font: axisTitleFont, fontColor: self.bgColors[1]).defaultVertical())]),
            ChartAxisModel(axisValues: yValues0, lineColor: self.bgColors[0], axisTitleLabels: [ChartAxisLabel(text: "Axis title", settings: ChartLabelSettings(font: axisTitleFont, fontColor: self.bgColors[0]).defaultVertical())])
        ]
        let yHighModels: [ChartAxisModel] = [
            ChartAxisModel(axisValues: yValues2, lineColor: self.bgColors[2], axisTitleLabels: [ChartAxisLabel(text: "Axis title", settings: ChartLabelSettings(font: axisTitleFont, fontColor: self.bgColors[2]).defaultVertical())]),
            ChartAxisModel(axisValues: yValues3, lineColor: self.bgColors[3], axisTitleLabels: [ChartAxisLabel(text: "Axis title", settings: ChartLabelSettings(font: axisTitleFont, fontColor: self.bgColors[3]).defaultVertical())])
        ]
        let xLowModels: [ChartAxisModel] = [
            ChartAxisModel(axisValues: xValues0, lineColor: self.bgColors[0], axisTitleLabels: [ChartAxisLabel(text: "Axis title", settings: ChartLabelSettings(font: axisTitleFont, fontColor: self.bgColors[0]))]),
            ChartAxisModel(axisValues: xValues1, lineColor: self.bgColors[1], axisTitleLabels: [ChartAxisLabel(text: "Axis title", settings: ChartLabelSettings(font: axisTitleFont, fontColor: self.bgColors[1]))])
        ]
        let xHighModels: [ChartAxisModel] = [
            ChartAxisModel(axisValues: xValues3, lineColor: self.bgColors[3], axisTitleLabels: [ChartAxisLabel(text: "Axis title", settings: ChartLabelSettings(font: axisTitleFont, fontColor: self.bgColors[3]))]),
            ChartAxisModel(axisValues: xValues2, lineColor: self.bgColors[2], axisTitleLabels: [ChartAxisLabel(text: "Axis title", settings: ChartLabelSettings(font: axisTitleFont, fontColor: self.bgColors[2]))])
        ]
        
        // calculate coords space in the background to keep UI smooth
        DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.default).async {
            
            let coordsSpace = ChartCoordsSpace(chartSettings: chartSettings, chartSize: self.viewFrame.size, yLowModels: yLowModels, yHighModels: yHighModels, xLowModels: xLowModels, xHighModels: xHighModels)
            
            DispatchQueue.main.async {
                
                self.chartInnerFrame = coordsSpace.chartInnerFrame
                
                // create axes
                self.yLowAxes = coordsSpace.yLowAxes
                self.yHighAxes = coordsSpace.yHighAxes
                self.xLowAxes = coordsSpace.xLowAxes
                self.xHighAxes = coordsSpace.xHighAxes
                
                // create layers with references to axes
                let guideLinesLayer0Settings = ChartGuideLinesDottedLayerSettings(linesColor: self.bgColors[0], linesWidth: ExamplesDefaults.guidelinesWidth)
                self.guideLinesLayer0 = ChartGuideLinesDottedLayer(xAxis: self.xLowAxes[0], yAxis: self.yLowAxes[1], innerFrame: self.chartInnerFrame, settings: guideLinesLayer0Settings)
                let guideLinesLayer1Settings = ChartGuideLinesDottedLayerSettings(linesColor: self.bgColors[1], linesWidth: ExamplesDefaults.guidelinesWidth)
                self.guideLinesLayer1 = ChartGuideLinesDottedLayer(xAxis: self.xLowAxes[1], yAxis: self.yLowAxes[0], innerFrame: self.chartInnerFrame, settings: guideLinesLayer1Settings)
                let guideLinesLayer3Settings = ChartGuideLinesDottedLayerSettings(linesColor: self.bgColors[2], linesWidth: ExamplesDefaults.guidelinesWidth)
                self.guideLinesLayer2 = ChartGuideLinesDottedLayer(xAxis: self.xHighAxes[1], yAxis: self.yHighAxes[0], innerFrame: self.chartInnerFrame, settings: guideLinesLayer3Settings)
                let guideLinesLayer4Settings = ChartGuideLinesDottedLayerSettings(linesColor: self.bgColors[3], linesWidth: ExamplesDefaults.guidelinesWidth)
                self.guideLinesLayer3 = ChartGuideLinesDottedLayer(xAxis: self.xHighAxes[0], yAxis: self.yHighAxes[1], innerFrame: self.chartInnerFrame, settings: guideLinesLayer4Settings)
                
                self.showChart(lineAnimDuration: 1)
            }
        }
        
        
        self.view.addSubview(self.createSelectionView())
        self.view.addSubview(self.createShowGuidesView())
    }
    
    fileprivate func createLineLayers(animDuration: Float) -> [ChartPointsLineLayer<ChartPoint>] {
        let lineModel0 = ChartLineModel(chartPoints: chartPoints0, lineColor: bgColors[0], animDuration: animDuration, animDelay: 0)
        let lineModel1 = ChartLineModel(chartPoints: chartPoints1, lineColor: bgColors[1], animDuration: animDuration, animDelay: 0)
        let lineModel2 = ChartLineModel(chartPoints: chartPoints2, lineColor: bgColors[2], animDuration: animDuration, animDelay: 0)
        let lineModel3 = ChartLineModel(chartPoints: chartPoints3, lineColor: bgColors[3], animDuration: animDuration, animDelay: 0)
        
        let chartPointsLineLayer0 = ChartPointsLineLayer<ChartPoint>(xAxis: xLowAxes[0], yAxis: yLowAxes[1], innerFrame: chartInnerFrame, lineModels: [lineModel0])
        let chartPointsLineLayer1 = ChartPointsLineLayer<ChartPoint>(xAxis: xLowAxes[1], yAxis: yLowAxes[0], innerFrame: chartInnerFrame, lineModels: [lineModel1])
        let chartPointsLineLayer2 = ChartPointsLineLayer<ChartPoint>(xAxis: xHighAxes[1], yAxis: yHighAxes[0], innerFrame: chartInnerFrame, lineModels: [lineModel2])
        let chartPointsLineLayer3 = ChartPointsLineLayer<ChartPoint>(xAxis: xHighAxes[0], yAxis: yHighAxes[1], innerFrame: chartInnerFrame, lineModels: [lineModel3])
        
        return [chartPointsLineLayer0, chartPointsLineLayer1, chartPointsLineLayer2, chartPointsLineLayer3]
    }
    
    
    fileprivate func createLayers(selectedLayersFlags: [Bool], showGuides: Bool, lineAnimDuration: Float) -> ([ChartLayer]) {
        
        var axisLayers: [ChartLayer] = []
        var itemsLayers: [ChartLayer] = []
        
        let lineLayers = self.createLineLayers(animDuration: lineAnimDuration)
        
        func group(xAxis: ChartAxisLayer, yAxis: ChartAxisLayer, lineLayer: ChartLayer, guideLayer: ChartLayer) -> [ChartLayer] {
            return [xAxis, yAxis, lineLayer] + (showGuides ? [guideLayer] : [])
        }
        
        let layers: [[ChartLayer]] = [
            group(xAxis: xLowAxes[0], yAxis: yLowAxes[1], lineLayer: lineLayers[0], guideLayer: guideLinesLayer0),
            group(xAxis: xLowAxes[1], yAxis: yLowAxes[0], lineLayer: lineLayers[1], guideLayer: guideLinesLayer1),
            group(xAxis: xHighAxes[1], yAxis: yHighAxes[0], lineLayer: lineLayers[2], guideLayer: guideLinesLayer2),
            group(xAxis: xHighAxes[0], yAxis: yHighAxes[1], lineLayer: lineLayers[3], guideLayer: guideLinesLayer3)
        ]
        
        return selectedLayersFlags.enumerated().reduce(Array<ChartLayer>()) {selectedLayers, inTuple in
            
            let index = inTuple.0
            let selected = inTuple.1
            
            if selected {
                return selectedLayers + layers[index]
            }
            return selectedLayers
        }
    }
    
    fileprivate func showChart(lineAnimDuration: Float) -> () {
        
        self.chart?.clearView()
        
        let layers = self.createLayers(selectedLayersFlags: self.selectedLayersFlags, showGuides: self.showGuides, lineAnimDuration: lineAnimDuration)
        
        let view = ChartBaseView(frame: viewFrame)
        let chart = Chart(
            view: view,
            layers: layers
        )
        
        self.view.addSubview(chart.view)
        self.chart = chart
    }
    
    fileprivate func createSelectionView() -> UIView {
        let v = UIView(frame: CGRect(x: 0, y: self.view.frame.height - selectionViewH - showGuidesViewH, width: self.view.frame.width, height: selectionViewH))
        v.backgroundColor = UIColor.white
        v.isUserInteractionEnabled = true
        
        let selectorSize: CGFloat = 50
        for index in 0...3 {
            
            let x = CGFloat(index) * (selectorSize + 10)
            let y: CGFloat = (selectionViewH - selectorSize) / 2
            
            let selectorView = HandlingView(frame: CGRect(x: x, y: y, width: selectorSize, height: selectorSize))
            selectorView.backgroundColor = self.bgColors[index]
            weak var selectorViewWeak = selectorView
            selectorView.touchHandler = {[weak self] in
                self!.selectedLayersFlags[index] = !self!.selectedLayersFlags[index]
                selectorViewWeak?.backgroundColor = self!.selectedLayersFlags[index] ? self!.bgColors[index] : UIColor.gray
                self!.showChart(lineAnimDuration: 0)
            }
            
            v.addSubview(selectorView)
        }
        return v
    }
    
    fileprivate func createShowGuidesView() -> UIView {
        let v = HandlingView(frame: CGRect(x: 0, y: self.view.frame.height - showGuidesViewH, width: self.view.frame.width, height: showGuidesViewH))
        v.backgroundColor = UIColor.green
        v.isUserInteractionEnabled = true
        let label = UILabel(frame: CGRect(x: 10, y: 0, width: self.view.frame.width, height: showGuidesViewH))
        label.text = "Show guidelines"
        v.addSubview(label)
        
        v.touchHandler = {[weak self] in
            self!.showGuides = !self!.showGuides
            label.text = self!.showGuides ? "Hide guidelines" : "Show guidelines"
            self!.showChart(lineAnimDuration: 0)
        }
        return v
    }
    
    fileprivate func createChartPoint(_ x: Double, _ y: Double, _ labelColor: UIColor) -> ChartPoint {
        let labelSettings = ChartLabelSettings(font: ExamplesDefaults.labelFontSmall, fontColor: labelColor)
        return ChartPoint(x: ChartAxisValueDouble(x, labelSettings: labelSettings), y: ChartAxisValueDouble(y, labelSettings: labelSettings))
    }
}
