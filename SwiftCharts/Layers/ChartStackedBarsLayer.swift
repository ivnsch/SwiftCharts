//
//  ChartStackedBarsLayer.swift
//  Examples
//
//  Created by ischuetz on 15/05/15.
//  Copyright (c) 2015 ivanschuetz. All rights reserved.
//

import UIKit

public typealias ChartStackedBarItemModel = (quantity: CGFloat, bgColor: UIColor)

public class ChartStackedBarModel: ChartBarModel {

    let items: [ChartStackedBarItemModel]
    
    public init(constant: ChartAxisValue, start: ChartAxisValue, items: [ChartStackedBarItemModel]) {
        self.items = items

        let axisValue2Scalar = items.reduce(start.scalar) {sum, item in
            sum + item.quantity
        }
        let axisValue2 = start.copy(axisValue2Scalar)
        
        super.init(constant: constant, axisValue1: start, axisValue2: axisValue2)
    }
    
    lazy var totalQuantity: CGFloat = {
        return self.items.reduce(0) {total, item in
            total + item.quantity
        }
    }()
}


class ChartStackedBarsViewGenerator<T: ChartStackedBarModel>: ChartBarsViewGenerator<T> {
    
    private typealias FrameBuilder = (barModel: ChartStackedBarModel, item: ChartStackedBarItemModel, currentTotalQuantity: CGFloat) -> (frame: ChartPointViewBarStackedFrame, length: CGFloat)
    
    private lazy var leftToRightFrameBuilder: FrameBuilder = {
        {barModel, item, currentTotalQuantity in
            let p0 = self.xAxis.screenLocForScalar(currentTotalQuantity)
            let p1 = self.xAxis.screenLocForScalar(currentTotalQuantity + item.quantity)
            let length = abs(p1 - p0)
            
            return (frame: ChartPointViewBarStackedFrame(rect:
                CGRectMake(
                    p0 - self.chartInnerFrame.origin.x,
                    0,
                    length,
                    self.barWidth), color: item.bgColor), length: length)
        }
    }()
    
    private lazy var bottomToTopFrameBuilder: FrameBuilder = {
        {barModel, item, currentTotalQuantity in
            let p0 = self.yAxis.screenLocForScalar(currentTotalQuantity)
            let p1 = self.yAxis.screenLocForScalar(currentTotalQuantity + item.quantity)
            let length = abs(p1 - p0)
            
            let totalLength = self.yAxis.screenLocForScalar(barModel.totalQuantity)
            return (frame: ChartPointViewBarStackedFrame(rect:
                CGRectMake(
                    0,
                    p1 - totalLength,
                    self.barWidth,
                    length), color: item.bgColor), length: length)
        }
    }()
    
    private lazy var frameBuilder: FrameBuilder = {
        switch self.direction {
        case .LeftToRight: return self.leftToRightFrameBuilder
        case .BottomToTop: return self.bottomToTopFrameBuilder
        }
    }()
    
    override init(horizontal: Bool, xAxis: ChartAxisLayer, yAxis: ChartAxisLayer, chartInnerFrame: CGRect, barWidth barWidthMaybe: CGFloat?, barSpacing barSpacingMaybe: CGFloat?) {
        super.init(horizontal: horizontal, xAxis: xAxis, yAxis: yAxis, chartInnerFrame: chartInnerFrame, barWidth: barWidthMaybe, barSpacing: barSpacingMaybe)
    }
    
    override func generateView(barModel: T, constantScreenLoc constantScreenLocMaybe: CGFloat? = nil, bgColor: UIColor? = nil, animDuration: Float) -> ChartPointViewBar {
        
        let constantScreenLoc = constantScreenLocMaybe ?? self.constantScreenLoc(barModel)
        
        let stackFrames = barModel.items.reduce((currentTotalQuantity: CGFloat(0), currentTotalLength: CGFloat(0), frames: Array<ChartPointViewBarStackedFrame>())) {tuple, item in
            let frameWithLength = self.frameBuilder(barModel: barModel, item: item, currentTotalQuantity: tuple.currentTotalQuantity)
            return (currentTotalQuantity: tuple.currentTotalQuantity + item.quantity, currentTotalLength: tuple.currentTotalLength + frameWithLength.length, frames: tuple.frames + [frameWithLength.frame])
        }
        
        let viewPoints = self.viewPoints(barModel, constantScreenLoc: constantScreenLoc)
        
        return ChartPointViewBarStacked(p1: viewPoints.p1, p2: viewPoints.p2, width: self.barWidth, stackFrames: stackFrames.frames, animDuration: animDuration)
    }
    
}

public class ChartStackedBarsLayer: ChartCoordsSpaceLayer {
    
    private let barModels: [ChartStackedBarModel]
    private let horizontal: Bool
    
    private let barWidth: CGFloat?
    private let barSpacing: CGFloat?
    
    public convenience init(xAxis: ChartAxisLayer, yAxis: ChartAxisLayer, innerFrame: CGRect, barModels: [ChartStackedBarModel], horizontal: Bool = false, barWidth: CGFloat) {
        self.init(xAxis: xAxis, yAxis: yAxis, innerFrame: innerFrame, barModels: barModels, horizontal: horizontal, barWidth: barWidth, barSpacing: nil)
    }

    public convenience init(xAxis: ChartAxisLayer, yAxis: ChartAxisLayer, innerFrame: CGRect, barModels: [ChartStackedBarModel], horizontal: Bool = false, barSpacing: CGFloat) {
        self.init(xAxis: xAxis, yAxis: yAxis, innerFrame: innerFrame, barModels: barModels, horizontal: horizontal, barWidth: nil, barSpacing: barSpacing)
    }
    
    private init(xAxis: ChartAxisLayer, yAxis: ChartAxisLayer, innerFrame: CGRect, barModels: [ChartStackedBarModel], horizontal: Bool = false, barWidth: CGFloat? = nil, barSpacing: CGFloat?) {
        self.barModels = barModels
        self.horizontal = horizontal
        self.barWidth = barWidth
        self.barSpacing = barSpacing
        
        super.init(xAxis: xAxis, yAxis: yAxis, innerFrame: innerFrame)
    }
    
    public override func chartInitialized(#chart: Chart) {

        let barsGenerator = ChartStackedBarsViewGenerator(horizontal: self.horizontal, xAxis: self.xAxis, yAxis: self.yAxis, chartInnerFrame: self.innerFrame, barWidth: self.barWidth, barSpacing: self.barSpacing)
        
        for barModel in self.barModels {
            chart.addSubview(barsGenerator.generateView(barModel, animDuration: 0.5))
        }
    }
}
