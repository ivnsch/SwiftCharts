//
//  ChartAxisYHighLayerDefault.swift
//  SwiftCharts
//
//  Created by ischuetz on 25/04/15.
//  Copyright (c) 2015 ivanschuetz. All rights reserved.
//

import UIKit

/// A ChartAxisLayer for high Y axes
class ChartAxisYHighLayerDefault: ChartAxisYLayerDefault {
    
    override var low: Bool {return false}

    /// The start point of the axis line.
    override var lineP1: CGPoint {
        return CGPoint(x: origin.x, y: axis.firstVisibleScreen)
    }

    /// The end point of the axis line.
    override var lineP2: CGPoint {
        return CGPoint(x: end.x, y: axis.lastVisibleScreen)
    }
    
    override func updateInternal() {
        guard let chart = self.chart else {return}
        super.updateInternal()
        if lastFrame.width != self.frame.width {
            
            // Move drawers by delta
            let delta = frame.width - lastFrame.width
            offset -= delta
            initDrawers()
            
            chart.notifyAxisInnerFrameChange(yHigh: ChartAxisLayerWithFrameDelta(layer: self, delta: delta))
        }
    }
    
    
    override func handleAxisInnerFrameChange(_ xLow: ChartAxisLayerWithFrameDelta?, yLow: ChartAxisLayerWithFrameDelta?, xHigh: ChartAxisLayerWithFrameDelta?, yHigh: ChartAxisLayerWithFrameDelta?) {
        super.handleAxisInnerFrameChange(xLow, yLow: yLow, xHigh: xHigh, yHigh: yHigh)
        
        // Handle resizing of other high y axes
        if let yHigh = yHigh , yHigh.layer.frame.maxX > frame.maxX {
            offset = offset - yHigh.delta
            initDrawers()
        }
    }
    
    override func initDrawers() {
        
        self.lineDrawer = self.generateLineDrawer(offset: 0)
        
        let labelsOffset = self.settings.labelsToAxisSpacingY + self.settings.axisStrokeWidth
        self.labelDrawers = self.generateLabelDrawers(offset: labelsOffset)
        let axisTitleLabelsOffset = labelsOffset + self.labelsMaxWidth + self.settings.axisTitleLabelsToLabelsSpacing
        self.axisTitleLabelDrawers = self.generateAxisTitleLabelsDrawers(offset: axisTitleLabelsOffset)
    }
    
    override func generateLineDrawer(offset: CGFloat) -> ChartLineDrawer {
        let halfStrokeWidth = self.settings.axisStrokeWidth / 2 // we want that the stroke begins at the beginning of the frame, not in the middle of it
        let x = self.origin.x + offset + halfStrokeWidth
        let p1 = CGPoint(x: x, y: self.axis.firstVisibleScreen)
        let p2 = CGPoint(x: x, y: self.axis.lastVisibleScreen)
        return ChartLineDrawer(p1: p1, p2: p2, color: self.settings.lineColor, strokeWidth: self.settings.axisStrokeWidth)
    }
    
    override func labelsX(offset: CGFloat, labelWidth: CGFloat, textAlignment: ChartLabelTextAlignment) -> CGFloat {
        var labelsX: CGFloat
        switch textAlignment {
        case .left, .default:
            labelsX = self.origin.x + offset
        case .right:
            labelsX = self.origin.x + offset + self.labelsMaxWidth - labelWidth
        }
        return labelsX
    }
}
