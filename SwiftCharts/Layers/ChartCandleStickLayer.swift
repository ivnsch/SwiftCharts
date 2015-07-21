//
//  ChartCandleStickLayer.swift
//  SwiftCharts
//
//  Created by ischuetz on 28/04/15.
//  Copyright (c) 2015 ivanschuetz. All rights reserved.
//

import UIKit

public class ChartCandleStickLayer<T: ChartPointCandleStick>: ChartPointsLayer<T> {
    
    private var screenItems: [CandleStickScreenItem] = []

    private let itemWidth: CGFloat
    private let strokeWidth: CGFloat
    
    public init(xAxis: ChartAxisLayer, yAxis: ChartAxisLayer, innerFrame: CGRect, chartPoints: [T], itemWidth: CGFloat = 10, strokeWidth: CGFloat = 1) {
        self.itemWidth = itemWidth
        self.strokeWidth = strokeWidth
        
        super.init(xAxis: xAxis, yAxis: yAxis, innerFrame: innerFrame, chartPoints: chartPoints)
        
        self.screenItems = self.chartPointsModels.map {model in
            
            let chartPoint = model.chartPoint
            
            let x = model.screenLoc.x

            let highScreenY = self.modelLocToScreenLoc(x: Double(x), y: Double(chartPoint.high)).y
            let lowScreenY = self.modelLocToScreenLoc(x: Double(x), y: Double(chartPoint.low)).y
            let openScreenY = self.modelLocToScreenLoc(x: Double(x), y: Double(chartPoint.open)).y
            let closeScreenY = self.modelLocToScreenLoc(x: Double(x), y: Double(chartPoint.close)).y
            
            let (rectTop, rectBottom, fillColor) = closeScreenY < openScreenY ? (closeScreenY, openScreenY, UIColor.whiteColor()) : (openScreenY, closeScreenY, UIColor.blackColor())
            return CandleStickScreenItem(x: x, lineTop: highScreenY, lineBottom: lowScreenY, rectTop: rectTop, rectBottom: rectBottom, width: self.itemWidth, fillColor: fillColor)
        }
    }

    override public func chartViewDrawing(context context: CGContextRef, chart: Chart) {
        
        for screenItem in self.screenItems {
            
            CGContextSetLineWidth(context, self.strokeWidth)
            CGContextSetStrokeColorWithColor(context, UIColor.blackColor().CGColor)
            CGContextMoveToPoint(context, screenItem.x, screenItem.lineTop)
            CGContextAddLineToPoint(context, screenItem.x, screenItem.lineBottom)
            CGContextStrokePath(context)
            
            CGContextSetRGBFillColor(context, 1.0, 1.0, 1.0, 0.0)
            CGContextSetFillColorWithColor(context, screenItem.fillColor.CGColor)
            CGContextFillRect(context, screenItem.rect)
            CGContextStrokeRect(context, screenItem.rect)
        }
    }
}


private struct CandleStickScreenItem {
    let x: CGFloat
    let lineTop: CGFloat
    let lineBottom: CGFloat
    let fillColor: UIColor
    let rect: CGRect
    
    init(x: CGFloat, lineTop: CGFloat, lineBottom: CGFloat, rectTop: CGFloat, rectBottom: CGFloat, width: CGFloat, fillColor: UIColor) {
        self.x = x
        self.lineTop = lineTop
        self.lineBottom = lineBottom
        self.rect = CGRectMake(x - (width / 2), rectTop, width, rectBottom - rectTop)
        self.fillColor = fillColor
    }
    
}
