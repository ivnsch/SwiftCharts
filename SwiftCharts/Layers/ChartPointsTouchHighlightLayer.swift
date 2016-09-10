//
//  ChartPointsTouchHighlightLayer.swift
//  SwiftCharts
//
//  Created by Nathan Racklyeft on 2/21/16.
//  Copyright © 2016 ivanschuetz. All rights reserved.
//

import UIKit


/// Displays a single view for a point in response to a pan gesture
open class ChartPointsTouchHighlightLayer<T: ChartPoint, U: UIView>: ChartPointsViewsLayer<T, U> {
    public typealias ChartPointLayerModelForScreenLocFilter = (_ screenLoc: CGPoint, _ chartPointModels: [ChartPointLayerModel<T>]) -> ChartPointLayerModel<T>?

    open fileprivate(set) var view: UIView?

    fileprivate let chartPointLayerModelForScreenLocFilter: ChartPointLayerModelForScreenLocFilter

    open let panGestureRecognizer: UIPanGestureRecognizer

    /// The delay after touches end before the highlighted point fades out. Set to `nil` to keep the highlight until the next touch.
    open var hideDelay: TimeInterval? = 1.0

    weak var chart: Chart?

    public init(xAxis: ChartAxisLayer, yAxis: ChartAxisLayer, innerFrame: CGRect, chartPoints: [T], gestureRecognizer: UIPanGestureRecognizer? = nil, modelFilter: @escaping ChartPointLayerModelForScreenLocFilter, viewGenerator: @escaping ChartPointViewGenerator) {
        chartPointLayerModelForScreenLocFilter = modelFilter
        panGestureRecognizer = gestureRecognizer ?? UIPanGestureRecognizer()

        super.init(xAxis: xAxis, yAxis: yAxis, innerFrame: innerFrame, chartPoints: chartPoints, viewGenerator: viewGenerator)
    }

    override func display(chart: Chart) {
        let view = UIView(frame: chart.bounds)
        self.chart = chart

        panGestureRecognizer.addTarget(self, action: #selector(handlePan(_:)))

        if panGestureRecognizer.view == nil {
            view.addGestureRecognizer(panGestureRecognizer)
        }

        chart.addSubview(view)
        self.view = view
    }

    open var highlightedPoint: T? {
        get {
            return highlightedModel?.chartPoint
        }
        set {
            if let index = chartPointsModels.index(where: { $0.chartPoint == newValue }) {
                highlightedModel = chartPointsModels[index]
            } else {
                highlightedModel = nil
            }
        }
    }

    var highlightedModel: ChartPointLayerModel<T>? {
        didSet {
            if highlightedModel?.index != oldValue?.index, let view = view, let chart = chart {
                for subview in view.subviews {
                    subview.removeFromSuperview()
                }

                if let model = highlightedModel, let pointView = viewGenerator(model, self, chart) {
                    view.addSubview(pointView)
                }
            }
        }
    }

    @objc func handlePan(_ gestureRecognizer: UIPanGestureRecognizer) {
        switch gestureRecognizer.state {
        case .possible:
            // Follow your dreams!
            break
        case .began, .changed:
            if let view = view {
                let point = gestureRecognizer.location(in: view)

                highlightedModel = chartPointLayerModelForScreenLocFilter(point, chartPointsModels)
            }
        case .cancelled, .failed, .ended:
            if let view = view, let hideDelay = hideDelay {
                UIView.animate(withDuration: 0.5,
                    delay: hideDelay,
                    options: [],
                    animations: { () -> Void in
                        for subview in view.subviews {
                            subview.alpha = 0
                        }
                    }, completion: { (completed) -> Void in
                        if completed {
                            self.highlightedModel = nil
                        }
                    }
                )
            }
        }
    }
}
