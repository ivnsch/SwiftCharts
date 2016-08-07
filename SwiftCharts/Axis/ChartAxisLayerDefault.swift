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
public class ChartAxisSettings {
    var screenLeading: CGFloat = 0
    var screenTrailing: CGFloat = 0
    var screenTop: CGFloat = 0
    var screenBottom: CGFloat = 0
    var labelsSpacing: CGFloat = 5
    var labelsToAxisSpacingX: CGFloat = 5
    var labelsToAxisSpacingY: CGFloat = 5
    var axisTitleLabelsToLabelsSpacing: CGFloat = 5
    var lineColor:UIColor = UIColor.blackColor()
    var axisStrokeWidth: CGFloat = 2.0
    var isAxisLineVisible: Bool = true
    
    convenience init(_ chartSettings: ChartSettings) {
        self.init()
        self.labelsSpacing = chartSettings.labelsSpacing
        self.labelsToAxisSpacingX = chartSettings.labelsToAxisSpacingX
        self.labelsToAxisSpacingY = chartSettings.labelsToAxisSpacingY
        self.axisTitleLabelsToLabelsSpacing = chartSettings.axisTitleLabelsToLabelsSpacing
        self.screenLeading = chartSettings.leading
        self.screenTop = chartSettings.top
        self.screenTrailing = chartSettings.trailing
        self.screenBottom = chartSettings.bottom
        self.axisStrokeWidth = chartSettings.axisStrokeWidth
    }
}

public typealias ChartAxisValueLabelDrawers = (scalar: Double, drawers: [ChartLabelDrawer])

/// Helper class to notify other layers about frame changes which affect content available space
public final class ChartAxisLayerWithFrameDelta {
    let layer: ChartAxisLayer
    let delta: CGFloat
    init(layer: ChartAxisLayer, delta: CGFloat) {
        self.layer = layer
        self.delta = delta
    }
}

extension Optional where Wrapped: ChartAxisLayerWithFrameDelta {
    var deltaDefault0: CGFloat {
        return self?.delta ?? 0
    }
}

public enum AxisLabelsSpaceReservationMode {
    case MinPresentedSize /// Doesn't reserve less space than the min presented label width/height so far
    case MaxPresentedSize /// Doesn't reserve less space than the max presented label width/height so far
    case Fixed(CGFloat) /// Fixed value, ignores labels width/height
    case Current /// Reserves space for currently visible labels
}


/// A default implementation of ChartAxisLayer, which delegates drawing of the axis line and labels to the appropriate Drawers
class ChartAxisLayerDefault: ChartAxisLayer {
    
    var axis: ChartAxis

    var origin: CGPoint {
        fatalError("Override")
    }
    
    var end: CGPoint {
        fatalError("Override")
    }
    
    var frame: CGRect {
        return CGRectMake(origin.x, origin.y, width, height)
    }
    
    var frameWithoutLabels: CGRect {
        return CGRectMake(origin.x, origin.y, widthWithoutLabels, heightWithoutLabels)
    }
    
    /// Constant dimension between origin and end
    var offset: CGFloat
    
    var currentAxisValues: [Double] = []
    
    let valuesGenerator: ChartAxisValuesGenerator
    var labelsGenerator: ChartAxisLabelsGenerator
    
    let axisTitleLabels: [ChartAxisLabel]
    let settings: ChartAxisSettings
    
    // exposed for subclasses
    var lineDrawer: ChartLineDrawer?
    var labelDrawers: [ChartAxisValueLabelDrawers] = []
    var axisTitleLabelDrawers: [ChartLabelDrawer] = []
    
    let labelsConflictSolver: ChartAxisLabelsConflictSolver?
    
    weak var chart: Chart?
    
    let labelSpaceReservationMode: AxisLabelsSpaceReservationMode

    var widthWithoutLabels: CGFloat {
        return width
    }
    
    var heightWithoutLabels: CGFloat {
        return settings.axisStrokeWidth + settings.labelsToAxisSpacingX + settings.axisTitleLabelsToLabelsSpacing + axisTitleLabelsHeight
    }
    
    var axisValuesScreenLocs: [CGFloat] {
        return self.currentAxisValues.map{self.axis.screenLocForScalar($0)}
    }

    var axisValuesWithFrames: [(axisValue: Double, frames: [CGRect])] {
        return labelDrawers.map {(axisValue, drawers) in
            (axisValue: axisValue, frames: drawers.map{$0.frame})
        }
    }
    
    var visibleAxisValuesScreenLocs: [CGFloat] {
        return self.currentAxisValues.reduce(Array<CGFloat>()) {u, scalar in
            return u + [self.axis.screenLocForScalar(scalar)]
        }
    }
    
    // smallest screen space between axis values
    var minAxisScreenSpace: CGFloat {
        return self.axisValuesScreenLocs.reduce((CGFloat.max, -CGFloat.max)) {tuple, screenLoc in
            let minSpace = tuple.0
            let previousScreenLoc = tuple.1
            return (min(minSpace, abs(screenLoc - previousScreenLoc)), screenLoc)
        }.0
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

    /// Frame of layer after last update. This is used to detect deltas with the frame resulting from an update. Note that the layer's frame can be altered by only updating the model data (this depends on how the concrete axis layer calculates the frame), which is why this frame is not always identical to the layer's frame directly before calling udpate.
    var lastFrame: CGRect = CGRectZero
    
    // NOTE: Assumes axis values sorted by scalar (can be increasing or decreasing)
    required init(axis: ChartAxis, offset: CGFloat, valuesGenerator: ChartAxisValuesGenerator, labelsGenerator: ChartAxisLabelsGenerator, axisTitleLabels: [ChartAxisLabel], settings: ChartAxisSettings, labelsConflictSolver: ChartAxisLabelsConflictSolver? = nil, labelSpaceReservationMode: AxisLabelsSpaceReservationMode)  {
        self.axis = axis
        self.offset = offset
        self.valuesGenerator = valuesGenerator
        self.labelsGenerator = labelsGenerator
        self.axisTitleLabels = axisTitleLabels
        self.settings = settings
        self.labelsConflictSolver = labelsConflictSolver
        self.labelSpaceReservationMode = labelSpaceReservationMode
        self.lastFrame = frame
        
        self.currentAxisValues = valuesGenerator.generate(axis)
    }

    func update() {
        self.prepareUpdate()
        self.updateInternal()
        self.postUpdate()
    }
    
    private func clearDrawers() {
        self.lineDrawer = nil
        self.labelDrawers = []
        self.axisTitleLabelDrawers = []
    }
    
    func prepareUpdate() {
        self.clearDrawers()
    }
    
    func updateInternal() {
        self.initDrawers()
    }
    
    func postUpdate() {
        self.lastFrame = frame
    }
    
    func handleAxisInnerFrameChange(xLow: ChartAxisLayerWithFrameDelta?, yLow: ChartAxisLayerWithFrameDelta?, xHigh: ChartAxisLayerWithFrameDelta?, yHigh: ChartAxisLayerWithFrameDelta?) {
    }
    
    func chartInitialized(chart chart: Chart) {
        self.chart = chart
        
        self.update()
    }

    /**
     Draws the axis' line, labels and axis title label

     - parameter context: The context to draw the axis contents in
     - parameter chart:   The chart that this axis belongs to
     */
    func chartViewDrawing(context context: CGContextRef, chart: Chart) {
        if self.settings.isAxisLineVisible {
            if let lineDrawer = self.lineDrawer {
                CGContextSetLineWidth(context, CGFloat(self.settings.axisStrokeWidth))
                lineDrawer.triggerDraw(context: context, chart: chart)
            }
        }
        
        for (_, labelDrawers) in self.labelDrawers {
            for labelDrawer in labelDrawers {
                labelDrawer.triggerDraw(context: context, chart: chart)
            }
        }
        for axisTitleLabelDrawer in self.axisTitleLabelDrawers {
            axisTitleLabelDrawer.triggerDraw(context: context, chart: chart)
        }
    }
    
    func chartContentViewDrawing(context context: CGContextRef, chart: Chart) {}
    
    func chartDrawersContentViewDrawing(context context: CGContextRef, chart: Chart, view: UIView) {}
    
    func handleGlobalTap(location: CGPoint) {}
    
    func initDrawers() {
        fatalError("override")
    }
    
    func generateLineDrawer(offset offset: CGFloat) -> ChartLineDrawer {
        fatalError("override")
    }
    
    func generateAxisTitleLabelsDrawers(offset offset: CGFloat) -> [ChartLabelDrawer] {
        fatalError("override")
    }
    
    /// Generates label drawers to be displayed on the screen. Calls generateDirectLabelDrawers to generate labels and passes result to an optional conflict solver, which maps the labels array to a new one such that the conflicts are solved. If there's no conflict solver returns the drawers unmodified.
    func generateLabelDrawers(offset offset: CGFloat) -> [ChartAxisValueLabelDrawers] {
        let directLabelDrawers = generateDirectLabelDrawers(offset: offset)
        return labelsConflictSolver.map{$0.solveConflicts(directLabelDrawers)} ?? directLabelDrawers
    }
    
    /// Generates label drawers which correspond directly to axis values. No conflict solving.
    func generateDirectLabelDrawers(offset offset: CGFloat) -> [ChartAxisValueLabelDrawers] {
        fatalError("override")
    }
    
    func zoom(x: CGFloat, y: CGFloat, centerX: CGFloat, centerY: CGFloat) {
        fatalError("override")
    }
    
    func zoom(scaleX: CGFloat, scaleY: CGFloat, centerX: CGFloat, centerY: CGFloat) {
        fatalError("override")
    }
    
    func pan(deltaX: CGFloat, deltaY: CGFloat) {
        fatalError("override")
    }
}
