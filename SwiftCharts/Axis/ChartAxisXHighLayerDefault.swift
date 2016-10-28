//
//  ChartAxisXHighLayerDefault.swift
//  SwiftCharts
//
//  Created by ischuetz on 25/04/15.
//  Copyright (c) 2015 ivanschuetz. All rights reserved.
//

import UIKit

/// A ChartAxisLayer for high X axes
class ChartAxisXHighLayerDefault: ChartAxisXLayerDefault {
    
    override var low: Bool {return false}

    /// The start point of the axis line.
    override var lineP1: CGPoint {
        return CGPoint(x: self.origin.x, y: self.origin.y + self.lineOffset)
    }

    /// The end point of the axis line
    override var lineP2: CGPoint {
        return CGPoint(x: self.end.x, y: self.end.y + self.lineOffset)
    }

    /// The offset of the axis labels from the edge of the axis bounds
    ///
    /// ````
    /// ─ ─ ─ ─  ▲
    ///  Title   │
    ///          │
    ///          ▼
    ///  Label
    /// ````
    fileprivate var labelsOffset: CGFloat {
        return self.axisTitleLabelsHeight + self.settings.axisTitleLabelsToLabelsSpacing
    }

    /// The offset of the axis line from the edge of the axis bounds
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
    fileprivate var lineOffset: CGFloat {
        return self.labelsOffset + (self.settings.axisStrokeWidth / 2) + self.settings.labelsToAxisSpacingX + self.labelsTotalHeight
    }
    
    override func chartViewDrawing(context: CGContext, chart: Chart) {
        super.chartViewDrawing(context: context, chart: chart)
    }
    
    override func updateInternal() {
        guard let chart = self.chart else {return}
        
        super.updateInternal()

        if lastFrame.height != self.frame.height {
            chart.notifyAxisInnerFrameChange(xHigh: ChartAxisLayerWithFrameDelta(layer: self, delta: self.frame.height - self.lastFrame.height))
        }
    }

    override func handleAxisInnerFrameChange(_ xLow: ChartAxisLayerWithFrameDelta?, yLow: ChartAxisLayerWithFrameDelta?, xHigh: ChartAxisLayerWithFrameDelta?, yHigh: ChartAxisLayerWithFrameDelta?) {
        super.handleAxisInnerFrameChange(xLow, yLow: yLow, xHigh: xHigh, yHigh: yHigh)
        
        // handle resizing of other high x axes
        if let xHigh = xHigh , xHigh.layer.frame.minY < self.frame.minY {
            offset = offset + xHigh.delta
            
            self.initDrawers()
        }
    }
    
    override func initDrawers() {
        self.axisTitleLabelDrawers = self.generateAxisTitleLabelsDrawers(offset: 0)
        self.labelDrawers = self.generateLabelDrawers(offset: self.labelsOffset)
        self.lineDrawer = self.generateLineDrawer(offset: self.lineOffset)
    }
}
