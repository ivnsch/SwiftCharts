//
//  ChartStackedBarsLayer.swift
//  Examples
//
//  Created by ischuetz on 15/05/15.
//  Copyright (c) 2015 ivanschuetz. All rights reserved.
//

import UIKit

public typealias ChartStackedBarItemModel = (quantity: Double, bgColor: UIColor)

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
    
    lazy var totalQuantity: Double = {
        return self.items.reduce(0) {total, item in
            total + item.quantity
        }
    }()
}


class ChartStackedBarsViewGenerator<T: ChartStackedBarModel>: ChartBarsViewGenerator<T> {
    
    private typealias FrameBuilder = (barModel: ChartStackedBarModel, item: ChartStackedBarItemModel, currentTotalQuantity: Double) -> (frame: ChartPointViewBarStackedFrame, length: CGFloat)
    
    override init(horizontal: Bool, xAxis: ChartAxis, yAxis: ChartAxis, chartInnerFrame: CGRect, barWidth: CGFloat) {
        super.init(horizontal: horizontal, xAxis: xAxis, yAxis: yAxis, chartInnerFrame: chartInnerFrame, barWidth: barWidth)
    }
    
    override func generateView(barModel: T, constantScreenLoc constantScreenLocMaybe: CGFloat? = nil, bgColor: UIColor? = nil, animDuration: Float) -> ChartPointViewBar {
        
        let constantScreenLoc = constantScreenLocMaybe ?? self.constantScreenLoc(barModel)
        
        let frameBuilder: FrameBuilder = {
            switch self.horizontal {
                case true:
                    return {barModel, item, currentTotalQuantity in
                        let p0 = self.xAxis.screenLocForScalar(currentTotalQuantity)
                        let p1 = self.xAxis.screenLocForScalar(currentTotalQuantity + item.quantity)
                        let length = p1 - p0
                        let barLeftScreenLoc = self.xAxis.screenLocForScalar(length > 0 ? barModel.axisValue1.scalar : barModel.axisValue2.scalar)
                        
                        return (frame: ChartPointViewBarStackedFrame(rect:
                            CGRectMake(
                                p0 - barLeftScreenLoc,
                                0,
                                length,
                                self.barWidth), color: item.bgColor), length: length)
                }
                case false:
                    return {barModel, item, currentTotalQuantity in
                        let p0 = self.yAxis.screenLocForScalar(currentTotalQuantity)
                        let p1 = self.yAxis.screenLocForScalar(currentTotalQuantity + item.quantity)
                        let length = p1 - p0
                        let barTopScreenLoc = self.yAxis.screenLocForScalar(length > 0 ? barModel.axisValue1.scalar : barModel.axisValue2.scalar)
                        
                        return (frame: ChartPointViewBarStackedFrame(rect:
                            CGRectMake(
                                0,
                                p0 - barTopScreenLoc,
                                self.barWidth,
                                length), color: item.bgColor), length: length)
                }
            }
        }()
        
        
        let stackFrames = barModel.items.reduce((currentTotalQuantity: barModel.axisValue1.scalar, currentTotalLength: CGFloat(0), frames: Array<ChartPointViewBarStackedFrame>())) {tuple, item in
            let frameWithLength = frameBuilder(barModel: barModel, item: item, currentTotalQuantity: tuple.currentTotalQuantity)
            return (currentTotalQuantity: tuple.currentTotalQuantity + item.quantity, currentTotalLength: tuple.currentTotalLength + frameWithLength.length, frames: tuple.frames + [frameWithLength.frame])
        }
        
        let viewPoints = self.viewPoints(barModel, constantScreenLoc: constantScreenLoc)
        
        return ChartPointViewBarStacked(p1: viewPoints.p1, p2: viewPoints.p2, width: self.barWidth, stackFrames: stackFrames.frames, animDuration: animDuration)
    }
    
}

public class ChartStackedBarsLayer: ChartCoordsSpaceLayer {
    private let barModels: [ChartStackedBarModel]
    private let horizontal: Bool
    private let barWidth: CGFloat
    private let animDuration: Float

    private var barViews: [UIView] = []

    public init(xAxis: ChartAxis, yAxis: ChartAxis, innerFrame: CGRect, barModels: [ChartStackedBarModel], horizontal: Bool = false, barWidth: CGFloat, animDuration: Float) {
        self.barModels = barModels
        self.horizontal = horizontal
        self.barWidth = barWidth
        self.animDuration = animDuration
        
        super.init(xAxis: xAxis, yAxis: yAxis, innerFrame: innerFrame)
    }
    
    public override func chartInitialized(chart chart: Chart) {
        super.chartInitialized(chart: chart)
        display()
    }
    
    func display() {
        let barsGenerator = ChartStackedBarsViewGenerator(horizontal: self.horizontal, xAxis: self.xAxis, yAxis: self.yAxis, chartInnerFrame: self.innerFrame, barWidth: self.barWidth)
        
        for barModel in barModels {
            let barView = barsGenerator.generateView(barModel, animDuration: isTransform ? 0 : animDuration)
            barViews.append(barView)
            chart?.addSubview(barView)
        }
    }
    
    private func reloadViews() {
        for v in barViews {
            v.removeFromSuperview()
        }
        
        isTransform = true
        display()
        isTransform = false
    }
    
    public override func pan(deltaX: CGFloat, deltaY: CGFloat) {
        super.pan(deltaX, deltaY: deltaY)
        reloadViews()
    }
    
    public override func zoom(x: CGFloat, y: CGFloat, centerX: CGFloat, centerY: CGFloat) {
        super.zoom(x, y: y, centerX: centerX, centerY: centerY)
        reloadViews()
    }
}
