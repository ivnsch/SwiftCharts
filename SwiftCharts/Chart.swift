//
//  Chart.swift
//  SwiftCharts
//
//  Created by ischuetz on 25/04/15.
//  Copyright (c) 2015 ivanschuetz. All rights reserved.
//

import UIKit

public class ChartSettings {
    public var leading: CGFloat = 0
    public var top: CGFloat = 0
    public var trailing: CGFloat = 0
    public var bottom: CGFloat = 0
    public var labelsSpacing: CGFloat = 5
    public var labelsToAxisSpacingX: CGFloat = 5
    public var labelsToAxisSpacingY: CGFloat = 5
    public var spacingBetweenAxesX: CGFloat = 15
    public var spacingBetweenAxesY: CGFloat = 15
    public var axisTitleLabelsToLabelsSpacing: CGFloat = 5
    public var axisStrokeWidth: CGFloat = 1.0
    
    public init() {}
}

public class Chart {
    
    public let view: ChartBaseView

    private let layers: [ChartLayer]

    convenience public init(frame: CGRect, layers: [ChartLayer]) {
        self.init(view: ChartBaseView(frame: frame), layers: layers)
    }
    
    public init(view: ChartBaseView, layers: [ChartLayer]) {

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
    
    public func addSubview(view: UIView) {
        self.view.addSubview(view)
    }
    
    public var frame: CGRect {
        return self.view.frame
    }
    
    public var bounds: CGRect {
        return self.view.bounds
    }
    
    public func clearView() {
        self.view.removeFromSuperview()
    }
    
    private func drawRect(rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        for layer in self.layers {
            layer.chartViewDrawing(context: context!, chart: self)
        }
    }
}

public class ChartBaseView: UIView {
    
    weak var chart: Chart?
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        self.sharedInit()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.sharedInit()
    }
    
    func sharedInit() {
        self.backgroundColor = UIColor.clearColor()
    }
    
    override public func drawRect(rect: CGRect) {
        self.chart?.drawRect(rect)
    }
}