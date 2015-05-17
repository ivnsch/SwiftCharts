//
//  ChartBarsLayer.swift
//  Examples
//
//  Created by ischuetz on 17/05/15.
//  Copyright (c) 2015 ivanschuetz. All rights reserved.
//

import UIKit

public final class ChartPointsBar {
    let constant: ChartAxisValue
    let axisValue1: ChartAxisValue
    let axisValue2: ChartAxisValue
    let bgColor: UIColor
    
    public init(constant: ChartAxisValue, axisValue1: ChartAxisValue, axisValue2: ChartAxisValue, bgColor: UIColor) {
        self.constant = constant
        self.axisValue1 = axisValue1
        self.axisValue2 = axisValue2
        self.bgColor = bgColor
    }
}

// TODO refactor with ChartStackedBarsLayer
public class ChartBarsLayer: ChartCoordsSpaceLayer {
    
    private let bars: [ChartPointsBar]
    
    private let barWidth: CGFloat?
    private let barSpacing: CGFloat?
    
    private let horizontal: Bool
    
    public convenience init(xAxis: ChartAxisLayer, yAxis: ChartAxisLayer, innerFrame: CGRect, bars: [ChartPointsBar], horizontal: Bool = false, barWidth: CGFloat) {
        self.init(xAxis: xAxis, yAxis: yAxis, innerFrame: innerFrame, bars: bars, horizontal: horizontal, barWidth: barWidth, barSpacing: nil)
    }
    
    public convenience init(xAxis: ChartAxisLayer, yAxis: ChartAxisLayer, innerFrame: CGRect, bars: [ChartPointsBar], horizontal: Bool = false, barSpacing: CGFloat) {
        self.init(xAxis: xAxis, yAxis: yAxis, innerFrame: innerFrame, bars: bars, horizontal: horizontal, barWidth: nil, barSpacing: barSpacing)
    }
    
    private init(xAxis: ChartAxisLayer, yAxis: ChartAxisLayer, innerFrame: CGRect, bars: [ChartPointsBar], horizontal: Bool = false, barWidth: CGFloat? = nil, barSpacing: CGFloat?) {
        self.bars = bars
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
        
        for bar in self.bars {
            let (p1: CGPoint, p2: CGPoint) = {
                if self.horizontal {
                    let constant = self.yAxis.screenLocForScalar(bar.constant.scalar)
                    return (
                        CGPointMake(self.xAxis.screenLocForScalar(bar.axisValue1.scalar), constant),
                        CGPointMake(self.xAxis.screenLocForScalar(bar.axisValue2.scalar), constant)
                    )
                    
                } else {
                    let constant = self.xAxis.screenLocForScalar(bar.constant.scalar)
                    return (
                        CGPointMake(constant, self.yAxis.screenLocForScalar(bar.axisValue1.scalar)),
                        CGPointMake(constant, self.yAxis.screenLocForScalar(bar.axisValue2.scalar))
                    )
                }
            }()
            
            chart.addSubview(ChartPointViewBar(p1: p1, p2: p2, width: barWidth, bgColor: bar.bgColor, animDuration: 0.5))
        }
    }
}
