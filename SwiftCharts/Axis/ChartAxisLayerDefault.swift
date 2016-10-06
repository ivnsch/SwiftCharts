//
//  ChartAxisLayerDefault.swift
//  SwiftCharts
//
//  Created by ischuetz on 25/04/15.
//  Copyright (c) 2015 ivanschuetz. All rights reserved.
//

import UIKit

/**
 This class allows customizing the layout of an axis layer and its contents. An example of how some of these settings affect the layout of a Y axis is shown below.

 ````
                   ┌───────────────────────────────────────────────────────────────────┐
                   │                             screenTop                             │
                   │   ┌───────────────────────────────────────────────────────────┐   │
                   │   │ ───────────────────────────────────────────────────────── │   │     labelsToAxisSpacingX
                   │   │                                                       ◀───┼───┼──── similar for labelsToAxisSpacingY
                   │   │  Label 1     Label 2     Label 3     Label 4     Label 5  │   │
                   │   │                                                       ◀───┼───┼──── labelsSpacing (only supported for X axes)
 screenLeading ────┼─▶ │  Label A     Label B     Label C     Label D     Label E  │   │
                   │   │                                                           │   │
                   │   │                              ◀────────────────────────────┼───┼──── axisTitleLabelsToLabelsSpacing
                   │   │                                                           │   │
                   │   │                           Title                           │ ◀─┼──── screenTrailing
                   │   └───────────────────────────────────────────────────────────┘   │
                   │                           screenBottom                            │
                   └───────────────────────────────────────────────────────────────────┘
 ````
 */
open class ChartAxisSettings {
    var screenLeading: CGFloat = 0
    var screenTrailing: CGFloat = 0
    var screenTop: CGFloat = 0
    var screenBottom: CGFloat = 0
    var labelsSpacing: CGFloat = 5
    var labelsToAxisSpacingX: CGFloat = 5
    var labelsToAxisSpacingY: CGFloat = 5
    var labelsWidthY: CGFloat?
    var axisTitleLabelsToLabelsSpacing: CGFloat = 5
    var lineColor:UIColor = UIColor.black
    var axisStrokeWidth: CGFloat = 2.0
    var isAxisLineVisible: Bool = true
    
    convenience init(_ chartSettings: ChartSettings) {
        self.init()
        self.labelsSpacing = chartSettings.labelsSpacing
        self.labelsToAxisSpacingX = chartSettings.labelsToAxisSpacingX
        self.labelsToAxisSpacingY = chartSettings.labelsToAxisSpacingY
        self.labelsWidthY = chartSettings.labelsWidthY
        self.axisTitleLabelsToLabelsSpacing = chartSettings.axisTitleLabelsToLabelsSpacing
        self.screenLeading = chartSettings.leading
        self.screenTop = chartSettings.top
        self.screenTrailing = chartSettings.trailing
        self.screenBottom = chartSettings.bottom
        self.axisStrokeWidth = chartSettings.axisStrokeWidth
    }
}

/// A default implementation of ChartAxisLayer, which delegates drawing of the axis line and labels to the appropriate Drawers
class ChartAxisLayerDefault: ChartAxisLayer {
    
    let p1: CGPoint
    let p2: CGPoint
    let axisValues: [ChartAxisValue]
    let axisTitleLabels: [ChartAxisLabel]
    let settings: ChartAxisSettings
    
    // exposed for subclasses
    var lineDrawer: ChartLineDrawer?
    var labelDrawers: [ChartLabelDrawer] = []
    var axisTitleLabelDrawers: [ChartLabelDrawer] = []
    
    var rect: CGRect {
        return CGRect(x: self.p1.x, y: self.p1.y, width: self.width, height: self.height)
    }
    
    var axisValuesScreenLocs: [CGFloat] {
        return self.axisValues.map{self.screenLocForScalar($0.scalar)}
    }
    
    var visibleAxisValuesScreenLocs: [CGFloat] {
        return self.axisValues.reduce(Array<CGFloat>()) {u, axisValue in
            return axisValue.hidden ? u : u + [self.screenLocForScalar(axisValue.scalar)]
        }
    }
    
    // smallest screen space between axis values
    var minAxisScreenSpace: CGFloat {
        return self.axisValuesScreenLocs.reduce((CGFloat.greatestFiniteMagnitude, -CGFloat.greatestFiniteMagnitude)) {tuple, screenLoc in
            let minSpace = tuple.0
            let previousScreenLoc = tuple.1
            return (min(minSpace, abs(screenLoc - previousScreenLoc)), screenLoc)
        }.0
    }

    var length: CGFloat {
        fatalError("override")
    }

    /// The difference between the first and last axis values
    var modelLength: CGFloat {
        if let first = self.axisValues.first, let last = self.axisValues.last {
            return CGFloat(last.scalar - first.scalar)
        } else {
            return 0
        }
    }
    
    lazy var axisTitleLabelsHeight: CGFloat = {
        return self.axisTitleLabels.reduce(0) { sum, label in
            sum + label.textSize.height
        }
    }()

    lazy var axisTitleLabelsWidth: CGFloat = {
        return self.axisTitleLabels.reduce(0) { sum, label in
            sum + label.textSize.width
        }
    }()

    var width: CGFloat {
        fatalError("override")
    }
    
    var lineP1: CGPoint {
        fatalError("override")
    }

    var lineP2: CGPoint {
        fatalError("override")
    }
    
    var height: CGFloat {
        fatalError("override")
    }
    
    var low: Bool {
        fatalError("override")
    }

    // NOTE: Assumes axis values sorted by scalar (can be increasing or decreasing)
    required init(p1: CGPoint, p2: CGPoint, axisValues: [ChartAxisValue], axisTitleLabels: [ChartAxisLabel], settings: ChartAxisSettings)  {
        self.p1 = p1
        self.p2 = p2
        self.axisValues = axisValues
        self.axisTitleLabels = axisTitleLabels
        self.settings = settings
    }
    
    func chartInitialized(chart: Chart) {
        self.initDrawers()
    }

    /**
     Draws the axis' line, labels and axis title label

     - parameter context: The context to draw the axis contents in
     - parameter chart:   The chart that this axis belongs to
     */
    func chartViewDrawing(context: CGContext, chart: Chart) {
        if self.settings.isAxisLineVisible {
            if let lineDrawer = self.lineDrawer {
                context.setLineWidth(CGFloat(self.settings.axisStrokeWidth))
                lineDrawer.triggerDraw(context: context, chart: chart)
            }
        }
        
        for labelDrawer in self.labelDrawers {
            labelDrawer.triggerDraw(context: context, chart: chart)
        }
        for axisTitleLabelDrawer in self.axisTitleLabelDrawers {
            axisTitleLabelDrawer.triggerDraw(context: context, chart: chart)
        }
    }
    
    
    func initDrawers() {
        fatalError("override")
    }
    
    func generateLineDrawer(offset: CGFloat) -> ChartLineDrawer {
        fatalError("override")
    }
    
    func generateAxisTitleLabelsDrawers(offset: CGFloat) -> [ChartLabelDrawer] {
        fatalError("override")
    }
    
    func generateLabelDrawers(offset: CGFloat) -> [ChartLabelDrawer] {
        fatalError("override")
    }

    /**
     Calculates the location for the scalar value in the chart's coordinates.
     
     If there are no axis values in this axis layer, returns 0.

     - parameter scalar: An axis value's scalar value

     - returns: The location along the axis' dimension that the axis value should be displayed at
     */
    final func screenLocForScalar(_ scalar: Double) -> CGFloat {
        if let firstScalar = self.axisValues.first?.scalar {
            return self.screenLocForScalar(scalar, firstAxisScalar: firstScalar)
        } else {
            print("Warning: requesting empty axis for screen location")
            return 0
        }
    }

    /**
     Finds the location for the scalar value within the bounds of the axis layer

     - parameter scalar:          The axis value's scalar value
     - parameter firstAxisScalar: The first axis value's scalar value, used to find how many "steps" away the given scalar value is from the first value

     - returns: The location of the axis value within the bounds of the axis layer
     */
    func innerScreenLocForScalar(_ scalar: Double, firstAxisScalar: Double) -> CGFloat {
        if self.modelLength != 0 {
            return self.length * CGFloat(scalar - firstAxisScalar) / self.modelLength
        } else {
            return 0
        }
    }

    /**
     Calculates the location for the scalar value in the chart's coordinates.

     - parameter scalar:          An axis value's scalar value
     - parameter firstAxisScalar: The first axis value's scalar value, used to find how many "steps" away the given scalar value is from the first value

     - returns: The screen location along the axis' dimension that the axis value should be displayed at
     */
    func screenLocForScalar(_ scalar: Double, firstAxisScalar: Double) -> CGFloat {
        fatalError("must override")
    }
    
    

}
