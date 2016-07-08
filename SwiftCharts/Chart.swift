//
//  Chart.swift
//  SwiftCharts
//
//  Created by ischuetz on 25/04/15.
//  Copyright (c) 2015 ivanschuetz. All rights reserved.
//

import UIKit

/// ChartSettings allows configuration of the visual layout of a chart
public class ChartSettings {

    /// Empty space in points added to the leading edge of the chart
    public var leading: CGFloat = 0

    /// Empty space in points added to the top edge of the chart
    public var top: CGFloat = 0

    /// Empty space in points added to the trailing edge of the chart
    public var trailing: CGFloat = 0

    /// Empty space in points added to the bottom edge of the chart
    public var bottom: CGFloat = 0

    /// The spacing in points between axis labels when using multiple labels for each axis value. This is currently only supported with an X axis.
    public var labelsSpacing: CGFloat = 5

    /// The spacing in points between X axis labels and the X axis line
    public var labelsToAxisSpacingX: CGFloat = 5

    /// The spacing in points between Y axis labels and the Y axis line
    public var labelsToAxisSpacingY: CGFloat = 5

    public var spacingBetweenAxesX: CGFloat = 15

    public var spacingBetweenAxesY: CGFloat = 15

    /// The spacing in points between axis title labels and axis labels
    public var axisTitleLabelsToLabelsSpacing: CGFloat = 5

    /// The stroke width in points of the axis lines
    public var axisStrokeWidth: CGFloat = 1.0
    
    public var panEnabled = false
    
    public var zoomEnabled = false
    
    public init() {}
}

/// A Chart object is the highest level access to your chart. It has the view where all of the chart layers are drawn, which you can provide (useful if you want to position it as part of a storyboard or XIB), or it can be created for you.
public class Chart: Pannable, Zoomable {

    /// The view that the chart is drawn in
    public let view: ChartView

    public let containerView: UIView
    public let contentView: UIView

    /// The layers of the chart that are drawn in the view
    private let layers: [ChartLayer]

    /**
     Create a new Chart with a frame and layers. A new ChartBaseView will be created for you.

     - parameter innerFrame: Frame comprised by axes, where the chart displays content
     - parameter settings: Chart settings
     - parameter frame:  The frame used for the ChartBaseView
     - parameter layers: The layers that are drawn in the chart

     - returns: The new Chart
     */
    convenience public init(frame: CGRect, innerFrame: CGRect, settings: ChartSettings? = nil, layers: [ChartLayer]) {
        self.init(view: ChartBaseView(frame: frame), innerFrame: innerFrame, settings: settings, layers: layers)
    }

    /**
     Create a new Chart with a view and layers.

     
     - parameter innerFrame: Frame comprised by axes, where the chart displays content
     - parameter settings: Chart settings
     - parameter view:   The view that the chart will be drawn in
     - parameter layers: The layers that are drawn in the chart

     - returns: The new Chart
     */
    public init(view: ChartView, innerFrame: CGRect, settings: ChartSettings? = nil, layers: [ChartLayer]) {
        
        self.layers = layers
        
        self.view = view

        let containerView = UIView(frame: innerFrame)
        let contentView = ChartContentView(frame: containerView.bounds)
        contentView.backgroundColor = UIColor.clearColor()
        containerView.addSubview(contentView)
        containerView.clipsToBounds = true
        view.addSubview(containerView)

        self.contentView = contentView
        self.containerView = containerView
        contentView.chart = self
        
        if let settings = settings {
            self.view.configure(settings)
        }
        
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
     Adds a subview to the chart's content view

     - parameter view: The subview to add to the chart's content view
     */
    public func addSubview(view: UIView) {
        self.contentView.addSubview(view)
    }

    /// The frame of the chart's view
    public var frame: CGRect {
        return self.view.frame
    }

    public var containerFrame: CGRect {
        return containerView.frame
    }
    
    /// The bounds of the chart's view
    public var bounds: CGRect {
        return self.view.bounds
    }

    /**
     Removes the chart's view from its superview
     */
    public func clearView() {
        self.view.removeFromSuperview()
    }

    public func update() {
        for layer in self.layers {
            layer.update()
        }
        self.view.setNeedsDisplay()
    }
 
    func notifyAxisInnerFrameChange(xLow xLow: ChartAxisLayerWithFrameDelta? = nil, yLow: ChartAxisLayerWithFrameDelta? = nil, xHigh: ChartAxisLayerWithFrameDelta? = nil, yHigh: ChartAxisLayerWithFrameDelta? = nil) {
        for layer in layers {
            layer.handleAxisInnerFrameChange(xLow, yLow: yLow, xHigh: xHigh, yHigh: yHigh)
        }

        containerView.frame = ChartUtils.insetBy(containerView.frame, dx: yLow.deltaDefault0, dy: xHigh.deltaDefault0, dw: yHigh.deltaDefault0, dh: xLow.deltaDefault0)
        contentView.frame = ChartUtils.insetBy(contentView.frame, dx: 0, dy: 0, dw: yLow.deltaDefault0 + yHigh.deltaDefault0, dh: xLow.deltaDefault0 + xHigh.deltaDefault0)
        
        view.setNeedsDisplay()
    }
    
    func onZoom(let x: CGFloat, let y: CGFloat, let centerX: CGFloat, let centerY: CGFloat) {
        for layer in layers {
            layer.zoom(x, y: y, centerX: centerX, centerY: centerY)
        }
    }
    
    func onPan(deltaX: CGFloat, deltaY: CGFloat) {
        for layer in layers {
            layer.pan(deltaX, deltaY: deltaY)
        }
    }

    /**
     Draws the chart's layers in the chart view

     - parameter rect: The rect that needs to be drawn
     */
    private func drawRect(rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        for layer in self.layers {
            layer.chartViewDrawing(context: context!, chart: self)
        }
    }
    
    private func drawContentViewRect(rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        for layer in layers {
            layer.chartContentViewDrawing(context: context!, chart: self)
        }
    }
}


public class ChartContentView: UIView {
    
    weak var chart: Chart?
    
    override public func drawRect(rect: CGRect) {
        self.chart?.drawContentViewRect(rect)
    }
}

/// A UIView subclass for drawing charts
public class ChartBaseView: ChartView {
    
    override public func drawRect(rect: CGRect) {
        self.chart?.drawRect(rect)
    }
}

public class ChartView: UIView, UIGestureRecognizerDelegate {
    
    /// The chart that will be drawn in this view
    weak var chart: Chart?
    
    private var lastPanTranslation: CGPoint?
    
    private var pinchRecognizer: UIPinchGestureRecognizer?
    private var panRecognizer: UIPanGestureRecognizer?
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        self.sharedInit()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.sharedInit()
    }
   
    func configure(settings: ChartSettings) {
        if settings.zoomEnabled {
            let pinchRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(ChartView.onPinch(_:)))
            pinchRecognizer.delegate = self
            addGestureRecognizer(pinchRecognizer)
            self.pinchRecognizer = pinchRecognizer
        }
        
        if settings.panEnabled {
            let panRecognizer = UIPanGestureRecognizer(target: self, action: #selector(ChartView.onPan(_:)))
            panRecognizer.delegate = self
            addGestureRecognizer(panRecognizer)
            self.panRecognizer = panRecognizer
        }
    }
    
    /**
     Initialization code shared between all initializers
     */
    func sharedInit() {
        self.backgroundColor = UIColor.clearColor()
    }
    
    @objc func onPinch(sender: UIPinchGestureRecognizer) {
        
        guard sender.numberOfTouches() > 1 else {return}
        
        let center = sender.locationInView(self)
        
        let x = abs(sender.locationInView(self).x - sender.locationOfTouch(1, inView: self).x)
        let y = abs(sender.locationInView(self).y - sender.locationOfTouch(1, inView: self).y)
        
        // calculate scale x and scale y
        let (absMax, absMin) = x > y ? (abs(x), abs(y)) : (abs(y), abs(x))
        let minScale = (absMin * (sender.scale - 1) / absMax) + 1
        let (scaleX, scaleY) = x > y ? (sender.scale, minScale) : (minScale, sender.scale)
        
        chart?.zoom(scaleX, y: scaleY, centerX: center.x, centerY: center.y)
        
        sender.scale = 1.0
    }
    
    @objc func onPan(sender: UIPanGestureRecognizer) {
        
        switch sender.state {
            
        case .Began:
            lastPanTranslation = nil
            
        case .Changed:
            
            let trans = sender.translationInView(self)
            
            let deltaX = lastPanTranslation.map{trans.x - $0.x} ?? trans.x
            let deltaY = lastPanTranslation.map{trans.y - $0.y} ?? trans.y
            
            lastPanTranslation = trans
            
            chart?.pan(deltaX, deltaY: deltaY)
            
        case .Ended:
            
            guard let view = sender.view else {print("Recogniser has no view"); return}
            
            let velocityX = sender.velocityInView(sender.view).x
            let velocityY = sender.velocityInView(sender.view).y
            
            func next(index: Int, velocityX: CGFloat, velocityY: CGFloat) {
                dispatch_async(dispatch_get_main_queue()) {
                    
                    self.chart?.pan(velocityX, deltaY: velocityY)
                    
                    if abs(velocityX) > 0.1 || abs(velocityY) > 0.1 {
                        let friction: CGFloat = 0.9
                        next(index + 1, velocityX: velocityX * friction, velocityY: velocityY * friction)
                    }
                }
            }
            let initFriction: CGFloat = 50
            next(0, velocityX: velocityX / initFriction, velocityY: velocityY / initFriction)
            
        case .Cancelled: break;
        case .Failed: break;
        case .Possible: break;
        }
    }
}