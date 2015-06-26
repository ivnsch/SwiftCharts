//
//  ChartCoordsSpace.swift
//  SwiftCharts
//
//  Created by ischuetz on 27/04/15.
//  Copyright (c) 2015 ivanschuetz. All rights reserved.
//

import UIKit

public class ChartCoordsSpace {
    
    public typealias ChartAxisLayerModel = (p1: CGPoint, p2: CGPoint, axisValues: [ChartAxisValue], axisTitleLabels: [ChartAxisLabel], settings: ChartAxisSettings)
    public typealias ChartAxisLayerGenerator = (ChartAxisLayerModel) -> ChartAxisLayer
    
    private let chartSettings: ChartSettings
    private let chartSize: CGSize
    
    public private(set) var chartInnerFrame: CGRect = CGRectZero
    
    private let yLowModels: [ChartAxisModel]
    private let yHighModels: [ChartAxisModel]
    private let xLowModels: [ChartAxisModel]
    private let xHighModels: [ChartAxisModel]
    
    private let yLowGenerator: ChartAxisLayerGenerator
    private let yHighGenerator: ChartAxisLayerGenerator
    private let xLowGenerator: ChartAxisLayerGenerator
    private let xHighGenerator: ChartAxisLayerGenerator

    public private(set) var yLowAxes: [ChartAxisLayer] = []
    public private(set) var yHighAxes: [ChartAxisLayer] = []
    public private(set) var xLowAxes: [ChartAxisLayer] = []
    public private(set) var xHighAxes: [ChartAxisLayer] = []

    public convenience init(chartSettings: ChartSettings, chartSize: CGSize, yLowModels: [ChartAxisModel] = [], yHighModels: [ChartAxisModel] = [], xLowModels: [ChartAxisModel] = [], xHighModels: [ChartAxisModel] = []) {
        
        let yLowGenerator: ChartAxisLayerGenerator = {model in
            ChartAxisYLowLayerDefault(p1: model.p1, p2: model.p2, axisValues: model.axisValues, axisTitleLabels: model.axisTitleLabels, settings: model.settings)
        }
        let yHighGenerator: ChartAxisLayerGenerator = {model in
            ChartAxisYHighLayerDefault(p1: model.p1, p2: model.p2, axisValues: model.axisValues, axisTitleLabels: model.axisTitleLabels, settings: model.settings)
        }
        let xLowGenerator: ChartAxisLayerGenerator = {model in
            ChartAxisXLowLayerDefault(p1: model.p1, p2: model.p2, axisValues: model.axisValues, axisTitleLabels: model.axisTitleLabels, settings: model.settings)
        }
        let xHighGenerator: ChartAxisLayerGenerator = {model in
            ChartAxisXHighLayerDefault(p1: model.p1, p2: model.p2, axisValues: model.axisValues, axisTitleLabels: model.axisTitleLabels, settings: model.settings)
        }
        
        self.init(chartSettings: chartSettings, chartSize: chartSize, yLowModels: yLowModels, yHighModels: yHighModels, xLowModels: xLowModels, xHighModels: xHighModels, yLowGenerator: yLowGenerator, yHighGenerator: yHighGenerator, xLowGenerator: xLowGenerator, xHighGenerator: xHighGenerator)
    }
    
    public init(chartSettings: ChartSettings, chartSize: CGSize, yLowModels: [ChartAxisModel], yHighModels: [ChartAxisModel], xLowModels: [ChartAxisModel], xHighModels: [ChartAxisModel], yLowGenerator: ChartAxisLayerGenerator, yHighGenerator: ChartAxisLayerGenerator, xLowGenerator: ChartAxisLayerGenerator, xHighGenerator: ChartAxisLayerGenerator) {
        self.chartSettings = chartSettings
        self.chartSize = chartSize
        
        self.yLowModels = yLowModels
        self.yHighModels = yHighModels
        self.xLowModels = xLowModels
        self.xHighModels = xHighModels
        
        self.yLowGenerator = yLowGenerator
        self.yHighGenerator = yHighGenerator
        self.xLowGenerator = xLowGenerator
        self.xHighGenerator = xHighGenerator
        
        self.chartInnerFrame = self.calculateChartInnerFrame()
        
        self.yLowAxes = self.generateYLowAxes()
        self.yHighAxes = self.generateYHighAxes()
        self.xLowAxes = self.generateXLowAxes()
        self.xHighAxes = self.generateXHighAxes()
    }
    
    private func generateYLowAxes() -> [ChartAxisLayer] {
        return generateYAxisShared(axisModels: self.yLowModels, offset: chartSettings.leading, generator: self.yLowGenerator)
    }
    
    private func generateYHighAxes() -> [ChartAxisLayer] {
        let chartFrame = self.chartInnerFrame
        return generateYAxisShared(axisModels: self.yHighModels, offset: chartFrame.origin.x + chartFrame.width, generator: self.yHighGenerator)
    }
    
    private func generateXLowAxes() -> [ChartAxisLayer] {
        let chartFrame = self.chartInnerFrame
        let y = chartFrame.origin.y + chartFrame.height
        return self.generateXAxesShared(axisModels: self.xLowModels, offset: y, generator: self.xLowGenerator)
    }
    
    private func generateXHighAxes() -> [ChartAxisLayer] {
        return self.generateXAxesShared(axisModels: self.xHighModels, offset: chartSettings.top, generator: self.xHighGenerator)
    }
    
    private func generateXAxesShared(axisModels axisModels: [ChartAxisModel], offset: CGFloat, generator: ChartAxisLayerGenerator) -> [ChartAxisLayer] {
        let chartFrame = self.chartInnerFrame
        let chartSettings = self.chartSettings
        let x = chartFrame.origin.x
        let length = chartFrame.width
        
        return generateAxisShared(axisModels: axisModels, offset: offset, pointsCreator: { varDim in
            (p1: CGPointMake(x, varDim), p2: CGPointMake(x + length, varDim))
            }, dimIncr: { layer in
                layer.rect.height + chartSettings.spacingBetweenAxesX
            }, generator: generator)
    }
    
    
    private func generateYAxisShared(axisModels axisModels: [ChartAxisModel], offset: CGFloat, generator: ChartAxisLayerGenerator) -> [ChartAxisLayer] {
        let chartFrame = self.chartInnerFrame
        let chartSettings = self.chartSettings
        let y = chartFrame.origin.y
        let length = chartFrame.height
        
        return generateAxisShared(axisModels: axisModels, offset: offset, pointsCreator: { varDim in
            (p1: CGPointMake(varDim, y + length), p2: CGPointMake(varDim, y))
            }, dimIncr: { layer in
                layer.rect.width + chartSettings.spacingBetweenAxesY
            }, generator: generator)
    }
    
    private func generateAxisShared(axisModels axisModels: [ChartAxisModel], offset: CGFloat, pointsCreator: (varDim: CGFloat) -> (p1: CGPoint, p2: CGPoint), dimIncr: (ChartAxisLayer) -> CGFloat, generator: ChartAxisLayerGenerator) -> [ChartAxisLayer] {
        
        let chartSettings = self.chartSettings
        
        return axisModels.reduce((axes: Array<ChartAxisLayer>(), x: offset)) {tuple, chartAxisModel in
            let layers = tuple.axes
            let x: CGFloat = tuple.x
            let axisSettings = ChartAxisSettings(chartSettings)
            axisSettings.lineColor = chartAxisModel.lineColor
            let points = pointsCreator(varDim: x)
            let layer = generator(p1: points.p1, p2: points.p2, axisValues: chartAxisModel.axisValues, axisTitleLabels: chartAxisModel.axisTitleLabels, settings: axisSettings)
            return (
                axes: layers + [layer],
                x: x + dimIncr(layer)
            )
        }.0
    }
    
    private func calculateChartInnerFrame() -> CGRect {
        
        let totalDim = {(axisLayers: [ChartAxisLayer], dimPicker: (ChartAxisLayer) -> CGFloat, spacingBetweenAxes: CGFloat) -> CGFloat in
            return axisLayers.reduce((CGFloat(0), CGFloat(0))) {tuple, chartAxisLayer in
                let totalDim = tuple.0 + tuple.1
                return (totalDim + dimPicker(chartAxisLayer), spacingBetweenAxes)
            }.0
        }

        func totalWidth(axisLayers: [ChartAxisLayer]) -> CGFloat {
            return totalDim(axisLayers, {$0.rect.width}, self.chartSettings.spacingBetweenAxesY)
        }
        
        func totalHeight(axisLayers: [ChartAxisLayer]) -> CGFloat {
            return totalDim(axisLayers, {$0.rect.height}, self.chartSettings.spacingBetweenAxesX)
        }
        
        let yLowWidth = totalWidth(self.generateYLowAxes())
        let yHighWidth = totalWidth(self.generateYHighAxes())
        let xLowHeight = totalHeight(self.generateXLowAxes())
        let xHighHeight = totalHeight(self.generateXHighAxes())
        
        let leftWidth = yLowWidth + self.chartSettings.leading
        let topHeigth = xHighHeight + self.chartSettings.top
        let rightWidth = yHighWidth + self.chartSettings.trailing
        let bottomHeight = xLowHeight + self.chartSettings.bottom
        
        return CGRectMake(
            leftWidth,
            topHeigth,
            self.chartSize.width - leftWidth - rightWidth,
            self.chartSize.height - topHeigth - bottomHeight
        )
    }
}

public class ChartCoordsSpaceLeftBottomSingleAxis {

    public let yAxis: ChartAxisLayer
    public let xAxis: ChartAxisLayer
    public let chartInnerFrame: CGRect
    
    public init(chartSettings: ChartSettings, chartFrame: CGRect, xModel: ChartAxisModel, yModel: ChartAxisModel) {
        let coordsSpaceInitializer = ChartCoordsSpace(chartSettings: chartSettings, chartSize: chartFrame.size, yLowModels: [yModel], xLowModels: [xModel])
        self.chartInnerFrame = coordsSpaceInitializer.chartInnerFrame
        
        self.yAxis = coordsSpaceInitializer.yLowAxes[0]
        self.xAxis = coordsSpaceInitializer.xLowAxes[0]
    }
}

public class ChartCoordsSpaceLeftTopSingleAxis {
    
    public let yAxis: ChartAxisLayer
    public let xAxis: ChartAxisLayer
    public let chartInnerFrame: CGRect
    
    public init(chartSettings: ChartSettings, chartFrame: CGRect, xModel: ChartAxisModel, yModel: ChartAxisModel) {
        let coordsSpaceInitializer = ChartCoordsSpace(chartSettings: chartSettings, chartSize: chartFrame.size, yLowModels: [yModel], xHighModels: [xModel])
        self.chartInnerFrame = coordsSpaceInitializer.chartInnerFrame
        
        self.yAxis = coordsSpaceInitializer.yLowAxes[0]
        self.xAxis = coordsSpaceInitializer.xHighAxes[0]
    }
}

public class ChartCoordsSpaceRightBottomSingleAxis {
    
    public let yAxis: ChartAxisLayer
    public let xAxis: ChartAxisLayer
    public let chartInnerFrame: CGRect
    
    public init(chartSettings: ChartSettings, chartFrame: CGRect, xModel: ChartAxisModel, yModel: ChartAxisModel) {
        let coordsSpaceInitializer = ChartCoordsSpace(chartSettings: chartSettings, chartSize: chartFrame.size, yHighModels: [yModel], xLowModels: [xModel])
        self.chartInnerFrame = coordsSpaceInitializer.chartInnerFrame
        
        self.yAxis = coordsSpaceInitializer.yHighAxes[0]
        self.xAxis = coordsSpaceInitializer.xLowAxes[0]
    }
}