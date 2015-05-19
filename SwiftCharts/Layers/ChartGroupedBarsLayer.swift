//
//  ChartGroupedBarsLayer.swift
//  Examples
//
//  Created by ischuetz on 19/05/15.
//  Copyright (c) 2015 ivanschuetz. All rights reserved.
//

import UIKit

public final class ChartPointsBarGroup {
    let constant: ChartAxisValue
    let bars: [ChartPointsBar]
    
    public init(constant: ChartAxisValue, bars: [ChartPointsBar]) {
        self.constant = constant
        self.bars = bars
    }
}


public class ChartGroupedBarsLayer: ChartCoordsSpaceLayer {
    
    private let groups: [ChartPointsBarGroup]
    
    private let barSpacing: CGFloat?
    private let groupSpacing: CGFloat?
    
    private let horizontal: Bool
    
    public init(xAxis: ChartAxisLayer, yAxis: ChartAxisLayer, innerFrame: CGRect, groups: [ChartPointsBarGroup], horizontal: Bool = false, barSpacing: CGFloat?, groupSpacing: CGFloat?) {
        self.groups = groups
        self.horizontal = horizontal
        self.barSpacing = barSpacing
        self.groupSpacing = groupSpacing
        
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
        
        let axis = self.horizontal ? self.yAxis : self.xAxis
        let groupAvailableLength = (axis.length  - (self.groupSpacing ?? 0) * CGFloat(self.groups.count)) / CGFloat(groups.count + 1)
        let maxBarCountInGroup = self.groups.reduce(CGFloat(0)) {maxCount, group in
            max(maxCount, CGFloat(group.bars.count))
        }
        
        let width = ((groupAvailableLength - ((self.barSpacing ?? 0) * (maxBarCountInGroup - 1))) / CGFloat(maxBarCountInGroup))
        
        let calculateVarCoord: (axis: ChartAxisLayer, index: Int, group: ChartPointsBarGroup) -> CGFloat = {axis, index, group in
            let totalWidth = CGFloat(group.bars.count) * width + ((self.barSpacing ?? 0) * (maxBarCountInGroup - 1))
            let groupCenter = axis.screenLocForScalar(group.constant.scalar)
            let origin = groupCenter - totalWidth / 2
            return origin + CGFloat(index) * (width + (self.barSpacing ?? 0)) + width / 2
        }
        
        for group in self.groups {

            for (index, bar) in enumerate(group.bars) {
                
                let (p1: CGPoint, p2: CGPoint) = {
                    if self.horizontal {
                        let barY = calculateVarCoord(axis: self.yAxis, index: index, group: group)
                        return (
                            CGPointMake(self.xAxis.screenLocForScalar(bar.axisValue1.scalar), barY),
                            CGPointMake(self.xAxis.screenLocForScalar(bar.axisValue2.scalar), barY)
                        )
                        
                    } else {
                        let barX = calculateVarCoord(axis: self.xAxis, index: index, group: group)
                        return (
                            CGPointMake(barX, self.yAxis.screenLocForScalar(bar.axisValue1.scalar)),
                            CGPointMake(barX, self.yAxis.screenLocForScalar(bar.axisValue2.scalar))
                        )
                    }
                }()
                
                chart.addSubview(ChartPointViewBar(p1: p1, p2: p2, width: width, bgColor: bar.bgColor, animDuration: 0.5))
            }
        }
    }
}
