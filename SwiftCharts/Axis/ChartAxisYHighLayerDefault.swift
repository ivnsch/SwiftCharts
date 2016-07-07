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
        return CGPointMake(origin.x, axis.firstVisibleScreen)
    }

    /// The end point of the axis line.
    override var lineP2: CGPoint {
        return CGPointMake(end.x, axis.lastVisibleScreen)
    }
    
    override func prepareUpdate() {
        super.prepareUpdate()
        
        // Move frame before updating drawers
        let newOriginX = self.origin.x - (self.frame.width - self.lastFrame.width)
        self.origin = CGPointMake(newOriginX, self.origin.y)
        self.end = CGPointMake(newOriginX, self.end.y)
    }
    
    override func updateInternal() {
        guard let chart = self.chart else {return}
        
        super.updateInternal()
        
        if lastFrame.width != self.frame.width {
            chart.notifyAxisInnerFrameChange(yHigh: (layer: self, delta: self.frame.width - self.lastFrame.width))
        }
    }
    
    
    override func handleAxisInnerFrameChange(xLow: ChartAxisLayerWithFrameDelta?, yLow: ChartAxisLayerWithFrameDelta?, xHigh: ChartAxisLayerWithFrameDelta?, yHigh: ChartAxisLayerWithFrameDelta?) {
        super.handleAxisInnerFrameChange(xLow, yLow: yLow, xHigh: xHigh, yHigh: yHigh)
        
        // Handle resizing of other high y axes
        if let (yHigh, deltaYHigh) = yHigh where yHigh.frame.maxX > self.frame.maxX {
            self.origin = CGPointMake(self.origin.x - deltaYHigh, self.origin.y)
            self.end = CGPointMake(self.end.x + deltaYHigh, self.end.y)
            
            self.initDrawers()
        }
    }
    
    override func initDrawers() {
        
        self.lineDrawer = self.generateLineDrawer(offset: 0)
        
        let labelsOffset = self.settings.labelsToAxisSpacingY + self.settings.axisStrokeWidth
        self.labelDrawers = self.generateLabelDrawers(offset: labelsOffset)
        let axisTitleLabelsOffset = labelsOffset + self.labelsMaxWidth + self.settings.axisTitleLabelsToLabelsSpacing
        self.axisTitleLabelDrawers = self.generateAxisTitleLabelsDrawers(offset: axisTitleLabelsOffset)
    }
    
    override func generateLineDrawer(offset offset: CGFloat) -> ChartLineDrawer {
        let halfStrokeWidth = self.settings.axisStrokeWidth / 2 // we want that the stroke begins at the beginning of the frame, not in the middle of it
        let x = self.origin.x + offset + halfStrokeWidth
        let p1 = CGPointMake(x, self.axis.firstVisibleScreen)
        let p2 = CGPointMake(x, self.axis.lastVisibleScreen)
        return ChartLineDrawer(p1: p1, p2: p2, color: self.settings.lineColor, strokeWidth: self.settings.axisStrokeWidth)
    }
    
    override func labelsX(offset offset: CGFloat, labelWidth: CGFloat, textAlignment: ChartLabelTextAlignment) -> CGFloat {
        var labelsX: CGFloat
        switch textAlignment {
        case .Left, .Default:
            labelsX = self.origin.x + offset
        case .Right:
            labelsX = self.origin.x + offset + self.labelsMaxWidth - labelWidth
        }
        return labelsX
    }
}
