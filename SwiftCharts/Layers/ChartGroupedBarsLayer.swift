//
//  ChartGroupedBarsLayer.swift
//  Examples
//
//  Created by ischuetz on 19/05/15.
//  Copyright (c) 2015 ivanschuetz. All rights reserved.
//

import UIKit

public final class ChartPointsBarGroup<T: ChartBarModel> {
    let constant: ChartAxisValue
    let bars: [T]
    
    public init(constant: ChartAxisValue, bars: [T]) {
        self.constant = constant
        self.bars = bars
    }
}


public class ChartGroupedBarsLayer<T: ChartBarModel>: ChartCoordsSpaceLayer {

    private let groups: [ChartPointsBarGroup<T>]
    
    private let barSpacing: CGFloat?
    private let groupSpacing: CGFloat?
    
    private let horizontal: Bool
    
    private let animDuration: Float

    private var barViews: [UIView] = []
    
    init(xAxis: ChartAxis, yAxis: ChartAxis, groups: [ChartPointsBarGroup<T>], horizontal: Bool = false, barSpacing: CGFloat?, groupSpacing: CGFloat?, animDuration: Float) {
        self.groups = groups
        self.horizontal = horizontal
        self.barSpacing = barSpacing
        self.groupSpacing = groupSpacing
        self.animDuration = animDuration
        
        super.init(xAxis: xAxis, yAxis: yAxis)
    }
    
    func barsGenerator(barWidth barWidth: CGFloat, chart: Chart) -> ChartBarsViewGenerator<T> {
        fatalError("override")
    }
    
    public override func chartInitialized(chart chart: Chart) {
        super.chartInitialized(chart: chart)
        
        let axis = self.horizontal ? self.yAxis : self.xAxis
        let groupAvailableLength = (axis.screenLength  - (self.groupSpacing ?? 0) * CGFloat(self.groups.count)) / CGFloat(groups.count + 1)
        let maxBarCountInGroup = self.groups.reduce(CGFloat(0)) {maxCount, group in
            max(maxCount, CGFloat(group.bars.count))
        }
        
        let barWidth = ((groupAvailableLength - ((self.barSpacing ?? 0) * (maxBarCountInGroup - 1))) / CGFloat(maxBarCountInGroup))
        
        let barsGenerator = self.barsGenerator(barWidth: barWidth, chart: chart)
        
        let calculateConstantScreenLoc: (axis: ChartAxis, index: Int, group: ChartPointsBarGroup<T>) -> CGFloat = {axis, index, group in
            let totalWidth = CGFloat(group.bars.count) * barWidth + ((self.barSpacing ?? 0) * (maxBarCountInGroup - 1))
            let groupCenter = axis.innerScreenLocForScalar(group.constant.scalar)
            let origin = groupCenter - totalWidth / 2
            return origin + CGFloat(index) * (barWidth + (self.barSpacing ?? 0)) + barWidth / 2
        }
        
        for group in self.groups {
            
            for (index, bar) in group.bars.enumerate() {
                
                let constantScreenLoc: CGFloat = {
                    if barsGenerator.horizontal {
                        return calculateConstantScreenLoc(axis: self.yAxis, index: index, group: group)
                    } else {
                        return calculateConstantScreenLoc(axis: self.xAxis, index: index, group: group)
                    }
                }()
                let barView = barsGenerator.generateView(bar, constantScreenLoc: constantScreenLoc, bgColor: bar.bgColor, animDuration: isTransform ? 0 : animDuration)
                barViews.append(barView)
                chart.addSubview(barView)
            }
        }
    }
}



public typealias ChartGroupedPlainBarsLayer = ChartGroupedPlainBarsLayer_<Any>
public class ChartGroupedPlainBarsLayer_<N>: ChartGroupedBarsLayer<ChartBarModel> {

    public override init(xAxis: ChartAxis, yAxis: ChartAxis, groups: [ChartPointsBarGroup<ChartBarModel>], horizontal: Bool, barSpacing: CGFloat?, groupSpacing: CGFloat?, animDuration: Float) {
        super.init(xAxis: xAxis, yAxis: yAxis, groups: groups, horizontal: horizontal, barSpacing: barSpacing, groupSpacing: groupSpacing, animDuration: animDuration)
    }
    
    override func barsGenerator(barWidth barWidth: CGFloat, chart: Chart) -> ChartBarsViewGenerator<ChartBarModel> {
        return ChartBarsViewGenerator(horizontal: self.horizontal, xAxis: self.xAxis, yAxis: self.yAxis, barWidth: barWidth)
    }
}

public typealias ChartGroupedStackedBarsLayer = ChartGroupedStackedBarsLayer_<Any>
public class ChartGroupedStackedBarsLayer_<N>: ChartGroupedBarsLayer<ChartStackedBarModel> {
    
    public override init(xAxis: ChartAxis, yAxis: ChartAxis, groups: [ChartPointsBarGroup<ChartStackedBarModel>], horizontal: Bool, barSpacing: CGFloat?, groupSpacing: CGFloat?, animDuration: Float) {
        super.init(xAxis: xAxis, yAxis: yAxis, groups: groups, horizontal: horizontal, barSpacing: barSpacing, groupSpacing: groupSpacing, animDuration: animDuration)
    }
    
    override func barsGenerator(barWidth barWidth: CGFloat, chart: Chart) -> ChartBarsViewGenerator<ChartStackedBarModel> {
        return ChartStackedBarsViewGenerator(horizontal: horizontal, xAxis: xAxis, yAxis: yAxis, barWidth: barWidth)
    }
}