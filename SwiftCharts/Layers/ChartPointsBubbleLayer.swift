//
//  ChartPointsBubbleLayer.swift
//  Examples
//
//  Created by ischuetz on 16/05/15.
//  Copyright (c) 2015 ivanschuetz. All rights reserved.
//

import UIKit

public class ChartPointsBubbleLayer<T: ChartPointBubble>: ChartPointsLayer<T> {
    
    private let diameterFactor: Double
    
    public init(xAxis: ChartAxisLayer, yAxis: ChartAxisLayer, innerFrame: CGRect, chartPoints: [T], displayDelay: Float = 0, maxBubbleDiameter: Double = 30, minBubbleDiameter: Double = 2) {
        
        let (minDiameterScalar, maxDiameterScalar): (Double, Double) = chartPoints.reduce((min: 0, max: 0)) {tuple, chartPoint in
            (min: min(tuple.min, chartPoint.diameterScalar), max: max(tuple.max, chartPoint.diameterScalar))
        }
        
        self.diameterFactor = (maxBubbleDiameter - minBubbleDiameter) / (maxDiameterScalar - minDiameterScalar)

        super.init(xAxis: xAxis, yAxis: yAxis, innerFrame: innerFrame, chartPoints: chartPoints, displayDelay: displayDelay)
    }
    
    override public func chartViewDrawing(context context: CGContextRef, chart: Chart) {

        for chartPointModel in self.chartPointsModels {

            CGContextSetLineWidth(context, 1.0)
            CGContextSetStrokeColorWithColor(context, chartPointModel.chartPoint.borderColor.CGColor)
            CGContextSetFillColorWithColor(context, chartPointModel.chartPoint.bgColor.CGColor)
            
            let diameter = CGFloat(chartPointModel.chartPoint.diameterScalar * diameterFactor)
            let circleRect = (CGRectMake(chartPointModel.screenLoc.x - diameter / 2, chartPointModel.screenLoc.y - diameter / 2, diameter, diameter))
            
            CGContextFillEllipseInRect(context, circleRect)
            CGContextStrokeEllipseInRect(context, circleRect)
        }
    }
}
