//
//  ChartAxisYLowLayerDefault.swift
//  SwiftCharts
//
//  Created by ischuetz on 25/04/15.
//  Copyright (c) 2015 ivanschuetz. All rights reserved.
//

import UIKit

/// A ChartAxisLayer for low Y axes
class ChartAxisYLowLayerDefault: ChartAxisYLayerDefault {
    
    override var low: Bool {return true}

    /// The start point of the axis line.
    override var lineP1: CGPoint {
        return CGPointMake(self.origin.x + self.lineOffset, axis.firstVisibleScreen)
    }

    /// The end point of the axis line.
    override var lineP2: CGPoint {
        return CGPointMake(self.end.x + self.lineOffset, axis.lastVisibleScreen)
    }

    /// The offset of the axis labels from the edge of the axis bounds
    ///
    /// Imagine the following image rotated 90 degrees counter-clockwise.
    ///
    /// ````
    /// ─ ─ ─ ─  ▲
    ///  Title   │
    ///          │
    ///          ▼
    ///  Label
    /// ````
    private var labelsOffset: CGFloat {
        return self.axisTitleLabelsWidth + self.settings.axisTitleLabelsToLabelsSpacing
    }

    /// The offset of the axis line from the edge of the axis bounds.
    ///
    /// Imagine the following image rotated 90 degrees counter-clockwise.
    ///
    /// ````
    /// ─ ─ ─ ─  ▲
    ///  Title   │
    ///          │
    ///          │
    ///  Label   │
    ///          │
    ///          │
    /// ───────  ▼
    /// ````
    private var lineOffset: CGFloat {
        return self.labelsOffset + self.labelsMaxWidth + self.settings.labelsToAxisSpacingY + self.settings.axisStrokeWidth
    }
    
    override func handleAxisInnerFrameChange(xLow: ChartAxisLayerWithFrameDelta?, yLow: ChartAxisLayerWithFrameDelta?, xHigh: ChartAxisLayerWithFrameDelta?, yHigh: ChartAxisLayerWithFrameDelta?) {
        super.handleAxisInnerFrameChange(xLow, yLow: yLow, xHigh: xHigh, yHigh: yHigh)
        
        // Handle resizing of other low y axes
        if let yLow = yLow where yLow.layer.frame.origin.x < self.origin.x {
            offset = offset + yLow.delta
            initDrawers()
        }
    }
    
    override func updateInternal() {
        guard let chart = self.chart else {return}
        super.updateInternal()
        if self.lastFrame.width != self.frame.width {
            chart.notifyAxisInnerFrameChange(yLow: ChartAxisLayerWithFrameDelta(layer: self, delta: self.frame.width - self.lastFrame.width))
        }
    }
    
    override func initDrawers() {
        self.axisTitleLabelDrawers = self.generateAxisTitleLabelsDrawers(offset: 0)
        self.labelDrawers = self.generateLabelDrawers(offset: self.labelsOffset)
        self.lineDrawer = self.generateLineDrawer(offset: self.lineOffset)
    }
    
    override func generateLineDrawer(offset offset: CGFloat) -> ChartLineDrawer {
        let halfStrokeWidth = self.settings.axisStrokeWidth / 2 // we want that the stroke ends at the end of the frame, not be in the middle of it
        let p1 = CGPointMake(self.origin.x + offset - halfStrokeWidth, self.axis.firstVisibleScreen)
        let p2 = CGPointMake(self.end.x + offset - halfStrokeWidth, self.axis.lastVisibleScreen)
        return ChartLineDrawer(p1: p1, p2: p2, color: self.settings.lineColor, strokeWidth: self.settings.axisStrokeWidth)
    }

    override func labelsX(offset offset: CGFloat, labelWidth: CGFloat, textAlignment: ChartLabelTextAlignment) -> CGFloat {
        let labelsXRight = self.origin.x + offset
        var labelsX: CGFloat
        switch textAlignment {
        case .Right, .Default:
            labelsX = labelsXRight + self.labelsMaxWidth - labelWidth
        case .Left:
            labelsX = labelsXRight
        }
        return labelsX
    }
}
