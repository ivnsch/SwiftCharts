//
//  GroupedBarsCompanionsLayer.swift
//  SwiftCharts
//
//  Created by ischuetz on 07/10/16.
//  Copyright (c) 2016 ivanschuetz. All rights reserved.
//

import UIKit

/**
 Allows to add views to chart which require grouped bars position. E.g. a label on top of each bar.
 It works by holding a reference to the grouped bars layer and requesting the position of the bars on updates
 We use a custom layer, since screen position of a grouped bar can't be derived directly from the chart point it represents. We need other factors like the passed spacing parameters, the width of the other bars, etc. It seems convenient to implement an "observer" for current position of bars.
 NOTE: has to be passed to the chart after the grouped bars layer, in the layers array, in order to get its updated state.
 */
public class GroupedBarsCompanionsLayer<T: ChartPoint>: ChartPointsLayer<T> {
    
    public typealias CompanionViewGenerator = (barModel: ChartBarModel, barIndex: Int, barView: UIView, layer: GroupedBarsCompanionsLayer<T>, chart: Chart) -> UIView?
    
    public typealias PositionUpdater = (bar: ChartBarModel, barIndex: Int, viewIndex: Int, barView: UIView) -> CGRect
    
    private let groupedBarsLayer: ChartGroupedStackedBarsLayer
    
    private let viewGenerator: CompanionViewGenerator
    private let positionUpdater: PositionUpdater
    
    private let delayInit: Bool
    
    private var companionViews: [UIView] = []
    
    public init(xAxis: ChartAxis, yAxis: ChartAxis, viewGenerator: CompanionViewGenerator, positionUpdater: PositionUpdater, groupedBarsLayer: ChartGroupedStackedBarsLayer, displayDelay: Float = 0, delayInit: Bool = false) {
        
        self.groupedBarsLayer = groupedBarsLayer
        self.viewGenerator = viewGenerator
        self.delayInit = delayInit
        self.positionUpdater = positionUpdater
        
        super.init(xAxis: xAxis, yAxis: yAxis, chartPoints: [], displayDelay: displayDelay)
    }
    
    override public func display(chart chart: Chart) {
        super.display(chart: chart)
        if !delayInit {
            initViews(chart, applyDelay: false)
        }
    }
    
    private func initViews(chart: Chart) {
        for (group, barViews) in groupedBarsLayer.groupViews {
            
            for (barIndex, bar) in group.bars.enumerate() {
                
                let barView = barViews[barIndex]
                if let companionView = viewGenerator(barModel: bar, barIndex: barIndex, barView: barView, layer: self, chart: chart) {
                    chart.addSubviewNoTransform(companionView)
                    companionViews.append(companionView)
                }
            }
        }
    }
    
    public func initViews(chart: Chart, applyDelay: Bool = true) {
        if applyDelay {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(Double(displayDelay) * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) {() -> Void in
                self.initViews(chart)
            }
        } else {
            initViews(chart)
        }
    }
    
    private func updatePositions() {
        
        var viewIndex = 0
        
        for (group, barViews) in groupedBarsLayer.groupViews {
            
            for (barIndex, bar) in group.bars.enumerate() {
                let barView = barViews[barIndex]
                let newFrame = positionUpdater(bar: bar, barIndex: barIndex, viewIndex: viewIndex, barView: barView)
                if viewIndex < companionViews.count {
                    companionViews[viewIndex].frame = newFrame
                }
                
                viewIndex += 1
            }
        }
    }
    
    override public func zoom(x: CGFloat, y: CGFloat, centerX: CGFloat, centerY: CGFloat) {
        super.zoom(x, y: y, centerX: centerX, centerY: centerY)
        updatePositions()
    }
    
    override public func pan(deltaX: CGFloat, deltaY: CGFloat) {
        super.pan(deltaX, deltaY: deltaY)
        updatePositions()
    }
}
