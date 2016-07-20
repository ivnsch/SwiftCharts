//
//  ChartAxisValuesGeneratorXFixedNonOverlapping.swift
//  SwiftCharts
//
//  Created by ischuetz / Iain Bryson on 19/07/16.
//  Copyright © 2016 ivanschuetz. All rights reserved.
//

import UIKit

public class ChartAxisValuesGeneratorXFixedNonOverlapping: ChartAxisValuesGeneratorFixed {

    public let labelFont: UIFont
    public let axisValues: [ChartAxisValue]
    
    public let maxLabelSize: CGSize
    public let totalLabelSize: CGSize
    public let spacing: CGFloat = 4
    
    public init(axisValues: [ChartAxisValue], labelFont: UIFont) {
        self.axisValues = axisValues
        self.labelFont = labelFont
        
        (totalLabelSize, maxLabelSize) = ChartAxisValuesGeneratorXFixedNonOverlapping.calculateLabelsDimensions(axisValues, labelFont: labelFont)
        
        super.init(values: axisValues.map{$0.scalar})
    }
    
    public override func axisLayerInitialized(layer: ChartAxisLayer) {
        updateAxisValues(layer.axis)
    }
    
    public override func generate(axis: ChartAxis) -> [Double] {
        updateAxisValues(axis)
        return super.generate(axis)
    }
    
    private func updateAxisValues(axis: ChartAxis) {
        values = selectNonOverlappingXAxisLabels(axisValues, screenLength: axis.screenLength, labelFont: labelFont).map{$0.scalar}
    }
    
    private func selectNonOverlappingXAxisLabels(xAxisLabels: [ChartAxisValue], screenLength: CGFloat, labelFont: UIFont) -> [ChartAxisValue] {
        
        // Select only the x-axis labels which would prevent any overlap
        let spacePerXTick = screenLength / CGFloat(xAxisLabels.count)
        
        var relaxedXAxisValues: [ChartAxisValue] = []
        
        var x: CGFloat = 0, currentLabelEnd: CGFloat = 0
        xAxisLabels.forEach({axisValue in
            x += spacePerXTick
            if (currentLabelEnd <= x) {
                relaxedXAxisValues.append(axisValue)
                currentLabelEnd = x + maxLabelSize.width + spacing
            }
        })
        
        if let relatedLast = relaxedXAxisValues.last, axisLabelLast = relaxedXAxisValues.last {
            // Always show the last label
            if (relatedLast != axisLabelLast) {
                relaxedXAxisValues[relaxedXAxisValues.count - 1] = xAxisLabels.last!
            }
        }
        
        return relaxedXAxisValues
    }
    
    private static func calculateLabelsDimensions(values: [ChartAxisValue], labelFont: UIFont) -> (total: CGSize, max: CGSize) {
        return values.map({
            ChartUtils.textSize($0.labels[0].text, font: labelFont)
        }).reduce((total: CGSizeZero, max: CGSizeZero), combine: {(lhs: (total: CGSize, max: CGSize), rhs: CGSize) in
            return (
                CGSize(width: lhs.total.width + rhs.width, height: lhs.total.height + rhs.height),
                CGSize(width: max(lhs.max.width, rhs.width), height: max(lhs.max.height, rhs.height))
            )
        })
    }
}