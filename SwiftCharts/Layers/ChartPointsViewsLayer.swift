//
//  ChartPointsViewsLayer.swift
//  SwiftCharts
//
//  Created by ischuetz on 27/04/15.
//  Copyright (c) 2015 ivanschuetz. All rights reserved.
//

import UIKit


public class ChartPointsViewsLayer<T: ChartPoint, U: UIView>: ChartPointsLayer<T> {

    public typealias ChartPointViewGenerator = (chartPointModel: ChartPointLayerModel<T>, layer: ChartPointsViewsLayer<T, U>, chart: Chart) -> U?
    public typealias ViewWithChartPoint = (view: U, chartPointModel: ChartPointLayerModel<T>)
    
    private(set) var viewsWithChartPoints: [ViewWithChartPoint] = []
    
    private let delayBetweenItems: Float = 0
    
    let viewGenerator: ChartPointViewGenerator
    
    private var conflictSolver: ChartViewsConflictSolver<T, U>?
    
    public init(xAxis: ChartAxisLayer, yAxis: ChartAxisLayer, innerFrame: CGRect, chartPoints:[T], viewGenerator: ChartPointViewGenerator, conflictSolver: ChartViewsConflictSolver<T, U>? = nil, displayDelay: Float = 0, delayBetweenItems: Float = 0) {
        self.viewGenerator = viewGenerator
        self.conflictSolver = conflictSolver
        super.init(xAxis: xAxis, yAxis: yAxis, innerFrame: innerFrame, chartPoints: chartPoints, displayDelay: displayDelay)
    }
    
    override func display(chart chart: Chart) {
        super.display(chart: chart)
        
        self.viewsWithChartPoints = self.generateChartPointViews(chartPointModels: self.chartPointsModels, chart: chart)
        
        if self.delayBetweenItems == 0 {
            for v in self.viewsWithChartPoints {chart.addSubview(v.view)}
            
        } else {
            func next(index: Int, delay: dispatch_time_t) {
                if index < self.viewsWithChartPoints.count {
                    dispatch_after(delay, dispatch_get_main_queue()) {() -> Void in
                        let view = self.viewsWithChartPoints[index].view
                        chart.addSubview(view)
                        next(index + 1, delay: ChartUtils.toDispatchTime(self.delayBetweenItems))
                    }
                }
            }
            next(0, delay: 0)
        }
    }
    
    private func generateChartPointViews(chartPointModels chartPointModels: [ChartPointLayerModel<T>], chart: Chart) -> [ViewWithChartPoint] {
        let viewsWithChartPoints: [ViewWithChartPoint] = self.chartPointsModels.flatMap { model in
            if let view = self.viewGenerator(chartPointModel: model, layer: self, chart: chart) {
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
}
