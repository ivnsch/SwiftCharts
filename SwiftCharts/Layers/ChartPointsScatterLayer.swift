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
    
    private let optimized: Bool
    
    required public init(xAxis: ChartAxis, yAxis: ChartAxis, chartPoints: [T], displayDelay: Float = 0, itemSize: CGSize, itemFillColor: UIColor, optimized: Bool, tapSettings: ChartPointsTapSettings<T>?) {
        self.itemSize = itemSize
        self.itemFillColor = itemFillColor
        self.optimized = optimized
        super.init(xAxis: xAxis, yAxis: yAxis, chartPoints: chartPoints, displayDelay: displayDelay, tapSettings: tapSettings)
    }
    
    override public func chartContentViewDrawing(context context: CGContextRef, chart: Chart) {
    }
    
    override public func chartDrawersContentViewDrawing(context context: CGContextRef, chart: Chart, view: UIView) {
        if !optimized {
            for chartPointModel in chartPointsModels {
                drawChartPointModel(context: context, chartPointModel: chartPointModel, view: view)
            }
        } else { // Generate CGLayer with shape only once and draw it at different positions.
            let contentScale = view.contentScaleFactor * 2
            guard let layer = generateCGLayer(context: context, view: view, contentScale: contentScale) else {return}
            
            let w = itemSize.width
            let h = itemSize.height
            
            for chartPointModel in chartPointsModels {
                let screenLoc = modelLocToScreenLoc(x: chartPointModel.chartPoint.x.scalar, y: chartPointModel.chartPoint.y.scalar)
                CGContextSaveGState(context)
                CGContextTranslateCTM(context, screenLoc.x, screenLoc.y)
                CGContextDrawLayerInRect(context, CGRectMake(-w / 2, -h / 2, w, h), layer)
                CGContextRestoreGState(context)
            }
        }
    }
    
    override func toLocalCoordinates(globalPoint: CGPoint) -> CGPoint? {
        return globalToDrawersContainerCoordinates(globalPoint)
    }
    
    public override func modelLocToScreenLoc(x x: Double) -> CGFloat {
        return xAxis.screenLocForScalar(x) - (chart?.containerFrame.origin.x ?? 0)
    }
    
    public override func modelLocToScreenLoc(y y: Double) -> CGFloat {
        return yAxis.screenLocForScalar(y) - (chart?.containerFrame.origin.y ?? 0)
    }
    
    public override func zoom(scaleX: CGFloat, scaleY: CGFloat, centerX: CGFloat, centerY: CGFloat) {
        chart?.drawersContentView.setNeedsDisplay()
    }
    
    public override func zoom(x: CGFloat, y: CGFloat, centerX: CGFloat, centerY: CGFloat) {
        chart?.drawersContentView.setNeedsDisplay()
    }
    
    public override func pan(deltaX: CGFloat, deltaY: CGFloat) {
        chart?.drawersContentView.setNeedsDisplay()
    }
    
    public func drawChartPointModel(context context: CGContextRef, chartPointModel: ChartPointLayerModel<T>, view: UIView) {
        fatalError("override")
    }
    
    public func updatePointLayer(chartPointModel: ChartPointLayerModel<T>) {
        fatalError("override")
    }
    
    func generateCGLayer(context context: CGContextRef, view: UIView, contentScale: CGFloat) -> CGLayer? {
        let scaledBounds = CGRectMake(0, 0, itemSize.width * contentScale, itemSize.height * contentScale)
        let layer = CGLayerCreateWithContext(context, scaledBounds.size, nil)
        let myLayerContext1 = CGLayerGetContext(layer)
        CGContextScaleCTM(myLayerContext1, contentScale, contentScale)
        return layer
    }
    
}

public class ChartPointsScatterTrianglesLayer<T: ChartPoint>: ChartPointsScatterLayer<T> {
    
    private let trianglePointsCG: [CGPoint]
    
    required public init(xAxis: ChartAxis, yAxis: ChartAxis, chartPoints: [T], displayDelay: Float = 0, itemSize: CGSize, itemFillColor: UIColor, optimized: Bool = true, tapSettings: ChartPointsTapSettings<T>? = nil) {
        trianglePointsCG = [CGPointMake(0, itemSize.height), CGPointMake(itemSize.width / 2, 0), CGPointMake(itemSize.width, itemSize.height), CGPointMake(0, itemSize.height)]
        super.init(xAxis: xAxis, yAxis: yAxis, chartPoints: chartPoints, displayDelay: displayDelay, itemSize: itemSize, itemFillColor: itemFillColor, optimized: optimized, tapSettings: tapSettings)
    }
    
    override func generateCGLayer(context context: CGContextRef, view: UIView, contentScale: CGFloat) -> CGLayer? {
        let layer = super.generateCGLayer(context: context, view: view, contentScale: contentScale)
        let layerContext = CGLayerGetContext(layer)
        
        CGContextSetFillColorWithColor(layerContext, itemFillColor.CGColor)
        CGContextAddLines(layerContext, trianglePointsCG, 4)
        CGContextFillPath(layerContext)
        
        return layer
    }
    
    override public func drawChartPointModel(context context: CGContextRef, chartPointModel: ChartPointLayerModel<T>, view: UIView) {
        
        let w = self.itemSize.width
        let h = self.itemSize.height
        
        let screenLoc = modelLocToScreenLoc(x: chartPointModel.chartPoint.x.scalar, y: chartPointModel.chartPoint.y.scalar)
        
        let path = CGPathCreateMutable()
        CGPathMoveToPoint(path, nil, screenLoc.x, screenLoc.y - h / 2)
        CGPathAddLineToPoint(path, nil, screenLoc.x + w / 2, screenLoc.y + h / 2)
        CGPathAddLineToPoint(path, nil, screenLoc.x - w / 2, screenLoc.y + h / 2)
        CGPathCloseSubpath(path)
        
        CGContextSetFillColorWithColor(context, self.itemFillColor.CGColor)
        CGContextAddPath(context, path)
        CGContextFillPath(context)
    }
}

public class ChartPointsScatterSquaresLayer<T: ChartPoint>: ChartPointsScatterLayer<T> {
    
    private let squarePointsCG: [CGPoint]
    
    required public init(xAxis: ChartAxis, yAxis: ChartAxis, chartPoints: [T], displayDelay: Float = 0, itemSize: CGSize, itemFillColor: UIColor, optimized: Bool = true, tapSettings: ChartPointsTapSettings<T>? = nil) {
        squarePointsCG = [CGPointMake(0, 0), CGPointMake(itemSize.width, 0), CGPointMake(itemSize.width, itemSize.height), CGPointMake(0, itemSize.height), CGPointMake(0, 0)]
        super.init(xAxis: xAxis, yAxis: yAxis, chartPoints: chartPoints, displayDelay: displayDelay, itemSize: itemSize, itemFillColor: itemFillColor, optimized: optimized, tapSettings: tapSettings)
    }
    
    override public func drawChartPointModel(context context: CGContextRef, chartPointModel: ChartPointLayerModel<T>, view: UIView) {
        
        let w = self.itemSize.width
        let h = self.itemSize.height

        let screenLoc = modelLocToScreenLoc(x: chartPointModel.chartPoint.x.scalar, y: chartPointModel.chartPoint.y.scalar)
        
        CGContextSetFillColorWithColor(context, self.itemFillColor.CGColor)
        CGContextFillRect(context, CGRectMake(screenLoc.x - w / 2, screenLoc.y - h / 2, w, h))
    }
    
    override func generateCGLayer(context context: CGContextRef, view: UIView, contentScale: CGFloat) -> CGLayer? {
        let layer = super.generateCGLayer(context: context, view: view, contentScale: contentScale)
        let layerContext = CGLayerGetContext(layer)

        CGContextSetFillColorWithColor(layerContext, itemFillColor.CGColor)
        CGContextFillRect(layerContext, CGRectMake(0, 0, itemSize.width, itemSize.height))
        CGContextFillPath(layerContext)
        
        return layer
    }
}

public class ChartPointsScatterCirclesLayer<T: ChartPoint>: ChartPointsScatterLayer<T> {
    
    required public init(xAxis: ChartAxis, yAxis: ChartAxis, chartPoints: [T], displayDelay: Float = 0, itemSize: CGSize, itemFillColor: UIColor, optimized: Bool = true, tapSettings: ChartPointsTapSettings<T>? = nil) {
        super.init(xAxis: xAxis, yAxis: yAxis, chartPoints: chartPoints, displayDelay: displayDelay, itemSize: itemSize, itemFillColor: itemFillColor, optimized: optimized, tapSettings: tapSettings)
    }
    
    override public func drawChartPointModel(context context: CGContextRef, chartPointModel: ChartPointLayerModel<T>, view: UIView) {
        let w = self.itemSize.width
        let h = self.itemSize.height
        
        let screenLoc = modelLocToScreenLoc(x: chartPointModel.chartPoint.x.scalar, y: chartPointModel.chartPoint.y.scalar)
        
        CGContextSetFillColorWithColor(context, self.itemFillColor.CGColor)
        CGContextFillEllipseInRect(context, CGRectMake(screenLoc.x - w / 2, screenLoc.y - h / 2, w, h))
    }
    
    override func generateCGLayer(context context: CGContextRef, view: UIView, contentScale: CGFloat) -> CGLayer? {
        let layer = super.generateCGLayer(context: context, view: view, contentScale: contentScale)
        let layerContext = CGLayerGetContext(layer)
        
        CGContextSetFillColorWithColor(layerContext, itemFillColor.CGColor)
        CGContextFillEllipseInRect(layerContext, CGRectMake(0, 0, itemSize.width, itemSize.height))
        CGContextFillPath(layerContext)
        
        return layer
    }
}

public class ChartPointsScatterCrossesLayer<T: ChartPoint>: ChartPointsScatterLayer<T> {
    
    public let strokeWidth: CGFloat
    
    private let line1PointsCG: [CGPoint]
    private let line2PointsCG: [CGPoint]
    
    required public init(xAxis: ChartAxis, yAxis: ChartAxis, chartPoints: [T], displayDelay: Float = 0, itemSize: CGSize, itemFillColor: UIColor, strokeWidth: CGFloat = 2, optimized: Bool = true, tapSettings: ChartPointsTapSettings<T>? = nil) {
        self.strokeWidth = strokeWidth
        line1PointsCG = [CGPointMake(0, 0), CGPointMake(itemSize.width, itemSize.height)]
        line2PointsCG = [CGPointMake(itemSize.width, 0), CGPointMake(0, itemSize.height)]
        super.init(xAxis: xAxis, yAxis: yAxis, chartPoints: chartPoints, displayDelay: displayDelay, itemSize: itemSize, itemFillColor: itemFillColor, optimized: optimized, tapSettings: tapSettings)
    }
    
    override public func drawChartPointModel(context context: CGContextRef, chartPointModel: ChartPointLayerModel<T>, view: UIView) {
        let w = self.itemSize.width
        let h = self.itemSize.height

        let screenLoc = modelLocToScreenLoc(x: chartPointModel.chartPoint.x.scalar, y: chartPointModel.chartPoint.y.scalar)
        
        func drawLine(p1X: CGFloat, p1Y: CGFloat, p2X: CGFloat, p2Y: CGFloat) {
            CGContextSetStrokeColorWithColor(context, self.itemFillColor.CGColor)
            CGContextSetLineWidth(context, self.strokeWidth)
            CGContextMoveToPoint(context, p1X, p1Y)
            CGContextAddLineToPoint(context, p2X, p2Y)
            CGContextStrokePath(context)
        }
        
        drawLine(screenLoc.x - w / 2, p1Y: screenLoc.y - h / 2, p2X: screenLoc.x + w / 2, p2Y: screenLoc.y + h / 2)
        drawLine(screenLoc.x + w / 2, p1Y: screenLoc.y - h / 2, p2X: screenLoc.x - w / 2, p2Y: screenLoc.y + h / 2)
    }
    
    override func generateCGLayer(context context: CGContextRef, view: UIView, contentScale: CGFloat) -> CGLayer? {
        let layer = super.generateCGLayer(context: context, view: view, contentScale: contentScale)
        let layerContext = CGLayerGetContext(layer)

        CGContextSetStrokeColorWithColor(context, itemFillColor.CGColor)
        CGContextSetLineWidth(context, strokeWidth)
        
        CGContextAddLines(layerContext, line1PointsCG, 2)
        CGContextAddLines(layerContext, line2PointsCG, 2)
        
        CGContextStrokePath(layerContext)
        
        return layer
    }
}
