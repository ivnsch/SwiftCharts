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

class ChartBarsViewGenerator<T: ChartBarModel, U: ChartPointViewBar> {
    let layer: ChartCoordsSpaceLayer
    let barWidth: CGFloat
    
    let horizontal: Bool
    
    init(horizontal: Bool, layer: ChartCoordsSpaceLayer, barWidth: CGFloat) {
        self.layer = layer
        self.horizontal = horizontal
        self.barWidth = barWidth
    }
    
    func viewPoints(barModel: T, constantScreenLoc: CGFloat) -> (p1: CGPoint, p2: CGPoint) {

        
        switch self.horizontal {
        case true:
            return (
                CGPointMake(layer.modelLocToScreenLoc(x: barModel.axisValue1.scalar), constantScreenLoc),
                CGPointMake(layer.modelLocToScreenLoc(x: barModel.axisValue2.scalar), constantScreenLoc))
        case false:
            return (
                CGPointMake(constantScreenLoc, layer.modelLocToScreenLoc(y: barModel.axisValue1.scalar)),
                CGPointMake(constantScreenLoc, layer.modelLocToScreenLoc(y: barModel.axisValue2.scalar)))
        }
    }
    
    func constantScreenLoc(barModel: T) -> CGFloat {
        return horizontal ? layer.modelLocToScreenLoc(y: barModel.constant.scalar) : layer.modelLocToScreenLoc(x: barModel.constant.scalar)
    }
    
    // constantScreenLoc: (screen) coordinate that is equal in p1 and p2 - for vertical bar this is the x coordinate, for horizontal bar this is the y coordinate
    func generateView(barModel: T, constantScreenLoc constantScreenLocMaybe: CGFloat? = nil, bgColor: UIColor?, animDuration: Float, chart: Chart? = nil) -> U {
        
        let constantScreenLoc = constantScreenLocMaybe ?? self.constantScreenLoc(barModel)
        
        let viewPoints = self.viewPoints(barModel, constantScreenLoc: constantScreenLoc)
        return U(p1: viewPoints.p1, p2: viewPoints.p2, width: self.barWidth, bgColor: bgColor, animDuration: animDuration)
    }
}


public struct ChartTappedBar {
    public let model: ChartBarModel
    public let view: ChartPointViewBar
    public let layer: ChartCoordsSpaceLayer
}

public class ChartBarsLayer: ChartCoordsSpaceLayer {
    private let bars: [ChartBarModel]
    private let barWidth: CGFloat
    private let horizontal: Bool
    private let animDuration: Float

    private var barViews: [UIView] = []
    
    private var tapHandler: (ChartTappedBar -> Void)?
    
    public init(xAxis: ChartAxis, yAxis: ChartAxis, bars: [ChartBarModel], horizontal: Bool = false, barWidth: CGFloat, animDuration: Float, tapHandler: (ChartTappedBar -> Void)? = nil) {
        self.bars = bars
        self.horizontal = horizontal
        self.barWidth = barWidth
        self.animDuration = animDuration
        self.tapHandler = tapHandler
        
        super.init(xAxis: xAxis, yAxis: yAxis)
    }
    
    public override func chartInitialized(chart chart: Chart) {
        super.chartInitialized(chart: chart)
        
        let barsGenerator = ChartBarsViewGenerator(horizontal: horizontal, layer: self, barWidth: barWidth)
        
        for barModel in bars {
            let barView = barsGenerator.generateView(barModel, bgColor: barModel.bgColor, animDuration: isTransform ? 0 : animDuration, chart: chart)
            barView.tapHandler = {[weak self] tappedBarView in guard let weakSelf = self else {return}
                weakSelf.tapHandler?(ChartTappedBar(model: barModel, view: tappedBarView, layer: weakSelf))
            }
        
            barViews.append(barView)
            chart.addSubview(barView)
        }
    }
}
