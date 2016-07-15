//
//  ChartAxisYLayerDefault.swift
//  SwiftCharts
//
//  Created by ischuetz on 25/04/15.
//  Copyright (c) 2015 ivanschuetz. All rights reserved.
//

import UIKit

/// A ChartAxisLayer for Y axes
class ChartAxisYLayerDefault: ChartAxisLayerDefault {
    
    override var origin: CGPoint {
        return CGPointMake(offset, axis.firstScreen)
    }
    
    override var end: CGPoint {
        return CGPointMake(offset, axis.lastScreen)
    }
    
    override var height: CGFloat {
        return axis.screenLength
    }
    
    var labelsMaxWidth: CGFloat {
        if self.labelDrawers.isEmpty {
            return self.maxLabelWidth(self.currentAxisValues)
        } else {
            return self.labelDrawers.reduce(0) {maxWidth, labelDrawer in
                return max(maxWidth, labelDrawer.drawers.reduce(0) {maxWidth, drawer in
                    max(maxWidth, drawer.size.width)
                })
            }
        }
    }
    
    override var width: CGFloat {
        return self.labelsMaxWidth + self.settings.axisStrokeWidth + self.settings.labelsToAxisSpacingY + self.settings.axisTitleLabelsToLabelsSpacing + self.axisTitleLabelsWidth
    }
    
    override var widthWithoutLabels: CGFloat {
        return self.settings.axisStrokeWidth + self.settings.labelsToAxisSpacingY + self.settings.axisTitleLabelsToLabelsSpacing + self.axisTitleLabelsWidth
    }
    
    override var heightWithoutLabels: CGFloat {
        return height
    }
    
    override func handleAxisInnerFrameChange(xLow: ChartAxisLayerWithFrameDelta?, yLow: ChartAxisLayerWithFrameDelta?, xHigh: ChartAxisLayerWithFrameDelta?, yHigh: ChartAxisLayerWithFrameDelta?) {
        super.handleAxisInnerFrameChange(xLow, yLow: yLow, xHigh: xHigh, yHigh: yHigh)
        
        if let xLow = xLow {
            axis.offsetFirstScreen(-xLow.delta)
            self.initDrawers()
        }
        
        if let xHigh = xHigh {
            axis.offsetLastScreen(xHigh.delta)
            self.initDrawers()
        }
        
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
                self.offset + offset,
                axis.lastScreenInit + ((axis.firstScreenInit - axis.lastScreenInit) / 2) - (labelSize.height / 2)), settings: newSettings)
            
            return [axisLabelDrawer]
            
        } else { // definitionLabels is empty
            return []
        }
    }
    
    override func generateDirectLabelDrawers(offset offset: CGFloat) -> [ChartAxisValueLabelDrawers] {
        
        var drawers: [ChartAxisValueLabelDrawers] = []
        
        let scalars = self.valuesGenerator.generate(self.axis)
        currentAxisValues = scalars
        for scalar in scalars {
            let labels = self.labelsGenerator.generate(scalar)
            let y = self.axis.screenLocForScalar(scalar)
            if let axisLabel = labels.first { // for now y axis supports only one label x value
                let labelSize = ChartUtils.textSize(axisLabel.text, font: axisLabel.settings.font)
                let labelY = y - (labelSize.height / 2)
                let labelX = self.labelsX(offset: offset, labelWidth: labelSize.width, textAlignment: axisLabel.settings.textAlignment)
                let labelDrawer = ChartLabelDrawer(text: axisLabel.text, screenLoc: CGPointMake(labelX, labelY), settings: axisLabel.settings)

                let labelDrawers = ChartAxisValueLabelDrawers(scalar, [labelDrawer])
                drawers.append(labelDrawers)
            }
        }
        return drawers
    }
    
    func labelsX(offset offset: CGFloat, labelWidth: CGFloat, textAlignment: ChartLabelTextAlignment) -> CGFloat {
        fatalError("override")
    }
    
    private func maxLabelWidth(axisLabels: [ChartAxisLabel]) -> CGFloat {
        return axisLabels.reduce(CGFloat(0)) {maxWidth, label in
            return max(maxWidth, ChartUtils.textSize(label.text, font: label.settings.font).width)
        }
    }
    private func maxLabelWidth(axisValues: [Double]) -> CGFloat {
        return axisValues.reduce(CGFloat(0)) {maxWidth, value in
            let labels = self.labelsGenerator.generate(value)
            return max(maxWidth, maxLabelWidth(labels))
        }
    }
    
    override func zoom(x: CGFloat, y: CGFloat, centerX: CGFloat, centerY: CGFloat) {
        axis.zoom(x, y: y, centerX: centerX, centerY: centerY)
        update()
        chart?.view.setNeedsDisplay()
    }
    
    override func pan(deltaX: CGFloat, deltaY: CGFloat) {
        axis.pan(deltaX, deltaY: deltaY)
        update()
        chart?.view.setNeedsDisplay()
    }
    
    override func zoom(scaleX: CGFloat, scaleY: CGFloat, centerX: CGFloat, centerY: CGFloat) {
        axis.zoom(scaleX, scaleY: scaleY, centerX: centerX, centerY: centerY)
        update()
        chart?.view.setNeedsDisplay()
    }
}