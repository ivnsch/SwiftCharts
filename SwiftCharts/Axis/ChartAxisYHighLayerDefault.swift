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
        return self.origin
    }

    /// The end point of the axis line.
    override var lineP2: CGPoint {
        return self.end
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
        let p1 = CGPointMake(x, self.origin.y)
        let p2 = CGPointMake(x, self.end.y)
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
