//
//  ChartBarsLayer.swift
//  Examples
//
//  Created by ischuetz on 17/05/15.
//  Copyright (c) 2015 ivanschuetz. All rights reserved.
//

import UIKit

public class ChartBarModel {
    public let constant: ChartAxisValue
    public let axisValue1: ChartAxisValue
    public let axisValue2: ChartAxisValue
    public let bgColor: UIColor?

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

class ChartBarsViewGenerator<T: ChartBarModel> {
    let xAxis: ChartAxis
    let yAxis: ChartAxis
    let chartInnerFrame: CGRect
    let barWidth: CGFloat
    
    let horizontal: Bool
    
    init(horizontal: Bool, xAxis: ChartAxis, yAxis: ChartAxis, chartInnerFrame: CGRect, barWidth: CGFloat) {
        self.horizontal = horizontal
        self.xAxis = xAxis
        self.yAxis = yAxis
        self.chartInnerFrame = chartInnerFrame
        self.barWidth = barWidth
    }
    
    func viewPoints(barModel: T, constantScreenLoc: CGFloat) -> (p1: CGPoint, p2: CGPoint) {

        
        switch self.horizontal {
        case true:
            return (
                CGPointMake(self.xAxis.screenLocForScalar(barModel.axisValue1.scalar), constantScreenLoc),
                CGPointMake(self.xAxis.screenLocForScalar(barModel.axisValue2.scalar), constantScreenLoc))
        case false:
            return (
                CGPointMake(constantScreenLoc, self.yAxis.screenLocForScalar(barModel.axisValue1.scalar)),
                CGPointMake(constantScreenLoc, self.yAxis.screenLocForScalar(barModel.axisValue2.scalar)))
        }
    }
    
    func constantScreenLoc(barModel: T) -> CGFloat {
        return (self.horizontal ? self.yAxis : self.xAxis).screenLocForScalar(barModel.constant.scalar)
    }
    
    // constantScreenLoc: (screen) coordinate that is equal in p1 and p2 - for vertical bar this is the x coordinate, for horizontal bar this is the y coordinate
    func generateView(barModel: T, constantScreenLoc constantScreenLocMaybe: CGFloat? = nil, bgColor: UIColor?, animDuration: Float) -> ChartPointViewBar {
        
        let constantScreenLoc = constantScreenLocMaybe ?? self.constantScreenLoc(barModel)
        
        let viewPoints = self.viewPoints(barModel, constantScreenLoc: constantScreenLoc)
        return ChartPointViewBar(p1: viewPoints.p1, p2: viewPoints.p2, width: self.barWidth, bgColor: bgColor, animDuration: animDuration)
    }
}



public class ChartBarsLayer: ChartCoordsSpaceLayer {
    private let bars: [ChartBarModel]
    private let barWidth: CGFloat
    private let horizontal: Bool
    private let animDuration: Float

    private var barViews: [UIView] = []
    
    public init(xAxis: ChartAxis, yAxis: ChartAxis, innerFrame: CGRect, bars: [ChartBarModel], horizontal: Bool = false, barWidth: CGFloat, animDuration: Float) {
        self.bars = bars
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
        let barsGenerator = ChartBarsViewGenerator(horizontal: horizontal, xAxis: xAxis, yAxis: yAxis, chartInnerFrame: innerFrame, barWidth: barWidth)
        
        for barModel in bars {
            let barView = barsGenerator.generateView(barModel, bgColor: barModel.bgColor, animDuration: isTransform ? 0 : animDuration)
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
