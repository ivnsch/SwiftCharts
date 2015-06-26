//
//  ChartAxisXLowLayerDefault.swift
//  SwiftCharts
//
//  Created by ischuetz on 25/04/15.
//  Copyright (c) 2015 ivanschuetz. All rights reserved.
//

import UIKit

class ChartAxisXLowLayerDefault: ChartAxisXLayerDefault {

    override var low: Bool {return true}

    override var lineP1: CGPoint {
        return self.p1
    }
    
    override var lineP2: CGPoint {
        return self.p2
    }
    
    override func chartViewDrawing(context context: CGContextRef, chart: Chart) {
        super.chartViewDrawing(context: context, chart: chart)
    }
    
    override func initDrawers() {
        self.lineDrawer = self.generateLineDrawer(offset: 0)
        let labelsOffset = (self.settings.axisStrokeWidth / 2) + self.settings.labelsToAxisSpacingX
        let labelDrawers = self.generateLabelDrawers(offset: labelsOffset)
        let definitionLabelsOffset = labelsOffset + self.labelsTotalHeight + self.settings.axisTitleLabelsToLabelsSpacing
        self.axisTitleLabelDrawers = self.generateAxisTitleLabelsDrawers(offset: definitionLabelsOffset)
        self.labelDrawers = labelDrawers
    }
}
