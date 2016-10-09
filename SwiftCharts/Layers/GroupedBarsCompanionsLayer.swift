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
 We use a custom layer, since screen position of a grouped bar can't be derived directly from the chart point it represents. We need other factors like the passed spacing parameters, the width of the bars, etc. It seems convenient to implement an "observer" for current position of bars.
 NOTE: has to be passed to the chart after the grouped bars layer, in the layers array, in order to get its updated state.
 */
public class GroupedBarsCompanionsLayer<U: UIView>: ChartPointsLayer<ChartPoint> {
    
    public typealias CompanionViewGenerator = (barModel: ChartBarModel, barIndex: Int, viewIndex: Int, barView: UIView, layer: GroupedBarsCompanionsLayer<U>, chart: Chart) -> U?
    
    public typealias ViewUpdater = (barModel: ChartBarModel, barIndex: Int, viewIndex: Int, barView: UIView, layer: GroupedBarsCompanionsLayer<U>, chart: Chart, companionView: U) -> Void
    
    private let groupedBarsLayer: ChartGroupedStackedBarsLayer
    
    private let viewGenerator: CompanionViewGenerator
    private let viewUpdater: ViewUpdater
    
    private let delayInit: Bool
    
    private var companionViews: [U] = []
    
    public init(xAxis: ChartAxis, yAxis: ChartAxis, viewGenerator: CompanionViewGenerator, viewUpdater: ViewUpdater, groupedBarsLayer: ChartGroupedStackedBarsLayer, displayDelay: Float = 0, delayInit: Bool = false) {
        
        self.groupedBarsLayer = groupedBarsLayer
        self.viewGenerator = viewGenerator
        self.delayInit = delayInit
        self.viewUpdater = viewUpdater
        
        super.init(xAxis: xAxis, yAxis: yAxis, chartPoints: [], displayDelay: displayDelay)
    }
    
    override public func display(chart chart: Chart) {
        super.display(chart: chart)
        if !delayInit {
            initViews(chart, applyDelay: false)
        }
    }
    
    private func initViews(chart: Chart) {
        iterateBars {[weak self] (barModel, barIndex, viewIndex, barView) in guard let weakSelf = self else {return}
            if let companionView = weakSelf.viewGenerator(barModel: barModel, barIndex: barIndex, viewIndex: viewIndex, barView: barView, layer: weakSelf, chart: chart) {
                chart.addSubviewNoTransform(companionView)
                weakSelf.companionViews.append(companionView)
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
        
        guard let chart = chart else {return}
        
        iterateBars {[weak self] (barModel, barIndex, viewIndex, barView) in guard let weakSelf = self else {return}
            if viewIndex < weakSelf.companionViews.count {
                let companionView = weakSelf.companionViews[viewIndex]
                weakSelf.viewUpdater(barModel: barModel, barIndex: barIndex, viewIndex: viewIndex, barView: barView, layer: weakSelf, chart: chart, companionView: companionView)
            }
        }
    }
    
    private func iterateBars(f: (barModel: ChartBarModel, barIndex: Int, viewIndex: Int, barView: UIView) -> Void) {
        var viewIndex = 0
        for (group, barViews) in groupedBarsLayer.groupViews {
            for (barIndex, barModel) in group.bars.enumerate() {
                f(barModel: barModel, barIndex: barIndex, viewIndex: viewIndex, barView: barViews[barIndex])
                viewIndex += 1
            }
        }
    }
    
    public override func handlePanFinish() {
        super.handlePanEnd()
        updatePositions()
    }
    
    public override func handleZoomFinish() {
        super.handleZoomEnd()
        updatePositions()
    }
}
