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
    
    let viewGenerator: ChartBarsLayer<U>.ChartBarViewGenerator?
    
    init(horizontal: Bool, layer: ChartCoordsSpaceLayer, barWidth: CGFloat, viewGenerator: ChartBarsLayer<U>.ChartBarViewGenerator?) {
        self.layer = layer
        self.horizontal = horizontal
        self.barWidth = barWidth
        self.viewGenerator = viewGenerator
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
    
    func viewPoints(barModel: T, constantScreenLoc constantScreenLocMaybe: CGFloat? = nil) -> (p1: CGPoint, p2: CGPoint) {
        let constantScreenLoc = constantScreenLocMaybe ?? self.constantScreenLoc(barModel)
        return self.viewPoints(barModel, constantScreenLoc: constantScreenLoc)
    }
    
    func generateView(barModel: T, constantScreenLoc constantScreenLocMaybe: CGFloat? = nil, bgColor: UIColor?, settings: ChartBarViewSettings, model: ChartBarModel, index: Int, groupIndex: Int, chart: Chart? = nil) -> U {
        let viewPoints = self.viewPoints(barModel, constantScreenLoc: constantScreenLocMaybe)
        return viewGenerator?(p1: viewPoints.p1, p2: viewPoints.p2, width: self.barWidth, bgColor: bgColor, settings: settings, model: model, index: index) ??
            U(p1: viewPoints.p1, p2: viewPoints.p2, width: self.barWidth, bgColor: bgColor, settings: settings)
    }
}


public struct ChartTappedBar {
    public let model: ChartBarModel
    public let view: ChartPointViewBar
    public let layer: ChartCoordsSpaceLayer
}


public class ChartBarsLayer<T: ChartPointViewBar>: ChartCoordsSpaceLayer {
    
    public typealias ChartBarViewGenerator = (p1: CGPoint, p2: CGPoint, width: CGFloat, bgColor: UIColor?, settings: ChartBarViewSettings, model: ChartBarModel, index: Int) -> T
    
    private let bars: [ChartBarModel]
    private let barWidth: CGFloat
    private let horizontal: Bool
    private let settings: ChartBarViewSettings
    
    private var barViews: [(model: ChartBarModel, view: T)] = []
    
    private var tapHandler: (ChartTappedBar -> Void)?
    
    private var viewGenerator: ChartBarViewGenerator? // Custom bar views
    
    private let mode: ChartPointsViewsLayerMode
    
    private var barsGenerator: ChartBarsViewGenerator<ChartBarModel, T>?
    
    public init(xAxis: ChartAxis, yAxis: ChartAxis, bars: [ChartBarModel], horizontal: Bool = false, barWidth: CGFloat, settings: ChartBarViewSettings, mode: ChartPointsViewsLayerMode = .ScaleAndTranslate, tapHandler: (ChartTappedBar -> Void)? = nil, viewGenerator: ChartBarViewGenerator? = nil) {
        self.bars = bars
        self.horizontal = horizontal
        self.barWidth = barWidth
        self.settings = settings
        self.mode = mode
        self.tapHandler = tapHandler
        self.viewGenerator = viewGenerator
        
        super.init(xAxis: xAxis, yAxis: yAxis)
        
        self.barsGenerator = ChartBarsViewGenerator(horizontal: horizontal, layer: self, barWidth: barWidth, viewGenerator: viewGenerator)
    }
    
    public override func chartInitialized(chart chart: Chart) {
        super.chartInitialized(chart: chart)
        
        guard let barsGenerator = barsGenerator else {return}
        
        for (index, barModel) in bars.enumerate() {
            let barView = barsGenerator.generateView(barModel, bgColor: barModel.bgColor, settings: isTransform ? settings.copy(animDuration: 0, animDelay: 0) : settings, model: barModel, index: index, groupIndex: 0, chart: chart)
            barView.tapHandler = {[weak self] tappedBarView in guard let weakSelf = self else {return}
                weakSelf.tapHandler?(ChartTappedBar(model: barModel, view: tappedBarView, layer: weakSelf))
            }
        
            barViews.append((barModel, barView))
            
            addSubview(chart, view: barView)
        }
    }
    
    func addSubview(chart: Chart, view: UIView) {
        mode == .ScaleAndTranslate ? chart.addSubview(view) : chart.addSubviewNoTransform(view)
    }
    
    public override func zoom(x: CGFloat, y: CGFloat, centerX: CGFloat, centerY: CGFloat) {
        super.zoom(x, y: y, centerX: centerX, centerY: centerY)
        updateForTransform()
    }
    
    public override func pan(deltaX: CGFloat, deltaY: CGFloat) {
        super.pan(deltaX, deltaY: deltaY)
        updateForTransform()
    }
    
    func updateForTransform() {
        guard let barsGenerator = barsGenerator else {return}
        switch mode {
        case .ScaleAndTranslate:
            break
        case .Translate:
            for (barModel, barView) in barViews {
                let (p1, p2) = barsGenerator.viewPoints(barModel)
                barView.updateFrame(p1, p2: p2)
            }
        }
    }
    
    public override func modelLocToScreenLoc(x x: Double) -> CGFloat {
        switch mode {
        case .ScaleAndTranslate:
            return super.modelLocToScreenLoc(x: x)
        case .Translate:
            return super.modelLocToContainerScreenLoc(x: x)
        }
    }
    
    public override func modelLocToScreenLoc(y y: Double) -> CGFloat {
        switch mode {
        case .ScaleAndTranslate:
            return super.modelLocToScreenLoc(y: y)
        case .Translate:
            return super.modelLocToContainerScreenLoc(y: y)
        }
    }

}
