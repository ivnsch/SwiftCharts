//
//  ChartAxisYLowLayerDefault.swift
//  SwiftCharts
//
//  Created by ischuetz on 25/04/15.
//  Copyright (c) 2015 ivanschuetz. All rights reserved.
//

import UIKit

class ChartAxisYLowLayerDefault: ChartAxisYLayerDefault {
    
    override var low: Bool {return true}
    
    override var lineP1: CGPoint {
        return CGPointMake(self.p1.x + self.lineOffset, self.p1.y)
    }
    
    override var lineP2: CGPoint {
        return CGPointMake(self.p2.x + self.lineOffset, self.p2.y)
    }
    
    private lazy var labelsOffset: CGFloat = {
        return self.axisTitleLabelsWidth + self.settings.axisTitleLabelsToLabelsSpacing
    }()
    
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
        return ChartLineDrawer(p1: p1, p2: p2, color: self.settings.lineColor)
    }

    override func labelsX(offset offset: CGFloat, labelWidth: CGFloat) -> CGFloat {
        let labelsXRight = self.p1.x + offset + self.labelsMaxWidth
        return labelsXRight - labelWidth
    }
}
