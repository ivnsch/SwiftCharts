//
//  ChartBarsLayer.swift
//  Examples
//
//  Created by ischuetz on 17/05/15.
//  Copyright (c) 2015 ivanschuetz. All rights reserved.
//

import UIKit

open class ChartBarModel {
    open let constant: ChartAxisValue
    open let axisValue1: ChartAxisValue
    open let axisValue2: ChartAxisValue
    open let bgColor: UIColor?

    /**
    - parameter constant:Value of coordinate which doesn't change between start and end of the bar - if the bar is horizontal, this is y, if it's vertical it's x.
    - parameter axisValue1:Start, variable coordinate.
    - parameter axisValue2:End, variable coordinate.
    - parameter bgColor:Background color of bar.
    */
    public init(constant: ChartAxisValue, axisValue1: ChartAxisValue, axisValue2: ChartAxisValue, bgColor: UIColor? = nil) {
        self.constant = constant
        self.axisValue1 = axisValue1
        self.axisValue2 = axisValue2
        self.bgColor = bgColor
    }
}

enum ChartBarDirection {
    case leftToRight, bottomToTop
}

class ChartBarsViewGenerator<T: ChartBarModel> {
    let xAxis: ChartAxisLayer
    let yAxis: ChartAxisLayer
    let chartInnerFrame: CGRect
    let direction: ChartBarDirection
    let barWidth: CGFloat
    
    init(horizontal: Bool, xAxis: ChartAxisLayer, yAxis: ChartAxisLayer, chartInnerFrame: CGRect, barWidth barWidthMaybe: CGFloat?, barSpacing barSpacingMaybe: CGFloat?) {
        
        let direction: ChartBarDirection = {
            switch (horizontal: horizontal, yLow: yAxis.low, xLow: xAxis.low) {
            case (horizontal: true, yLow: true, _): return .leftToRight
            case (horizontal: false, _, xLow: true): return .bottomToTop
            default: fatalError("Direction not supported - stacked bars must be from left to right or bottom to top")
            }
        }()
        
        let barWidth = barWidthMaybe ?? {
            let axis: ChartAxisLayer = {
                switch direction {
                case .leftToRight: return yAxis
                case .bottomToTop: return xAxis
                }
                }()
            let spacing: CGFloat = barSpacingMaybe ?? 0
            return axis.minAxisScreenSpace - spacing
        }()
        
        self.xAxis = xAxis
        self.yAxis = yAxis
        self.chartInnerFrame = chartInnerFrame
        self.direction = direction
        self.barWidth = barWidth
    }
    
    func viewPoints(_ barModel: T, constantScreenLoc: CGFloat) -> (p1: CGPoint, p2: CGPoint) {
        switch self.direction {
        case .leftToRight:
            return (
                CGPoint(x: self.xAxis.screenLocForScalar(barModel.axisValue1.scalar), y: constantScreenLoc),
                CGPoint(x: self.xAxis.screenLocForScalar(barModel.axisValue2.scalar), y: constantScreenLoc))
        case .bottomToTop:
            return (
                CGPoint(x: constantScreenLoc, y: self.yAxis.screenLocForScalar(barModel.axisValue1.scalar)),
                CGPoint(x: constantScreenLoc, y: self.yAxis.screenLocForScalar(barModel.axisValue2.scalar)))
        }
    }
    
    func constantScreenLoc(_ barModel: T) -> CGFloat {
        return (self.direction == .leftToRight ? self.yAxis : self.xAxis).screenLocForScalar(barModel.constant.scalar)
    }
    
    // constantScreenLoc: (screen) coordinate that is equal in p1 and p2 - for vertical bar this is the x coordinate, for horizontal bar this is the y coordinate
    func generateView(_ barModel: T, constantScreenLoc constantScreenLocMaybe: CGFloat? = nil, bgColor: UIColor?, animDuration: Float) -> ChartPointViewBar {
        
        let constantScreenLoc = constantScreenLocMaybe ?? self.constantScreenLoc(barModel)
        
        let viewPoints = self.viewPoints(barModel, constantScreenLoc: constantScreenLoc)
        return ChartPointViewBar(p1: viewPoints.p1, p2: viewPoints.p2, width: self.barWidth, bgColor: bgColor, animDuration: animDuration)
    }
}



open class ChartBarsLayer: ChartCoordsSpaceLayer {
    
    fileprivate let bars: [ChartBarModel]
    
    fileprivate let barWidth: CGFloat?
    fileprivate let barSpacing: CGFloat?
    
    fileprivate let horizontal: Bool
    
    fileprivate let animDuration: Float
    
    public convenience init(xAxis: ChartAxisLayer, yAxis: ChartAxisLayer, innerFrame: CGRect, bars: [ChartBarModel], horizontal: Bool = false, barWidth: CGFloat, animDuration: Float) {
        self.init(xAxis: xAxis, yAxis: yAxis, innerFrame: innerFrame, bars: bars, horizontal: horizontal, barWidth: barWidth, barSpacing: nil, animDuration: animDuration)
    }
    
    public convenience init(xAxis: ChartAxisLayer, yAxis: ChartAxisLayer, innerFrame: CGRect, bars: [ChartBarModel], horizontal: Bool = false, barSpacing: CGFloat, animDuration: Float) {
        self.init(xAxis: xAxis, yAxis: yAxis, innerFrame: innerFrame, bars: bars, horizontal: horizontal, barWidth: nil, barSpacing: barSpacing, animDuration: animDuration)
    }
    
    fileprivate init(xAxis: ChartAxisLayer, yAxis: ChartAxisLayer, innerFrame: CGRect, bars: [ChartBarModel], horizontal: Bool = false, barWidth: CGFloat? = nil, barSpacing: CGFloat?, animDuration: Float) {
        self.bars = bars
        self.horizontal = horizontal
        self.barWidth = barWidth
        self.barSpacing = barSpacing
        self.animDuration = animDuration

        super.init(xAxis: xAxis, yAxis: yAxis, innerFrame: innerFrame)
    }
    
    open override func chartInitialized(chart: Chart) {
        
        
        let barsGenerator = ChartBarsViewGenerator(horizontal: self.horizontal, xAxis: self.xAxis, yAxis: self.yAxis, chartInnerFrame: self.innerFrame, barWidth: self.barWidth, barSpacing: self.barSpacing)
        
        for barModel in self.bars {
            chart.addSubview(barsGenerator.generateView(barModel, bgColor: barModel.bgColor, animDuration: self.animDuration))
        }
    }
}
