//
//  ChartStackedBarsLayer.swift
//  Examples
//
//  Created by ischuetz on 15/05/15.
//  Copyright (c) 2015 ivanschuetz. All rights reserved.
//

import UIKit

public typealias ChartStackedBarItemModel = (quantity: Double, bgColor: UIColor)

open class ChartStackedBarModel: ChartBarModel {

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
    
    fileprivate typealias FrameBuilder = (_ barModel: ChartStackedBarModel, _ item: ChartStackedBarItemModel, _ currentTotalQuantity: Double) -> (frame: ChartPointViewBarStackedFrame, length: CGFloat)
    
    override init(horizontal: Bool, xAxis: ChartAxisLayer, yAxis: ChartAxisLayer, chartInnerFrame: CGRect, barWidth barWidthMaybe: CGFloat?, barSpacing barSpacingMaybe: CGFloat?) {
        super.init(horizontal: horizontal, xAxis: xAxis, yAxis: yAxis, chartInnerFrame: chartInnerFrame, barWidth: barWidthMaybe, barSpacing: barSpacingMaybe)
    }
    
    override func generateView(_ barModel: T, constantScreenLoc constantScreenLocMaybe: CGFloat? = nil, bgColor: UIColor? = nil, animDuration: Float) -> ChartPointViewBar {
        
        let constantScreenLoc = constantScreenLocMaybe ?? self.constantScreenLoc(barModel)
        
        let frameBuilder: FrameBuilder = {
            switch self.direction {
                case .leftToRight:
                    return {barModel, item, currentTotalQuantity in
                        let p0 = self.xAxis.screenLocForScalar(currentTotalQuantity)
                        let p1 = self.xAxis.screenLocForScalar(currentTotalQuantity + item.quantity)
                        let length = p1 - p0
                        let barLeftScreenLoc = self.xAxis.screenLocForScalar(length > 0 ? barModel.axisValue1.scalar : barModel.axisValue2.scalar)
                        
                        return (frame: ChartPointViewBarStackedFrame(rect:
                            CGRect(
                                x: p0 - barLeftScreenLoc,
                                y: 0,
                                width: length,
                                height: self.barWidth), color: item.bgColor), length: length)
                }
                case .bottomToTop:
                    return {barModel, item, currentTotalQuantity in
                        let p0 = self.yAxis.screenLocForScalar(currentTotalQuantity)
                        let p1 = self.yAxis.screenLocForScalar(currentTotalQuantity + item.quantity)
                        let length = p1 - p0
                        let barTopScreenLoc = self.yAxis.screenLocForScalar(length > 0 ? barModel.axisValue1.scalar : barModel.axisValue2.scalar)
                        
                        return (frame: ChartPointViewBarStackedFrame(rect:
                            CGRect(
                                x: 0,
                                y: p0 - barTopScreenLoc,
                                width: self.barWidth,
                                height: length), color: item.bgColor), length: length)
                }
            }
        }()
        
        
        let stackFrames = barModel.items.reduce((currentTotalQuantity: barModel.axisValue1.scalar, currentTotalLength: CGFloat(0), frames: Array<ChartPointViewBarStackedFrame>())) {tuple, item in
            let frameWithLength = frameBuilder(barModel, item, tuple.currentTotalQuantity)
            return (currentTotalQuantity: tuple.currentTotalQuantity + item.quantity, currentTotalLength: tuple.currentTotalLength + frameWithLength.length, frames: tuple.frames + [frameWithLength.frame])
        }
        
        let viewPoints = self.viewPoints(barModel, constantScreenLoc: constantScreenLoc)
        
        return ChartPointViewBarStacked(p1: viewPoints.p1, p2: viewPoints.p2, width: self.barWidth, stackFrames: stackFrames.frames, animDuration: animDuration)
    }
    
}

open class ChartStackedBarsLayer: ChartCoordsSpaceLayer {
    
    fileprivate let barModels: [ChartStackedBarModel]
    fileprivate let horizontal: Bool
    
    fileprivate let barWidth: CGFloat?
    fileprivate let barSpacing: CGFloat?
    
    fileprivate let animDuration: Float
    
    public convenience init(xAxis: ChartAxisLayer, yAxis: ChartAxisLayer, innerFrame: CGRect, barModels: [ChartStackedBarModel], horizontal: Bool = false, barWidth: CGFloat, animDuration: Float) {
        self.init(xAxis: xAxis, yAxis: yAxis, innerFrame: innerFrame, barModels: barModels, horizontal: horizontal, barWidth: barWidth, barSpacing: nil, animDuration: animDuration)
    }

    public convenience init(xAxis: ChartAxisLayer, yAxis: ChartAxisLayer, innerFrame: CGRect, barModels: [ChartStackedBarModel], horizontal: Bool = false, barSpacing: CGFloat, animDuration: Float) {
        self.init(xAxis: xAxis, yAxis: yAxis, innerFrame: innerFrame, barModels: barModels, horizontal: horizontal, barWidth: nil, barSpacing: barSpacing, animDuration: animDuration)
    }
    
    fileprivate init(xAxis: ChartAxisLayer, yAxis: ChartAxisLayer, innerFrame: CGRect, barModels: [ChartStackedBarModel], horizontal: Bool = false, barWidth: CGFloat? = nil, barSpacing: CGFloat?, animDuration: Float) {
        self.barModels = barModels
        self.horizontal = horizontal
        self.barWidth = barWidth
        self.barSpacing = barSpacing
        self.animDuration = animDuration
        
        super.init(xAxis: xAxis, yAxis: yAxis, innerFrame: innerFrame)
    }
    
    open override func chartInitialized(chart: Chart) {

        let barsGenerator = ChartStackedBarsViewGenerator(horizontal: self.horizontal, xAxis: self.xAxis, yAxis: self.yAxis, chartInnerFrame: self.innerFrame, barWidth: self.barWidth, barSpacing: self.barSpacing)
        
        for barModel in self.barModels {
            chart.addSubview(barsGenerator.generateView(barModel, animDuration: self.animDuration))
        }
    }
}
