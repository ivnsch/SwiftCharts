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
    
    override var height: CGFloat {
        return self.end.y - self.origin.y
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
            self.axis.firstScreen = self.axis.firstScreen - xLow.delta
            self.origin = CGPointMake(self.origin.x, self.origin.y - xLow.delta)
            self.end = CGPointMake(self.end.x, self.end.y)
            self.originInit = CGPointMake(self.originInit.x, self.originInit.y - xLow.delta)
            self.axis.firstVisibleScreen = self.axis.firstVisibleScreen - xLow.delta
            self.initDrawers()
        }
        
        if let xHigh = xHigh {
            self.axis.lastScreen = self.axis.lastScreen + xHigh.delta
            self.end = CGPointMake(self.end.x, self.end.y + xHigh.delta)
            self.endInit = CGPointMake(self.endInit.x, self.endInit.y + xHigh.delta)
            self.axis.lastVisibleScreen = self.axis.lastVisibleScreen + xHigh.delta
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
                self.origin.x + offset,
                self.endInit.y + ((self.originInit.y - self.endInit.y) / 2) - (labelSize.height / 2)), settings: newSettings)
            
            return [axisLabelDrawer]
            
        } else { // definitionLabels is empty
            return []
        }
    }
    
    override func generateDirectLabelDrawers(offset offset: CGFloat) -> [ChartAxisValueLabelDrawers] {
        
        var drawers: [ChartAxisValueLabelDrawers] = []
        
        let scalars = self.valuesGenerator.generate(self.axis)
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
        currentAxisValues = scalars
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
        
        // Zoom around center of gesture. Uses center as anchor point dividing the line in 2 segments which are scaled proportionally.
        let segment1 = origin.y - centerY
        let segment2 = centerY - end.y
        let deltaSegment1 = (segment1 * y) - segment1
        let deltaSegment2 = (segment2 * y) - segment2
        var newOriginY = origin.y + deltaSegment1
        var newEndY = end.y - deltaSegment2
        
        if newEndY > endInit.y {
            let delta = newEndY - endInit.y
            newEndY = endInit.y
            newOriginY = newOriginY - delta
        }
        
        if newOriginY < originInit.y {
            let delta = originInit.y - newOriginY
            newOriginY = originInit.y
            newEndY = newEndY + delta
        }
        
        if newOriginY - newEndY > originInit.y - endInit.y { // new length > original length
            origin = CGPointMake(origin.x, newOriginY)
            end = CGPointMake(end.x, newEndY)
            
            // if new origin is above origin, move it back
            let offsetOriginY = originInit.y - origin.y
            if offsetOriginY > 0 {
                origin = CGPointMake(origin.x, origin.y + offsetOriginY)
                end = CGPointMake(end.x, end.y + offsetOriginY)
            }
            
        } else { // possible correction
            origin = originInit
            end = endInit
        }
 
        axis.firstScreen = origin.y
        axis.lastScreen = end.y
        
        initDrawers()
        chart?.view.setNeedsDisplay()
    }
    
    override func pan(deltaX: CGFloat, deltaY: CGFloat) {
        
        let length = axis.screenLength
        
        let (newOriginY, newEndY): (CGFloat, CGFloat) = {
            
            if deltaY < 0 { // scrolls up
                let originY = max(originInit.y, origin.y + deltaY)
                let endY = originY - length
                return (originY, endY)
                
            } else if deltaY > 0 { // scrolls down
                let endY = min(endInit.y, end.y + deltaY)
                let originY = endY + length
                return (originY, endY)
                
            } else {
                return (origin.y, end.y)
            }
        }()
        
        origin = CGPointMake(origin.x, newOriginY)
        end = CGPointMake(end.x, newEndY)
        
        axis.firstScreen = origin.y 
        axis.lastScreen = end.y

        initDrawers()
        chart?.view.setNeedsDisplay()
    }
}