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

    private var minTotalCalculatedRowHeights: CGFloat?
    private var maxTotalCalculatedRowHeights: CGFloat?
    
    override var origin: CGPoint {
        return CGPointMake(axis.firstScreen, offset)
    }
    
    override var end: CGPoint {
        return CGPointMake(axis.lastScreen, offset)
    }
    
    override var width: CGFloat {
        return axis.screenLength
    }
    
    override var visibleFrame: CGRect {
        return CGRectMake(axis.firstVisibleScreen, offset, axis.visibleScreenLength, height)
    }
    
    var labelsTotalHeight: CGFloat {
        
        let currentTotalHeight = rowHeights.reduce(0) {sum, height in
            sum + height + settings.labelsSpacing
        }

        let height: CGFloat = {
            switch labelSpaceReservationMode {
            case .MinPresentedSize: return minTotalCalculatedRowHeights.maxOpt(currentTotalHeight)
            case .MaxPresentedSize: return maxTotalCalculatedRowHeights.maxOpt(currentTotalHeight)
            case .Fixed(let value): return value
            case .Current: return currentTotalHeight
            }
        }()
        
        if !rowHeights.isEmpty {
            let (min, max): (CGFloat, CGFloat) = (minTotalCalculatedRowHeights.minOpt(currentTotalHeight), maxTotalCalculatedRowHeights.maxOpt(currentTotalHeight))
            minTotalCalculatedRowHeights = min
            maxTotalCalculatedRowHeights = max
        }

        return height
    }
    
    var rowHeights: [CGFloat] {
        return self.calculateRowHeights()
    }
    
    override var height: CGFloat {
        return self.labelsTotalHeight + self.settings.axisStrokeWidth + self.settings.labelsToAxisSpacingX + self.settings.axisTitleLabelsToLabelsSpacing + self.axisTitleLabelsHeight
    }
    
    override var widthWithoutLabels: CGFloat {
        return width
    }
    
    override var heightWithoutLabels: CGFloat {
        return self.settings.axisStrokeWidth + self.settings.labelsToAxisSpacingX + self.settings.axisTitleLabelsToLabelsSpacing + self.axisTitleLabelsHeight
    }
    
    override func handleAxisInnerFrameChange(xLow: ChartAxisLayerWithFrameDelta?, yLow: ChartAxisLayerWithFrameDelta?, xHigh: ChartAxisLayerWithFrameDelta?, yHigh: ChartAxisLayerWithFrameDelta?) {
        super.handleAxisInnerFrameChange(xLow, yLow: yLow, xHigh: xHigh, yHigh: yHigh)
        
        if let yLow = yLow {
            axis.offsetFirstScreen(yLow.delta)
            self.initDrawers()
        }
        
        if let yHigh = yHigh {
            axis.offsetLastScreen(-yHigh.delta)
            self.initDrawers()
        }
    }
    
    override func generateLineDrawer(offset offset: CGFloat) -> ChartLineDrawer {
        let p1 = CGPointMake(self.axis.firstVisibleScreen, self.offset + offset)
        let p2 = CGPointMake(self.axis.lastVisibleScreen, self.offset + offset)
        return ChartLineDrawer(p1: p1, p2: p2, color: self.settings.lineColor, strokeWidth: self.settings.axisStrokeWidth)
    }
    
    override func generateAxisTitleLabelsDrawers(offset offset: CGFloat) -> [ChartLabelDrawer] {
        return self.generateAxisTitleLabelsDrawers(self.axisTitleLabels, spacingLabelAxisX: self.settings.labelsToAxisSpacingX, spacingLabelBetweenAxis: self.settings.labelsSpacing, offset: offset)
    }
    
    
    private func generateAxisTitleLabelsDrawers(labels: [ChartAxisLabel], spacingLabelAxisX: CGFloat, spacingLabelBetweenAxis: CGFloat, offset: CGFloat) -> [ChartLabelDrawer] {
        
        let rowHeights = self.rowHeightsForRows(labels.map { [$0] })
        
        return labels.enumerate().map{(index, label) in
            
            let rowY = self.calculateRowY(rowHeights: rowHeights, rowIndex: index, spacing: spacingLabelBetweenAxis)
            
            let labelWidth = label.text.width(label.settings.font)
            let x = (axis.lastScreenInit - axis.firstScreenInit) / 2 + axis.firstScreenInit - labelWidth / 2
            let y = self.offset + offset + rowY
            
            let drawer = ChartLabelDrawer(text: label.text, screenLoc: CGPointMake(x, y), settings: label.settings)
            drawer.hidden = label.hidden
            return drawer
        }
    }
    
    // calculate row heights (max text height) for each row
    private func calculateRowHeights() -> [CGFloat] {
  
        guard !currentAxisValues.isEmpty else {return []}

        let axisValuesWithLabels: [(axisValue: Double, labels: [ChartAxisLabel])] = self.currentAxisValues.map {
            ($0, labelsGenerator.generateInBounds($0, axis: axis))
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
        
        let scalars = self.valuesGenerator.generate(self.axis)
        
        currentAxisValues = scalars
        return scalars.flatMap {scalar in
            
            let labels = self.labelsGenerator.generateInBounds(scalar, axis: axis)

            let labelDrawers: [ChartLabelDrawer] = labels.enumerate().map {index, label in
                let rowY = self.calculateRowY(rowHeights: rowHeights, rowIndex: index, spacing: spacingLabelBetweenAxis)
                
                let x = self.axis.screenLocForScalar(scalar)
                let y = self.offset + offset + rowY
                
                let labelSize = label.text.size(label.settings.font)
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
        axis.zoom(x, y: y, centerX: centerX, centerY: centerY)
        initDrawers()
        chart?.view.setNeedsDisplay()
    }
    
    override func pan(deltaX: CGFloat, deltaY: CGFloat) {
        axis.pan(deltaX, deltaY: deltaY)
        initDrawers()
        chart?.view.setNeedsDisplay()
    }
    
    override func zoom(scaleX: CGFloat, scaleY: CGFloat, centerX: CGFloat, centerY: CGFloat) {
        axis.zoom(scaleX, scaleY: scaleY, centerX: centerX, centerY: centerX)
        initDrawers()
        chart?.view.setNeedsDisplay()
    }
}