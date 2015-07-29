//
//  ChartAxisXLayerDefault.swift
//  SwiftCharts
//
//  Created by ischuetz on 25/04/15.
//  Copyright (c) 2015 ivanschuetz. All rights reserved.
//

import UIKit

class ChartAxisXLayerDefault: ChartAxisLayerDefault {
   
    override var width: CGFloat {
        return self.p2.x - self.p1.x
    }
    
    lazy var labelsTotalHeight: CGFloat = {
        return self.rowHeights.reduce(0) {sum, height in
            sum + height + self.settings.labelsSpacing
        }
    }()
    
    lazy var rowHeights: [CGFloat] = {
        return self.calculateRowHeights()
    }()
    
    override var height: CGFloat {
        return self.labelsTotalHeight + self.settings.axisStrokeWidth + self.settings.labelsToAxisSpacingX + self.settings.axisTitleLabelsToLabelsSpacing + self.axisTitleLabelsHeight
    }
    
    override var length: CGFloat {
        return p2.x - p1.x
    }
    
    override func chartViewDrawing(context context: CGContextRef, chart: Chart) {
        super.chartViewDrawing(context: context, chart: chart)
    }
    
    override func generateLineDrawer(offset offset: CGFloat) -> ChartLineDrawer {
        let p1 = CGPointMake(self.p1.x, self.p1.y + offset)
        let p2 = CGPointMake(self.p2.x, self.p2.y + offset)
        return ChartLineDrawer(p1: p1, p2: p2, color: self.settings.lineColor)
    }
    
    override func generateAxisTitleLabelsDrawers(offset offset: CGFloat) -> [ChartLabelDrawer] {
        return self.generateAxisTitleLabelsDrawers(self.axisTitleLabels, spacingLabelAxisX: self.settings.labelsToAxisSpacingX, spacingLabelBetweenAxis: self.settings.labelsSpacing, offset: offset)
    }
    
    
    private func generateAxisTitleLabelsDrawers(labels: [ChartAxisLabel], spacingLabelAxisX: CGFloat, spacingLabelBetweenAxis: CGFloat, offset: CGFloat) -> [ChartLabelDrawer] {
        
        let rowHeights = self.rowHeightsForRows(rows: labels.map{[$0]})
        
        return labels.enumerate().map{(index, label) in
            
            let rowY = self.calculateRowY(rowHeights: rowHeights, rowIndex: index, spacing: spacingLabelBetweenAxis)
            
            let labelWidth = ChartUtils.textSize(label.text, font: label.settings.font).width
            let x = (self.p2.x - self.p1.x) / 2 + self.p1.x - labelWidth / 2
            let y = self.p1.y + offset + rowY
            
            let drawer = ChartLabelDrawer(text: label.text, screenLoc: CGPointMake(x, y), settings: label.settings)
            drawer.hidden = label.hidden
            return drawer
        }
    }
    
    
    override func screenLocForScalar(scalar: Double, firstAxisScalar: Double) -> CGFloat {
        return self.p1.x + self.innerScreenLocForScalar(scalar, firstAxisScalar: firstAxisScalar)
    }
    
    // calculate row heights (max text height) for each row
    private func calculateRowHeights() -> [CGFloat] {
        
        // organize labels in rows
        let maxRowCount = self.axisValues.reduce(-1) {maxCount, axisValue in
            max(maxCount, axisValue.labels.count)
        }
        let rows:[[ChartAxisLabel?]] = (0..<maxRowCount).map {row in
            self.axisValues.map {axisValue in
                let labels = axisValue.labels
                return row < labels.count ? labels[row] : nil
            }
        }
        
        return self.rowHeightsForRows(rows: rows)
    }
    
    override func generateLabelDrawers(offset offset: CGFloat) -> [ChartLabelDrawer] {
        
        let spacingLabelBetweenAxis = self.settings.labelsSpacing
        
        let rowHeights = self.rowHeights
        
        // generate all the label drawers, in a flat list
        return self.axisValues.flatMap {axisValue in
            return Array(axisValue.labels.enumerate()).map {index, label in
                let rowY = self.calculateRowY(rowHeights: rowHeights, rowIndex: index, spacing: spacingLabelBetweenAxis)
                
                let x = self.screenLocForScalar(axisValue.scalar)
                let y = self.p1.y + offset + rowY
                
                let labelSize = ChartUtils.textSize(label.text, font: label.settings.font)
                let labelX = x - (labelSize.width / 2)
                
                let labelDrawer = ChartLabelDrawer(text: label.text, screenLoc: CGPointMake(labelX, y), settings: label.settings)
                labelDrawer.hidden = label.hidden
                return labelDrawer
            }
        }
    }
    
    // Get the y offset of row relative to the y position of the first row
    private func calculateRowY(rowHeights rowHeights: [CGFloat], rowIndex: Int, spacing: CGFloat) -> CGFloat {
        return Array(0..<rowIndex).reduce(0) {y, index in
            y + rowHeights[index] + spacing
        }
    }
    
    
    // Get max text height for each row of axis values
    private func rowHeightsForRows(rows rows: [[ChartAxisLabel?]]) -> [CGFloat] {
        return rows.map {row in
            row.reduce(-1) {maxHeight, labelMaybe in
                return max(maxHeight, self.labelMaybeSize(labelMaybe).height)
            }
        }
    }
}
