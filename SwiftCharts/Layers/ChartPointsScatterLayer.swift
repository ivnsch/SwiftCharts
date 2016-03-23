//
//  ChartPointsScatterLayer.swift
//  Examples
//
//  Created by ischuetz on 17/05/15.
//  Copyright (c) 2015 ivanschuetz. All rights reserved.
//

import UIKit

public class ChartPointsScatterLayer<T: ChartPoint>: ChartPointsLayer<T> {

    public let itemSize: CGSize
    public let itemFillColor: UIColor
    
    required public init(xAxis: ChartAxisLayer, yAxis: ChartAxisLayer, innerFrame: CGRect, chartPoints: [T], displayDelay: Float = 0, itemSize: CGSize, itemFillColor: UIColor) {
        self.itemSize = itemSize
        self.itemFillColor = itemFillColor
        super.init(xAxis: xAxis, yAxis: yAxis, innerFrame: innerFrame, chartPoints: chartPoints, displayDelay: displayDelay)
    }
    
    override public func chartViewDrawing(context context: CGContextRef, chart: Chart) {
        for chartPointModel in self.chartPointsModels {
            self.drawChartPointModel(context: context, chartPointModel: chartPointModel)
        }
    }
    
    public func drawChartPointModel(context context: CGContextRef, chartPointModel: ChartPointLayerModel<T>) {
        fatalError("override")
    }
}

public class ChartPointsScatterTrianglesLayer<T: ChartPoint>: ChartPointsScatterLayer<T> {
    
    required public init(xAxis: ChartAxisLayer, yAxis: ChartAxisLayer, innerFrame: CGRect, chartPoints: [T], displayDelay: Float = 0, itemSize: CGSize, itemFillColor: UIColor) {
        super.init(xAxis: xAxis, yAxis: yAxis, innerFrame: innerFrame, chartPoints: chartPoints, displayDelay: displayDelay, itemSize: itemSize, itemFillColor: itemFillColor)
    }
    
    override public func drawChartPointModel(context context: CGContextRef, chartPointModel: ChartPointLayerModel<T>) {
        let w = self.itemSize.width
        let h = self.itemSize.height
        
        let path = CGPathCreateMutable()
        CGPathMoveToPoint(path, nil, chartPointModel.screenLoc.x, chartPointModel.screenLoc.y - h / 2)
        CGPathAddLineToPoint(path, nil, chartPointModel.screenLoc.x + w / 2, chartPointModel.screenLoc.y + h / 2)
        CGPathAddLineToPoint(path, nil, chartPointModel.screenLoc.x - w / 2, chartPointModel.screenLoc.y + h / 2)
        CGPathCloseSubpath(path)
        
        CGContextSetFillColorWithColor(context, self.itemFillColor.CGColor)
        CGContextAddPath(context, path)
        CGContextFillPath(context)
    }
}

public class ChartPointsScatterSquaresLayer<T: ChartPoint>: ChartPointsScatterLayer<T> {
    
    required public init(xAxis: ChartAxisLayer, yAxis: ChartAxisLayer, innerFrame: CGRect, chartPoints: [T], displayDelay: Float = 0, itemSize: CGSize, itemFillColor: UIColor) {
        super.init(xAxis: xAxis, yAxis: yAxis, innerFrame: innerFrame, chartPoints: chartPoints, displayDelay: displayDelay, itemSize: itemSize, itemFillColor: itemFillColor)
    }
    
    override public func drawChartPointModel(context context: CGContextRef, chartPointModel: ChartPointLayerModel<T>) {
        let w = self.itemSize.width
        let h = self.itemSize.height
        
        CGContextSetFillColorWithColor(context, self.itemFillColor.CGColor)
        CGContextFillRect(context, CGRectMake(chartPointModel.screenLoc.x - w / 2, chartPointModel.screenLoc.y - h / 2, w, h))
    }
}

public class ChartPointsScatterCirclesLayer<T: ChartPoint>: ChartPointsScatterLayer<T> {
    
    required public init(xAxis: ChartAxisLayer, yAxis: ChartAxisLayer, innerFrame: CGRect, chartPoints: [T], displayDelay: Float = 0, itemSize: CGSize, itemFillColor: UIColor) {
        super.init(xAxis: xAxis, yAxis: yAxis, innerFrame: innerFrame, chartPoints: chartPoints, displayDelay: displayDelay, itemSize: itemSize, itemFillColor: itemFillColor)
    }
    
    override public func drawChartPointModel(context context: CGContextRef, chartPointModel: ChartPointLayerModel<T>) {
        let w = self.itemSize.width
        let h = self.itemSize.height
        
        CGContextSetFillColorWithColor(context, self.itemFillColor.CGColor)
        CGContextFillEllipseInRect(context, CGRectMake(chartPointModel.screenLoc.x - w / 2, chartPointModel.screenLoc.y - h / 2, w, h))
    }
}

public class ChartPointsScatterCrossesLayer<T: ChartPoint>: ChartPointsScatterLayer<T> {
    
    public let strokeWidth: CGFloat
    
    required public init(xAxis: ChartAxisLayer, yAxis: ChartAxisLayer, innerFrame: CGRect, chartPoints: [T], displayDelay: Float = 0, itemSize: CGSize, itemFillColor: UIColor, strokeWidth: CGFloat = 2) {
        self.strokeWidth = strokeWidth
        super.init(xAxis: xAxis, yAxis: yAxis, innerFrame: innerFrame, chartPoints: chartPoints, displayDelay: displayDelay, itemSize: itemSize, itemFillColor: itemFillColor)
    }
    
    override public func drawChartPointModel(context context: CGContextRef, chartPointModel: ChartPointLayerModel<T>) {
        let w = self.itemSize.width
        let h = self.itemSize.height
        
        func drawLine(p1X: CGFloat, p1Y: CGFloat, p2X: CGFloat, p2Y: CGFloat) {
            CGContextSetStrokeColorWithColor(context, self.itemFillColor.CGColor)
            CGContextSetLineWidth(context, self.strokeWidth)
            CGContextMoveToPoint(context, p1X, p1Y)
            CGContextAddLineToPoint(context, p2X, p2Y)
            CGContextStrokePath(context)
        }

        drawLine(chartPointModel.screenLoc.x - w / 2, p1Y: chartPointModel.screenLoc.y - h / 2, p2X: chartPointModel.screenLoc.x + w / 2, p2Y: chartPointModel.screenLoc.y + h / 2)
        drawLine(chartPointModel.screenLoc.x + w / 2, p1Y: chartPointModel.screenLoc.y - h / 2, p2X: chartPointModel.screenLoc.x - w / 2, p2Y: chartPointModel.screenLoc.y + h / 2)
    }
}
