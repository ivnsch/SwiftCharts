//
//  MultipleAxesInteractiveExample.swift
//  SwiftCharts
//
//  Created by ischuetz on 04/05/15.
//  Copyright (c) 2015 ivanschuetz. All rights reserved.
//

import UIKit

class MultipleAxesInteractiveExample: UIViewController {

    private var chart: Chart?

    let bgColors = [UIColor.redColor(), UIColor.blueColor(), UIColor(red: 0, green: 0.7, blue: 0, alpha: 1), UIColor(red: 1, green: 0.5, blue: 0, alpha: 1)]

    private var showGuides: Bool = false
    private var selectedLayersFlags = [true, true, true, true]
    
    private let chartPoints0: [ChartPoint]
    private let chartPoints1: [ChartPoint]
    private let chartPoints2: [ChartPoint]
    private let chartPoints3: [ChartPoint]

    private var viewFrame: CGRect!
    private var chartInnerFrame: CGRect!
    
    private var yLowAxes: [ChartAxisLayer]!
    private var yHighAxes: [ChartAxisLayer]!
    private var xLowAxes: [ChartAxisLayer]!
    private var xHighAxes: [ChartAxisLayer]!
    
    private var guideLinesLayer0: ChartLayer!
    private var guideLinesLayer1: ChartLayer!
    private var guideLinesLayer2: ChartLayer!
    private var guideLinesLayer3: ChartLayer!
    
    private let selectionViewH: CGFloat = 100
    private let showGuidesViewH: CGFloat = 50
    
    init() {
        let labelSettings = ChartLabelSettings(font: ExamplesDefaults.labelFontSmall)
        
        func createChartPoint(x: CGFloat, y: CGFloat, labelColor: UIColor) -> ChartPoint {
            let labelSettings = ChartLabelSettings(font: ExamplesDefaults.labelFontSmall, fontColor: labelColor)
            return ChartPoint(x: ChartAxisValueFloat(x, labelSettings: labelSettings), y: ChartAxisValueFloat(y, labelSettings: labelSettings))
        }
        
        func createChartPoints0(color: UIColor) -> [ChartPoint] {
            return [
                createChartPoint(0, 0, color),
                createChartPoint(2, 2, color),
                createChartPoint(5, 2, color),
                createChartPoint(8, 11, color),
                createChartPoint(10, 2, color),
                createChartPoint(12, 3, color),
                createChartPoint(16, 22, color),
                createChartPoint(20, 5, color)
            ]
        }
        
        func createChartPoints1(color: UIColor) -> [ChartPoint] {
            return [
                createChartPoint(0, 7, color),
                createChartPoint(1, 10, color),
                createChartPoint(3, 9, color),
                createChartPoint(9, 2, color),
                createChartPoint(10, -5, color),
                createChartPoint(13, -12, color)
            ]
        }
        
        func createChartPoints2(color: UIColor) -> [ChartPoint] {
            return [
                createChartPoint(-200, -10, color),
                createChartPoint(-160, -30, color),
                createChartPoint(-110, -10, color),
                createChartPoint(-40, -80, color),
                createChartPoint(-10, -50, color),
                createChartPoint(20, 10, color)
            ]
        }
        
        func createChartPoints3(color: UIColor) -> [ChartPoint] {
            return [
                createChartPoint(10000, 70, color),
                createChartPoint(20000, 100, color),
                createChartPoint(30000, 160, color)
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
        
        let chartFrame = ExamplesDefaults.chartFrame(self.view.bounds)
        let chartBounds = CGRectMake(0, 0, chartFrame.width, chartFrame.height)
        let chartSettings = ExamplesDefaults.chartSettings
        
        let top: CGFloat = 80
        
        self.viewFrame = CGRectMake(0, top, self.view.frame.size.width, self.view.frame.size.height - selectionViewH - showGuidesViewH - top - 10)
        
        let yValues0 = ChartAxisValuesGenerator.generateYAxisValuesWithChartPoints(self.chartPoints0, minSegmentCount: 10, maxSegmentCount: 20, multiple: 2, axisValueGenerator: {ChartAxisValueFloat($0, labelSettings: ChartLabelSettings(font: ExamplesDefaults.labelFontSmall, fontColor: self.bgColors[0]))}, addPaddingSegmentIfEdge: false)
        
        let yValues1 = ChartAxisValuesGenerator.generateYAxisValuesWithChartPoints(self.chartPoints1, minSegmentCount: 10, maxSegmentCount: 20, multiple: 2, axisValueGenerator: {ChartAxisValueFloat($0, labelSettings: ChartLabelSettings(font: ExamplesDefaults.labelFontSmall, fontColor: self.bgColors[1]))}, addPaddingSegmentIfEdge: false)
        
        let yValues2 = ChartAxisValuesGenerator.generateYAxisValuesWithChartPoints(self.chartPoints2, minSegmentCount: 10, maxSegmentCount: 20, multiple: 2, axisValueGenerator: {ChartAxisValueFloat($0, labelSettings: ChartLabelSettings(font: ExamplesDefaults.labelFontSmall, fontColor: self.bgColors[2]))}, addPaddingSegmentIfEdge: false)
        
        let yValues3 = ChartAxisValuesGenerator.generateYAxisValuesWithChartPoints(self.chartPoints3, minSegmentCount: 10, maxSegmentCount: 20, multiple: 2, axisValueGenerator: {ChartAxisValueFloat($0, labelSettings: ChartLabelSettings(font: ExamplesDefaults.labelFontSmall, fontColor: self.bgColors[3]))}, addPaddingSegmentIfEdge: false)
        
        let axisTitleFont = ExamplesDefaults.labelFontSmall
        
        let yLowModels: [ChartAxisModel] = [
            ChartAxisModel(axisValues: yValues1, lineColor: self.bgColors[1], axisTitleLabels: [ChartAxisLabel(text: "Axis title", settings: ChartLabelSettings(fontColor: self.bgColors[1], font: axisTitleFont).defaultVertical())]),
            ChartAxisModel(axisValues: yValues0, lineColor: self.bgColors[0], axisTitleLabels: [ChartAxisLabel(text: "Axis title", settings: ChartLabelSettings(fontColor: self.bgColors[0], font: axisTitleFont).defaultVertical())])
        ]
        let yHighModels: [ChartAxisModel] = [
            ChartAxisModel(axisValues: yValues2, lineColor: self.bgColors[2], axisTitleLabels: [ChartAxisLabel(text: "Axis title", settings: ChartLabelSettings(fontColor: self.bgColors[2], font: axisTitleFont).defaultVertical())]),
            ChartAxisModel(axisValues: yValues3, lineColor: self.bgColors[3], axisTitleLabels: [ChartAxisLabel(text: "Axis title", settings: ChartLabelSettings(fontColor: self.bgColors[3], font: axisTitleFont).defaultVertical())])
        ]
        let xLowModels: [ChartAxisModel] = [
            ChartAxisModel(axisValues: xValues0, lineColor: self.bgColors[0], axisTitleLabels: [ChartAxisLabel(text: "Axis title", settings: ChartLabelSettings(fontColor: self.bgColors[0], font: axisTitleFont))]),
            ChartAxisModel(axisValues: xValues1, lineColor: self.bgColors[1], axisTitleLabels: [ChartAxisLabel(text: "Axis title", settings: ChartLabelSettings(fontColor: self.bgColors[1], font: axisTitleFont))])
        ]
        let xHighModels: [ChartAxisModel] = [
            ChartAxisModel(axisValues: xValues3, lineColor: self.bgColors[3], axisTitleLabels: [ChartAxisLabel(text: "Axis title", settings: ChartLabelSettings(fontColor: self.bgColors[3], font: axisTitleFont))]),
            ChartAxisModel(axisValues: xValues2, lineColor: self.bgColors[2], axisTitleLabels: [ChartAxisLabel(text: "Axis title", settings: ChartLabelSettings(fontColor: self.bgColors[2], font: axisTitleFont))])
        ]
        
        // calculate coords space in the background to keep UI smooth
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            
            let coordsSpace = ChartCoordsSpace(chartSettings: chartSettings, chartSize: self.viewFrame.size, yLowModels: yLowModels, yHighModels: yHighModels, xLowModels: xLowModels, xHighModels: xHighModels)
            
            dispatch_async(dispatch_get_main_queue()) {
                
                self.chartInnerFrame = coordsSpace.chartInnerFrame
                
                // create axes
                self.yLowAxes = coordsSpace.yLowAxes
                self.yHighAxes = coordsSpace.yHighAxes
                self.xLowAxes = coordsSpace.xLowAxes
                self.xHighAxes = coordsSpace.xHighAxes
                
                // create layers with references to axes
                var guideLinesLayer0Settings = ChartGuideLinesDottedLayerSettings(linesColor: self.bgColors[0], linesWidth: ExamplesDefaults.guidelinesWidth)
                self.guideLinesLayer0 = ChartGuideLinesDottedLayer(xAxis: self.xLowAxes[0], yAxis: self.yLowAxes[1], innerFrame: self.chartInnerFrame, settings: guideLinesLayer0Settings)
                var guideLinesLayer1Settings = ChartGuideLinesDottedLayerSettings(linesColor: self.bgColors[1], linesWidth: ExamplesDefaults.guidelinesWidth)
                self.guideLinesLayer1 = ChartGuideLinesDottedLayer(xAxis: self.xLowAxes[1], yAxis: self.yLowAxes[0], innerFrame: self.chartInnerFrame, settings: guideLinesLayer1Settings)
                var guideLinesLayer3Settings = ChartGuideLinesDottedLayerSettings(linesColor: self.bgColors[2], linesWidth: ExamplesDefaults.guidelinesWidth)
                self.guideLinesLayer2 = ChartGuideLinesDottedLayer(xAxis: self.xHighAxes[1], yAxis: self.yHighAxes[0], innerFrame: self.chartInnerFrame, settings: guideLinesLayer3Settings)
                var guideLinesLayer4Settings = ChartGuideLinesDottedLayerSettings(linesColor: self.bgColors[3], linesWidth: ExamplesDefaults.guidelinesWidth)
                self.guideLinesLayer3 = ChartGuideLinesDottedLayer(xAxis: self.xHighAxes[0], yAxis: self.yHighAxes[1], innerFrame: self.chartInnerFrame, settings: guideLinesLayer4Settings)
                
                self.showChart(lineAnimDuration: 1)
            }
        }
        
        
        self.view.addSubview(self.createSelectionView())
        self.view.addSubview(self.createShowGuidesView())
    }
    
    private func createLineLayers(#animDuration: Float) -> [ChartPointsLineLayer<ChartPoint>] {
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
    
    
    private func createLayers(#selectedLayersFlags: [Bool], showGuides: Bool, lineAnimDuration: Float) -> ([ChartLayer]) {
        
        var axisLayers: [ChartLayer] = []
        var itemsLayers: [ChartLayer] = []
        
        let lineLayers = self.createLineLayers(animDuration: lineAnimDuration)
        
        func maybeGuides(guideLayer: ChartLayer) -> [ChartLayer] {
            return (showGuides ? [guideLayer] : [])
        }
        
        let layers: [[ChartLayer]] = [
            [yLowAxes[1], xLowAxes[0], lineLayers[0]] + maybeGuides(guideLinesLayer0),
            [yLowAxes[0], xLowAxes[1], lineLayers[1]] + maybeGuides(guideLinesLayer1),
            [yHighAxes[0], xHighAxes[1], lineLayers[2]] + maybeGuides(guideLinesLayer2),
            [yHighAxes[1], xHighAxes[0], lineLayers[3]] + maybeGuides(guideLinesLayer3)
        ]
        
        return Array(enumerate(selectedLayersFlags)).reduce(Array<ChartLayer>()) {selectedLayers, inTuple in
            
            let index = inTuple.0
            let selected = inTuple.1
            
            if selected {
                return selectedLayers + layers[index]
            }
            return selectedLayers
        }
    }
    
    private func showChart(#lineAnimDuration: Float) -> () {
        
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
    
    private func createSelectionView() -> UIView {
        let v = UIView(frame: CGRectMake(0, self.view.frame.height - selectionViewH - showGuidesViewH, self.view.frame.width, selectionViewH))
        v.backgroundColor = UIColor.whiteColor()
        v.userInteractionEnabled = true
        
        let selectorSize: CGFloat = 50
        for index in 0...3 {
            
            let x = CGFloat(index) * (selectorSize + 10)
            let y: CGFloat = (selectionViewH - selectorSize) / 2
            
            let selectorView = HandlingView(frame: CGRectMake(x, y, selectorSize, selectorSize))
            selectorView.backgroundColor = self.bgColors[index]
            weak var selectorViewWeak = selectorView
            selectorView.touchHandler = {[weak self] in
                self!.selectedLayersFlags[index] = !self!.selectedLayersFlags[index]
                selectorViewWeak?.backgroundColor = self!.selectedLayersFlags[index] ? self!.bgColors[index] : UIColor.grayColor()
                self!.showChart(lineAnimDuration: 0)
            }
            
            v.addSubview(selectorView)
        }
        return v
    }
    
    private func createShowGuidesView() -> UIView {
        let v = HandlingView(frame: CGRectMake(0, self.view.frame.height - showGuidesViewH, self.view.frame.width, showGuidesViewH))
        v.backgroundColor = UIColor.greenColor()
        v.userInteractionEnabled = true
        let label = UILabel(frame: CGRectMake(10, 0, self.view.frame.width, showGuidesViewH))
        label.text = "Show guidelines"
        v.addSubview(label)
        
        v.touchHandler = {[weak self] in
            self!.showGuides = !self!.showGuides
            label.text = self!.showGuides ? "Hide guidelines" : "Show guidelines"
            self!.showChart(lineAnimDuration: 0)
        }
        return v
    }
    
    private func createChartPoint(x: CGFloat, _ y: CGFloat, _ labelColor: UIColor) -> ChartPoint {
        let labelSettings = ChartLabelSettings(font: ExamplesDefaults.labelFontSmall, fontColor: labelColor)
        return ChartPoint(x: ChartAxisValueFloat(x, labelSettings: labelSettings), y: ChartAxisValueFloat(y, labelSettings: labelSettings))
    }
}
