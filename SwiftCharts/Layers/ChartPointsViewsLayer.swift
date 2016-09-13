//
//  ChartPointsViewsLayer.swift
//  SwiftCharts
//
//  Created by ischuetz on 27/04/15.
//  Copyright (c) 2015 ivanschuetz. All rights reserved.
//

import UIKit


open class ChartPointsViewsLayer<T: ChartPoint, U: UIView>: ChartPointsLayer<T> {

    public typealias ChartPointViewGenerator = (_ chartPointModel: ChartPointLayerModel<T>, _ layer: ChartPointsViewsLayer<T, U>, _ chart: Chart) -> U?
    public typealias ViewWithChartPoint = (view: U, chartPointModel: ChartPointLayerModel<T>)
    
    fileprivate(set) var viewsWithChartPoints: [ViewWithChartPoint] = []
    
    fileprivate let delayBetweenItems: Float = 0
    
    let viewGenerator: ChartPointViewGenerator
    
    fileprivate var conflictSolver: ChartViewsConflictSolver<T, U>?
    
    public init(xAxis: ChartAxisLayer, yAxis: ChartAxisLayer, innerFrame: CGRect, chartPoints:[T], viewGenerator: @escaping ChartPointViewGenerator, conflictSolver: ChartViewsConflictSolver<T, U>? = nil, displayDelay: Float = 0, delayBetweenItems: Float = 0) {
        self.viewGenerator = viewGenerator
        self.conflictSolver = conflictSolver
        super.init(xAxis: xAxis, yAxis: yAxis, innerFrame: innerFrame, chartPoints: chartPoints, displayDelay: displayDelay)
    }
    
    override func display(chart: Chart) {
        super.display(chart: chart)
        
        self.viewsWithChartPoints = self.generateChartPointViews(chartPointModels: self.chartPointsModels, chart: chart)
        
        if self.delayBetweenItems == 0 {
            for v in self.viewsWithChartPoints {chart.addSubview(v.view)}
            
        } else {
            func next(_ index: Int, delay: DispatchTime) {
                if index < self.viewsWithChartPoints.count {
                    DispatchQueue.main.asyncAfter(deadline: delay) {() -> Void in
                        let view = self.viewsWithChartPoints[index].view
                        chart.addSubview(view)
                        next(index + 1, delay: ChartUtils.toDispatchTime(self.delayBetweenItems))
                    }
                }
            }
            next(0, delay: .now())
        }
    }
    
    fileprivate func generateChartPointViews(chartPointModels: [ChartPointLayerModel<T>], chart: Chart) -> [ViewWithChartPoint] {
        let viewsWithChartPoints: [ViewWithChartPoint] = self.chartPointsModels.flatMap { model in
            if let view = self.viewGenerator(model, self, chart) {
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
}
