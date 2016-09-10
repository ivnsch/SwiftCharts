//
//  Chart.swift
//  SwiftCharts
//
//  Created by ischuetz on 25/04/15.
//  Copyright (c) 2015 ivanschuetz. All rights reserved.
//

import UIKit

/// ChartSettings allows configuration of the visual layout of a chart
open class ChartSettings {

    /// Empty space in points added to the leading edge of the chart
    open var leading: CGFloat = 0

    /// Empty space in points added to the top edge of the chart
    open var top: CGFloat = 0

    /// Empty space in points added to the trailing edge of the chart
    open var trailing: CGFloat = 0

    /// Empty space in points added to the bottom edge of the chart
    open var bottom: CGFloat = 0

    /// The spacing in points between axis labels when using multiple labels for each axis value. This is currently only supported with an X axis.
    open var labelsSpacing: CGFloat = 5

    /// The spacing in points between X axis labels and the X axis line
    open var labelsToAxisSpacingX: CGFloat = 5

    /// The spacing in points between Y axis labels and the Y axis line
    open var labelsToAxisSpacingY: CGFloat = 5

    /// The width of the Y-axis labels. If `nil`, it will be auto-calculated from the label text and font.
    open var labelsWidthY: CGFloat?

    open var spacingBetweenAxesX: CGFloat = 15

    open var spacingBetweenAxesY: CGFloat = 15

    /// The spacing in points between axis title labels and axis labels
    open var axisTitleLabelsToLabelsSpacing: CGFloat = 5

    /// The stroke width in points of the axis lines
    open var axisStrokeWidth: CGFloat = 1.0
    
    public init() {}
}

/// A Chart object is the highest level access to your chart. It has the view where all of the chart layers are drawn, which you can provide (useful if you want to position it as part of a storyboard or XIB), or it can be created for you.
open class Chart {

    /// The view that the chart is drawn in
    open let view: ChartView
    
    /// The layers of the chart that are drawn in the view
    fileprivate let layers: [ChartLayer]

    /**
     Create a new Chart with a frame and layers. A new ChartBaseView will be created for you.

     - parameter frame:  The frame used for the ChartBaseView
     - parameter layers: The layers that are drawn in the chart

     - returns: The new Chart
     */
    convenience public init(frame: CGRect, layers: [ChartLayer]) {
        self.init(view: ChartBaseView(frame: frame), layers: layers)
    }

    /**
     Create a new Chart with a view and layers.

     - parameter view:   The view that the chart will be drawn in
     - parameter layers: The layers that are drawn in the chart

     - returns: The new Chart
     */
    public init(view: ChartView, layers: [ChartLayer]) {
        
        self.layers = layers
        
        self.view = view
        self.view.chart = self
        
        for layer in self.layers {
            layer.chartInitialized(chart: self)
        }
        
        self.view.setNeedsDisplay()
    }
    
    public required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /**
     Adds a subview to the chart's view

     - parameter view: The subview to add to the chart's view
     */
    open func addSubview(_ view: UIView) {
        self.view.addSubview(view)
    }

    /// The frame of the chart's view
    open var frame: CGRect {
        return self.view.frame
    }

    /// The bounds of the chart's view
    open var bounds: CGRect {
        return self.view.bounds
    }

    /**
     Removes the chart's view from its superview
     */
    open func clearView() {
        self.view.removeFromSuperview()
    }

    /**
     Draws the chart's layers in the chart view

     - parameter rect: The rect that needs to be drawn
     */
    fileprivate func drawRect(_ rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        for layer in self.layers {
            layer.chartViewDrawing(context: context!, chart: self)
        }
    }
}

/// A UIView subclass for drawing charts
open class ChartBaseView: ChartView {
    
    override open func draw(_ rect: CGRect) {
        self.chart?.drawRect(rect)
    }
}

open class ChartView: UIView {
    
    /// The chart that will be drawn in this view
    weak var chart: Chart?
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        self.sharedInit()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.sharedInit()
    }

    /**
     Initialization code shared between all initializers
     */
    func sharedInit() {
        self.backgroundColor = UIColor.clear
    }
}
