//
//  ChartAxisYHighLayerDefault.swift
//  SwiftCharts
//
//  Created by ischuetz on 25/04/15.
//  Copyright (c) 2015 ivanschuetz. All rights reserved.
//

import UIKit

class ChartAxisYHighLayerDefault: ChartAxisYLayerDefault {
    
    override var low: Bool {return false}
    
    override var lineP1: CGPoint {
        return self.p1
    }
    
    override var lineP2: CGPoint {
        return self.p2
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
        let x = self.p1.x + offset + halfStrokeWidth
        let p1 = CGPointMake(x, self.p1.y)
        let p2 = CGPointMake(x, self.p2.y)
        return ChartLineDrawer(p1: p1, p2: p2, color: self.settings.lineColor)
    }
    
    override func labelsX(offset offset: CGFloat, labelWidth: CGFloat) -> CGFloat {
        return self.p1.x + offset
    }
}
