//
//  ChartAxisXLayerDefault.swift
//  SwiftCharts
//
//  Created by ischuetz on 25/04/15.
//  Copyright (c) 2015 ivanschuetz. All rights reserved.
//

import UIKit

/// A ChartAxisLayer for X axes
class ChartAxisXLayerDefault: ChartAxisLayerDefault {
   
    override var width: CGFloat {
        return self.end.x - self.origin.x
    }
    
    var labelsTotalHeight: CGFloat {
        return self.rowHeights.reduce(0) {sum, height in
            sum + height + self.settings.labelsSpacing
        }
    }
    
    var rowHeights: [CGFloat] {
        return self.calculateRowHeights()
    }
    
    override var height: CGFloat {
        return self.labelsTotalHeight + self.settings.axisStrokeWidth + self.settings.labelsToAxisSpacingX + self.settings.axisTitleLabelsToLabelsSpacing + self.axisTitleLabelsHeight
    }

    
    override func handleAxisInnerFrameChange(xLow: ChartAxisLayerWithFrameDelta?, yLow: ChartAxisLayerWithFrameDelta?, xHigh: ChartAxisLayerWithFrameDelta?, yHigh: ChartAxisLayerWithFrameDelta?) {
        super.handleAxisInnerFrameChange(xLow, yLow: yLow, xHigh: xHigh, yHigh: yHigh)
        
        if let (_, deltaYLow) = yLow {
            self.axis.firstScreen = self.axis.firstScreen + deltaYLow
            self.origin = CGPointMake(self.origin.x + deltaYLow, self.origin.y)
            self.end = CGPointMake(self.end.x, self.end.y)
        }
        
        if let (_, deltaYHigh) = yHigh {
            self.axis.lastScreen = self.axis.lastScreen - deltaYHigh
            self.end = CGPointMake(self.end.x - deltaYHigh, self.end.y)
        }
        
        self.initDrawers()
    }
    
    override func generateLineDrawer(offset offset: CGFloat) -> ChartLineDrawer {
        let p1 = CGPointMake(self.origin.x, self.origin.y + offset)
        let p2 = CGPointMake(self.end.x, self.end.y + offset)
        return ChartLineDrawer(p1: p1, p2: p2, color: self.settings.lineColor, strokeWidth: self.settings.axisStrokeWidth)
    }
    
    override func generateAxisTitleLabelsDrawers(offset offset: CGFloat) -> [ChartLabelDrawer] {
        return self.generateAxisTitleLabelsDrawers(self.axisTitleLabels, spacingLabelAxisX: self.settings.labelsToAxisSpacingX, spacingLabelBetweenAxis: self.settings.labelsSpacing, offset: offset)
    }
    
    
    private func generateAxisTitleLabelsDrawers(labels: [ChartAxisLabel], spacingLabelAxisX: CGFloat, spacingLabelBetweenAxis: CGFloat, offset: CGFloat) -> [ChartLabelDrawer] {
        
        let rowHeights = self.rowHeightsForRows(labels.map { [$0] })
        
        return labels.enumerate().map{(index, label) in
            
            let rowY = self.calculateRowY(rowHeights: rowHeights, rowIndex: index, spacing: spacingLabelBetweenAxis)
            
            let labelWidth = ChartUtils.textSize(label.text, font: label.settings.font).width
            let x = (self.end.x - self.origin.x) / 2 + self.origin.x - labelWidth / 2
            let y = self.origin.y + offset + rowY
            
            let drawer = ChartLabelDrawer(text: label.text, screenLoc: CGPointMake(x, y), settings: label.settings)
            drawer.hidden = label.hidden
            return drawer
        }
    }
    
    // calculate row heights (max text height) for each row
    private func calculateRowHeights() -> [CGFloat] {
  
        let axisValuesWithLabels: [(axisValue: Double, labels: [ChartAxisLabel])] = self.currentAxisValues.map {
            ($0, labelsGenerator.generate($0))
        }
        
        // organize labels in rows
        let maxRowCount = axisValuesWithLabels.reduce(-1) {maxCount, tuple in
            max(maxCount, tuple.labels.count)
        }
        let rows: [[ChartAxisLabel?]] = (0..<maxRowCount).map {row in
            axisValuesWithLabels.map {tuple in
                return row < tuple.labels.count ? tuple.labels[row] : nil
            }
        }
        
        return self.rowHeightsForRows(rows)
    }
    
    override func generateDirectLabelDrawers(offset offset: CGFloat) -> [ChartAxisValueLabelDrawers] {
        
        let spacingLabelBetweenAxis = self.settings.labelsSpacing
        
        let rowHeights = self.rowHeights
        
        // generate label drawers for each axis value and return them bundled with the respective axis value.
        
        return self.valuesGenerator.generate(self.axis).flatMap {scalar in
            
            let labels = self.labelsGenerator.generate(scalar)

            let labelDrawers: [ChartLabelDrawer] = labels.enumerate().map {index, label in
                let rowY = self.calculateRowY(rowHeights: rowHeights, rowIndex: index, spacing: spacingLabelBetweenAxis)
                
                let x = self.axis.screenLocForScalar(scalar)
                let y = self.origin.y + offset + rowY
                
                let labelSize = ChartUtils.textSize(label.text, font: label.settings.font)
                let labelX = x - (labelSize.width / 2)
                
                let labelDrawer = ChartLabelDrawer(text: label.text, screenLoc: CGPointMake(labelX, y), settings: label.settings)
                labelDrawer.hidden = label.hidden
                return labelDrawer
            }
            return ChartAxisValueLabelDrawers(scalar, labelDrawers)
        }
    }
    
    // Get the y offset of row relative to the y position of the first row
    private func calculateRowY(rowHeights rowHeights: [CGFloat], rowIndex: Int, spacing: CGFloat) -> CGFloat {
        return Array(0..<rowIndex).reduce(0) {y, index in
            y + rowHeights[index] + spacing
        }
    }
    
    
    // Get max text height for each row of axis values
    private func rowHeightsForRows(rows: [[ChartAxisLabel?]]) -> [CGFloat] {
        return rows.map { row in
            row.flatMap { $0 }.reduce(-1) { maxHeight, label in
                return max(maxHeight, label.textSize.height)
            }
        }
    }
    
    override func zoom(x: CGFloat, y: CGFloat, centerX: CGFloat, centerY: CGFloat) {

        // Zoom around center of gesture. Uses center as anchor point dividing the line in 2 segments which are scaled proportionally.
        let segment1 = centerX - origin.x
        let segment2 = end.x - centerX
        let deltaSegment1 = (segment1 * x) - segment1
        let deltaSegment2 = (segment2 * x) - segment2
        let newOriginX = origin.x - deltaSegment1
        let newEndX = end.x + deltaSegment2
        
        if newEndX - newOriginX > endInit.x - originInit.x { // new length > original length
            origin = CGPointMake(newOriginX, origin.y)
            end = CGPointMake(newEndX, end.y)

            // if p1 is to the right of origin, move it back
            let offsetOriginX = origin.x - originInit.x
            if offsetOriginX > 0 {
                origin = CGPointMake(origin.x - offsetOriginX, origin.y)
                end = CGPointMake(end.x - offsetOriginX, end.y)
            }
            
        } else { // possible correction
            origin = originInit
            end = endInit
        }
        
        axis.firstScreen = origin.x
        axis.lastScreen = end.x

        initDrawers()
        chart?.view.setNeedsDisplay()
    }
    
    
    override func pan(deltaX: CGFloat, deltaY: CGFloat) {
        
        let length = self.axis.length
        
        let (newOriginX, newEndX): (CGFloat, CGFloat) = {
            
            if deltaX < 0 { // scrolls left
                let endX = max(endInit.x, end.x + deltaX)
                let originX = endX - length
                return (originX, endX)
                
            } else if deltaX > 0 {  // scrolls right
                let originX = min(origin.x + deltaX, originInit.x)
                let endX = originX + length
                return (originX, endX)
                
            } else {
                return (origin.x, end.x)
            }
        }()
        
        origin = CGPointMake(newOriginX, origin.y)
        end = CGPointMake(newEndX, end.y)
        
        axis.firstScreen = origin.x
        axis.lastScreen = end.x
        
        initDrawers()
        chart?.view.setNeedsDisplay()
    }
}