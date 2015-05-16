//
//  ChartStackedBarsLayer.swift
//  Examples
//
//  Created by ischuetz on 15/05/15.
//  Copyright (c) 2015 ivanschuetz. All rights reserved.
//

import UIKit

public typealias ChartStackedBarItemModel = (title: String, quantity: CGFloat, bgColor: UIColor)

public final class ChartStackedBarModel {
    let constantAxisValue: ChartAxisValue
    let items: [ChartStackedBarItemModel]
    
    public init(constantAxisValue: ChartAxisValue, items: [ChartStackedBarItemModel]) {
        self.constantAxisValue = constantAxisValue
        self.items = items
    }
    
    lazy var totalQuantity: CGFloat = {
        return self.items.reduce(0) {total, item in
            total + item.quantity
        }
    }()
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

        enum Direction {
            case LeftToRight, BottomToTop
        }
        
        let direction: Direction = {
            switch (horizontal: self.horizontal, yLow: self.yAxis.low, xLow: self.xAxis.low) {
                case (horizontal: true, yLow: true, _): return .LeftToRight
                case (horizontal: false, _, xLow: true): return .BottomToTop
                default: fatalError("Direction not supported - stacked bars must be from left to right or bottom to top")
            }
        }()
        
        let barWidth = self.barWidth ?? {
            let axis: ChartAxisLayer = {
                switch direction {
                    case .LeftToRight: return self.yAxis
                    case .BottomToTop: return self.xAxis
                }
            }()
            let spacing: CGFloat = self.barSpacing! // if barWidth is not set, barSpacing is set - initializers ensure this
            return axis.minAxisScreenSpace - spacing
        }()
        
        
        
        typealias FrameBuilder = (barModel: ChartStackedBarModel, item: ChartStackedBarItemModel, currentTotalQuantity: CGFloat) -> (frame: ChartPointViewBarStackedFrame, length: CGFloat)
        
        let leftToRightFrameBuilder: FrameBuilder = {barModel, item, currentTotalQuantity in
            let p0 = self.xAxis.screenLocForScalar(currentTotalQuantity)
            let p1 = self.xAxis.screenLocForScalar(currentTotalQuantity + item.quantity)
            let length = abs(p1 - p0)
            
            return (frame: ChartPointViewBarStackedFrame(rect:
                CGRectMake(
                    p0 - self.innerFrame.origin.x,
                    0,
                    length,
                    barWidth), color: item.bgColor), length: length)
        }

        let bottomToTopFrameBuilder: FrameBuilder = {barModel, item, currentTotalQuantity in
            let p0 = self.yAxis.screenLocForScalar(currentTotalQuantity)
            let p1 = self.yAxis.screenLocForScalar(currentTotalQuantity + item.quantity)
            let length = abs(p1 - p0)
            
            let totalLength = self.yAxis.screenLocForScalar(barModel.totalQuantity)
            return (frame: ChartPointViewBarStackedFrame(rect:
                CGRectMake(
                    0,
                    p1 - totalLength,
                    barWidth,
                    length), color: item.bgColor), length: length)
        }
        
        let frameBuilder: FrameBuilder = {
            switch direction {
                case .LeftToRight: return leftToRightFrameBuilder
                case .BottomToTop: return bottomToTopFrameBuilder
            }
        }()
        
        for barModel in self.barModels {
            
            if barModel.items.isEmpty {continue}
            
            let stackFrames = barModel.items.reduce((currentTotalQuantity: CGFloat(0), currentTotalLength: CGFloat(0), frames: Array<ChartPointViewBarStackedFrame>())) {tuple, item in
                let frameWithLength = frameBuilder(barModel: barModel, item: item, currentTotalQuantity: tuple.currentTotalQuantity)
                return (currentTotalQuantity: tuple.currentTotalQuantity + item.quantity, currentTotalLength: tuple.currentTotalLength + frameWithLength.length, frames: tuple.frames + [frameWithLength.frame])
            }
            
            let (p1: CGPoint, p2: CGPoint) = {
                let first = stackFrames.frames.first!
                let last = stackFrames.frames.last!
                
                switch direction {
                    case .LeftToRight:
                        let y = self.yAxis.screenLocForScalar(barModel.constantAxisValue.scalar)
                        return (
                            CGPointMake(self.innerFrame.origin.x, y),
                            CGPointMake(self.innerFrame.origin.x + stackFrames.currentTotalLength, y))
                    case .BottomToTop:
                        let x = self.xAxis.screenLocForScalar(barModel.constantAxisValue.scalar)
                        return (
                            CGPointMake(x, self.innerFrame.origin.y + self.innerFrame.height),
                            CGPointMake(x, self.innerFrame.origin.y + self.innerFrame.height - stackFrames.currentTotalLength))
                }
            }()
            
            chart.addSubview(ChartPointViewBarStacked(p1: p1, p2: p2, width: barWidth, stackFrames: stackFrames.frames, animDuration: 0.5))
        }
    }
}
