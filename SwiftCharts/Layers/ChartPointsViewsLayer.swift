//
//  ChartPointsViewsLayer.swift
//  SwiftCharts
//
//  Created by ischuetz on 27/04/15.
//  Copyright (c) 2015 ivanschuetz. All rights reserved.
//

import UIKit

public enum ChartPointsViewsLayerMode {
    case scaleAndTranslate, translate
}

open class ChartPointsViewsLayer<T: ChartPoint, U: UIView>: ChartPointsLayer<T> {

    public typealias ChartPointViewGenerator = (_ chartPointModel: ChartPointLayerModel<T>, _ layer: ChartPointsViewsLayer<T, U>, _ chart: Chart, _ isTransform: Bool) -> U?
    public typealias ViewWithChartPoint = (view: U, chartPointModel: ChartPointLayerModel<T>)
    
    open fileprivate(set) var viewsWithChartPoints: [ViewWithChartPoint] = []
    
    fileprivate let delayBetweenItems: Float = 0
    
    let viewGenerator: ChartPointViewGenerator
    
    fileprivate var conflictSolver: ChartViewsConflictSolver<T, U>?
    
    fileprivate let mode: ChartPointsViewsLayerMode
    
    // For cases when layers behind re-add subviews on pan/zoom, ensure views of this layer stays on front
    // TODO z ordering
    fileprivate let keepOnFront: Bool
    
    fileprivate let delayInit: Bool
    
    public init(xAxis: ChartAxis, yAxis: ChartAxis, chartPoints:[T], viewGenerator: @escaping ChartPointViewGenerator, conflictSolver: ChartViewsConflictSolver<T, U>? = nil, displayDelay: Float = 0, delayBetweenItems: Float = 0, mode: ChartPointsViewsLayerMode = .scaleAndTranslate, keepOnFront: Bool = true, delayInit: Bool = false) {
        self.viewGenerator = viewGenerator
        self.conflictSolver = conflictSolver
        self.mode = mode
        self.keepOnFront = keepOnFront
        self.delayInit = delayInit
        super.init(xAxis: xAxis, yAxis: yAxis, chartPoints: chartPoints, displayDelay: displayDelay)
    }
    
    override open func display(chart: Chart) {
        super.display(chart: chart)
        if !delayInit {
            initViews(chart)
        }
    }
    
    open func initViews(_ chart: Chart) {
        self.viewsWithChartPoints = self.generateChartPointViews(chartPointModels: self.chartPointsModels, chart: chart)
        
        if self.isTransform || self.delayBetweenItems =~ 0 {
            for v in viewsWithChartPoints {addSubview(chart, view: v.view)}
            
        } else {
            for viewWithChartPoint in viewsWithChartPoints {
                let view = viewWithChartPoint.view
                addSubview(chart, view: view)
            }
        }
    }
    
    func addSubview(_ chart: Chart, view: UIView) {
        mode == .scaleAndTranslate ? chart.addSubview(view) : chart.addSubviewNoTransform(view)
    }
    
    func reloadViews() {
        guard let chart = chart else {return}
        
        for v in viewsWithChartPoints {
            v.view.removeFromSuperview()
        }
        
        isTransform = true
        display(chart: chart)
        isTransform = false
    }
    
    fileprivate func generateChartPointViews(chartPointModels: [ChartPointLayerModel<T>], chart: Chart) -> [ViewWithChartPoint] {
        let viewsWithChartPoints: [ViewWithChartPoint] = self.chartPointsModels.flatMap {model in
            if let view = self.viewGenerator(model, self, chart, isTransform) {
                return (view: view, chartPointModel: model)
            } else {
                return nil
            }
        }
        
        self.conflictSolver?.solveConflicts(views: viewsWithChartPoints)
        
        return viewsWithChartPoints
    }
    
    override open func chartPointsForScreenLoc(_ screenLoc: CGPoint) -> [T] {
        return self.filterChartPoints{self.inXBounds(screenLoc.x, view: $0.view) && self.inYBounds(screenLoc.y, view: $0.view)}
    }
    
    override open func chartPointsForScreenLocX(_ x: CGFloat) -> [T] {
        return self.filterChartPoints{self.inXBounds(x, view: $0.view)}
    }
    
    override open func chartPointsForScreenLocY(_ y: CGFloat) -> [T] {
        return self.filterChartPoints{self.inYBounds(y, view: $0.view)}
    }
    
    fileprivate func filterChartPoints(_ filter: (ViewWithChartPoint) -> Bool) -> [T] {
        return self.viewsWithChartPoints.reduce([]) {arr, viewWithChartPoint in
            if filter(viewWithChartPoint) {
                return arr + [viewWithChartPoint.chartPointModel.chartPoint]
            } else {
                return arr
            }
        }
    }
    
    fileprivate func inXBounds(_ x: CGFloat, view: UIView) -> Bool {
        return (x > view.frame.origin.x) && (x < (view.frame.origin.x + view.frame.width))
    }
    
    fileprivate func inYBounds(_ y: CGFloat, view: UIView) -> Bool {
        return (y > view.frame.origin.y) && (y < (view.frame.origin.y + view.frame.height))
    }
    
    open override func zoom(_ x: CGFloat, y: CGFloat, centerX: CGFloat, centerY: CGFloat) {
        super.zoom(x, y: y, centerX: centerX, centerY: centerY)
        updateForTransform()
    }
    
    open override func pan(_ deltaX: CGFloat, deltaY: CGFloat) {
        super.pan(deltaX, deltaY: deltaY)
        updateForTransform()
    }
    
    func updateForTransform() {
        switch mode {
            
        case .scaleAndTranslate:
            updateChartPointsScreenLocations()
            
        case .translate:
            for i in 0..<viewsWithChartPoints.count {
                viewsWithChartPoints[i].chartPointModel.screenLoc = modelLocToScreenLoc(x: viewsWithChartPoints[i].chartPointModel.chartPoint.x.scalar, y: viewsWithChartPoints[i].chartPointModel.chartPoint.y.scalar)
                viewsWithChartPoints[i].view.center = viewsWithChartPoints[i].chartPointModel.screenLoc
            }
        }
        
        if keepOnFront {
            bringToFront()
        }
    }
    
    open override func modelLocToScreenLoc(x: Double, y: Double) -> CGPoint {
        switch mode {
        case .scaleAndTranslate:
            return super.modelLocToScreenLoc(x: x, y: y)
        case .translate:
            return super.modelLocToContainerScreenLoc(x: x, y: y)
        }
    }
    
    open func bringToFront() {
        for (view, _) in viewsWithChartPoints {
            view.superview?.bringSubview(toFront: view)
        }
    }
}