//
//  ChartPointsViewsLayer.swift
//  SwiftCharts
//
//  Created by ischuetz on 27/04/15.
//  Copyright (c) 2015 ivanschuetz. All rights reserved.
//

import UIKit

public enum ChartPointsViewsLayerMode {
    case ScaleAndTranslate, Translate
}

public class ChartPointsViewsLayer<T: ChartPoint, U: UIView>: ChartPointsLayer<T> {

    public typealias ChartPointViewGenerator = (chartPointModel: ChartPointLayerModel<T>, layer: ChartPointsViewsLayer<T, U>, chart: Chart, isTransform: Bool) -> U?
    public typealias ViewWithChartPoint = (view: U, chartPointModel: ChartPointLayerModel<T>)
    
    public private(set) var viewsWithChartPoints: [ViewWithChartPoint] = []
    
    private let delayBetweenItems: Float = 0
    
    let viewGenerator: ChartPointViewGenerator
    
    private var conflictSolver: ChartViewsConflictSolver<T, U>?
    
    private let mode: ChartPointsViewsLayerMode
    
    // For cases when layers behind re-add subviews on pan/zoom, ensure views of this layer stays on front
    // TODO z ordering
    private let keepOnFront: Bool
    
    public init(xAxis: ChartAxis, yAxis: ChartAxis, chartPoints:[T], viewGenerator: ChartPointViewGenerator, conflictSolver: ChartViewsConflictSolver<T, U>? = nil, displayDelay: Float = 0, delayBetweenItems: Float = 0, mode: ChartPointsViewsLayerMode = .ScaleAndTranslate, keepOnFront: Bool = true) {
        self.viewGenerator = viewGenerator
        self.conflictSolver = conflictSolver
        self.mode = mode
        self.keepOnFront = keepOnFront
        super.init(xAxis: xAxis, yAxis: yAxis, chartPoints: chartPoints, displayDelay: displayDelay)
    }
    
    override func display(chart chart: Chart) {
        super.display(chart: chart)
        
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
    
    func addSubview(chart: Chart, view: UIView) {
        mode == .ScaleAndTranslate ? chart.addSubview(view) : chart.addSubviewNoTransform(view)
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
    
    private func generateChartPointViews(chartPointModels chartPointModels: [ChartPointLayerModel<T>], chart: Chart) -> [ViewWithChartPoint] {
        let viewsWithChartPoints: [ViewWithChartPoint] = self.chartPointsModels.flatMap {model in
            if let view = self.viewGenerator(chartPointModel: model, layer: self, chart: chart, isTransform: isTransform) {
                return (view: view, chartPointModel: model)
            } else {
                return nil
            }
        }
        
        self.conflictSolver?.solveConflicts(views: viewsWithChartPoints)
        
        return viewsWithChartPoints
    }
    
    override public func chartPointsForScreenLoc(screenLoc: CGPoint) -> [T] {
        return self.filterChartPoints{self.inXBounds(screenLoc.x, view: $0.view) && self.inYBounds(screenLoc.y, view: $0.view)}
    }
    
    override public func chartPointsForScreenLocX(x: CGFloat) -> [T] {
        return self.filterChartPoints{self.inXBounds(x, view: $0.view)}
    }
    
    override public func chartPointsForScreenLocY(y: CGFloat) -> [T] {
        return self.filterChartPoints{self.inYBounds(y, view: $0.view)}
    }
    
    private func filterChartPoints(filter: (ViewWithChartPoint) -> Bool) -> [T] {
        return self.viewsWithChartPoints.reduce([]) {arr, viewWithChartPoint in
            if filter(viewWithChartPoint) {
                return arr + [viewWithChartPoint.chartPointModel.chartPoint]
            } else {
                return arr
            }
        }
    }
    
    private func inXBounds(x: CGFloat, view: UIView) -> Bool {
        return (x > view.frame.origin.x) && (x < (view.frame.origin.x + view.frame.width))
    }
    
    private func inYBounds(y: CGFloat, view: UIView) -> Bool {
        return (y > view.frame.origin.y) && (y < (view.frame.origin.y + view.frame.height))
    }
    
    public override func zoom(x: CGFloat, y: CGFloat, centerX: CGFloat, centerY: CGFloat) {
        super.zoom(x, y: y, centerX: centerX, centerY: centerY)
        updateForTransform()
    }
    
    public override func pan(deltaX: CGFloat, deltaY: CGFloat) {
        super.pan(deltaX, deltaY: deltaY)
        updateForTransform()
    }
    
    func updateForTransform() {
        switch mode {
            
        case .ScaleAndTranslate:
            updateChartPointsScreenLocations()
            
        case .Translate:
            for i in 0..<viewsWithChartPoints.count {
                viewsWithChartPoints[i].chartPointModel.screenLoc = modelLocToScreenLoc(x: viewsWithChartPoints[i].chartPointModel.chartPoint.x.scalar, y: viewsWithChartPoints[i].chartPointModel.chartPoint.y.scalar)
                viewsWithChartPoints[i].view.center = viewsWithChartPoints[i].chartPointModel.screenLoc
            }
        }
        
        if keepOnFront {
            bringToFront()
        }
    }
    
    public override func modelLocToScreenLoc(x x: Double, y: Double) -> CGPoint {
        switch mode {
        case .ScaleAndTranslate:
            return super.modelLocToScreenLoc(x: x, y: y)
        case .Translate:
            return super.modelLocToContainerScreenLoc(x: x, y: y)
        }
    }
    
    public func bringToFront() {
        for (view, _) in viewsWithChartPoints {
            view.superview?.bringSubviewToFront(view)
        }
    }
}