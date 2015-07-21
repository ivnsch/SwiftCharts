//
//  ChartAxisYLayerDefault.swift
//  SwiftCharts
//
//  Created by ischuetz on 25/04/15.
//  Copyright (c) 2015 ivanschuetz. All rights reserved.
//

import UIKit

class ChartAxisYLayerDefault: ChartAxisLayerDefault {
    
    override var height: CGFloat {
        return self.p2.y - self.p1.y
    }
    
    var labelsMaxWidth: CGFloat {
        if self.labelDrawers.isEmpty {
            return self.maxLabelWidth(self.axisValues)
        } else {
            return self.labelDrawers.reduce(0) {maxWidth, labelDrawer in
                max(maxWidth, labelDrawer.size.width)
            }
        }
    }
    
    override var width: CGFloat {
        return self.labelsMaxWidth + self.settings.axisStrokeWidth + self.settings.labelsToAxisSpacingY + self.settings.axisTitleLabelsToLabelsSpacing + self.axisTitleLabelsWidth
    }
    
    override var length: CGFloat {
        return p1.y - p2.y
    }

    override func generateAxisTitleLabelsDrawers(offset offset: CGFloat) -> [ChartLabelDrawer] {
        
        if let firstTitleLabel = self.axisTitleLabels.first {
            
            if self.axisTitleLabels.count > 1 {
                print("WARNING: No support for multiple definition labels on vertical axis. Using only first one.")
            }
            let axisLabel = firstTitleLabel
            let labelSize = ChartUtils.textSize(axisLabel.text, font: axisLabel.settings.font)
            let settings = axisLabel.settings
            let newSettings = ChartLabelSettings(font: settings.font, fontColor: settings.fontColor, rotation: settings.rotation, rotationKeep: settings.rotationKeep)
            let axisLabelDrawer = ChartLabelDrawer(text: axisLabel.text, screenLoc: CGPointMake(
                self.p1.x + offset,
                self.p2.y + ((self.p1.y - self.p2.y) / 2) - (labelSize.height / 2)), settings: newSettings)
            
            return [axisLabelDrawer]
            
        } else { // definitionLabels is empty
            return []
        }
    }

    
    override func screenLocForScalar(scalar: Double, firstAxisScalar: Double) -> CGFloat {
        return self.p1.y - self.innerScreenLocForScalar(scalar, firstAxisScalar: firstAxisScalar)
    }
    
    
    override func generateLabelDrawers(offset offset: CGFloat) -> [ChartLabelDrawer] {
        
        return self.axisValues.reduce([]) {arr, axisValue in
            let scalar = axisValue.scalar
            let y = self.screenLocForScalar(scalar)
            if let axisLabel = axisValue.labels.first { // for now y axis supports only one label x value
                let labelSize = ChartUtils.textSize(axisLabel.text, font: axisLabel.settings.font)
                let labelY = y - (labelSize.height / 2)
                let labelX = self.labelsX(offset: offset, labelWidth: labelSize.width)
                let labelDrawer = ChartLabelDrawer(text: axisLabel.text, screenLoc: CGPointMake(labelX, labelY), settings: axisLabel.settings)
                labelDrawer.hidden = axisValue.hidden
                return arr + [labelDrawer]
                
            } else {
                return arr
            }

        }
    }
    
    func labelsX(offset offset: CGFloat, labelWidth: CGFloat) -> CGFloat {
        fatalError("override")
    }
    
    private func maxLabelWidth(axisLabels: [ChartAxisLabel]) -> CGFloat {
        return axisLabels.reduce(CGFloat(0)) {maxWidth, label in
            return max(maxWidth, ChartUtils.textSize(label.text, font: label.settings.font).width)
        }
    }
    
    private func maxLabelWidth(axisValues: [ChartAxisValue]) -> CGFloat {
        return axisValues.reduce(CGFloat(0)) {maxWidth, axisValue in
            return max(maxWidth, self.maxLabelWidth(axisValue.labels))
        }
    }
}
