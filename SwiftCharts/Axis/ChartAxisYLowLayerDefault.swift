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
        return CGPointMake(self.p1.x + self.lineOffset, self.p1.y)
    }

    /// The end point of the axis line.
    override var lineP2: CGPoint {
        return CGPointMake(self.p2.x + self.lineOffset, self.p2.y)
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
    private lazy var labelsOffset: CGFloat = {
        return self.axisTitleLabelsWidth + self.settings.axisTitleLabelsToLabelsSpacing
    }()

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
    private lazy var lineOffset: CGFloat = {
        return self.labelsOffset + self.labelsMaxWidth + self.settings.labelsToAxisSpacingY + self.settings.axisStrokeWidth
    }()
    
    override func initDrawers() {
        self.axisTitleLabelDrawers = self.generateAxisTitleLabelsDrawers(offset: 0)
        self.labelDrawers = self.generateLabelDrawers(offset: self.labelsOffset)
        self.lineDrawer = self.generateLineDrawer(offset: self.lineOffset)
    }
    
    override func generateLineDrawer(offset offset: CGFloat) -> ChartLineDrawer {
        let halfStrokeWidth = self.settings.axisStrokeWidth / 2 // we want that the stroke ends at the end of the frame, not be in the middle of it
        let p1 = CGPointMake(self.p1.x + offset - halfStrokeWidth, self.p1.y)
        let p2 = CGPointMake(self.p2.x + offset - halfStrokeWidth, self.p2.y)
        return ChartLineDrawer(p1: p1, p2: p2, color: self.settings.lineColor, strokeWidth: self.settings.axisStrokeWidth)
    }

    override func labelsX(offset offset: CGFloat, labelWidth: CGFloat, textAlignment: ChartLabelTextAlignment) -> CGFloat {
        let labelsXRight = self.p1.x + offset
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
