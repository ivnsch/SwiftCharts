//
//  ChartAxisValuesGeneratorXFixedNonOverlapping.swift
//  SwiftCharts
//
//  Created by ischuetz / Iain Bryson on 19/07/16.
//  Copyright © 2016 ivanschuetz. All rights reserved.
//

import UIKit

public class ChartAxisValuesGeneratorXFixedNonOverlapping: ChartAxisValuesGeneratorFixed {

    private let labelFont: UIFont
    private let axisValues: [ChartAxisValue]
    
    public init(axisValues: [ChartAxisValue], labelFont: UIFont) {
        self.axisValues = axisValues
        self.labelFont = labelFont
        super.init(values: axisValues.map{$0.scalar})
    }
    
    public override func axisLayerInitialized(layer: ChartAxisLayer) {
        let nonOverlappingValues = ChartAxisValuesGeneratorXFixedNonOverlapping.selectNonOverlappingXAxisLabels(axisValues, screenLength: layer.frame.width, labelFont: labelFont)
        values = nonOverlappingValues.map{$0.scalar}
    }
    
    private static func selectNonOverlappingXAxisLabels(xAxisLabels: [ChartAxisValue], screenLength: CGFloat, labelFont: UIFont) -> [ChartAxisValue] {
        
        // Select only the x-axis labels which would prevent any overlap
        let spacePerXTick = screenLength / CGFloat(xAxisLabels.count)
        
        var relaxedXAxisValues: [ChartAxisValue] = []
        
        let largestXLabel = ChartAxisValuesGeneratorXFixedNonOverlapping.getLargestLabels(xAxisLabels, labelFont: labelFont)
        
        var x: CGFloat = 0, currentLabelEnd: CGFloat = 0
        xAxisLabels.forEach({(axisValue) in
            x += spacePerXTick
            if (currentLabelEnd <= x) {
                relaxedXAxisValues.append(axisValue)
                currentLabelEnd = x + largestXLabel.width + 4 // 2px border
            }
        })
        
        // Always show the last label
        if (relaxedXAxisValues.last! != xAxisLabels.last!) {
            relaxedXAxisValues[relaxedXAxisValues.count - 1] = xAxisLabels.last!
        }
        
        return relaxedXAxisValues
    }
    
    private static func getLargestLabels(values: [ChartAxisValue], labelFont: UIFont) -> CGSize {
        let maxSize = CGSize(width: CGFloat.max, height:  CGFloat.max)
        
        let maxLabelWidth = values.map({
            $0.labels[0].text.boundingRectWithSize(maxSize,
                options: NSStringDrawingOptions.UsesLineFragmentOrigin,
                attributes: [NSFontAttributeName:  labelFont],
                context: nil).size
        }).reduce(CGSizeZero, combine: { (lhs: CGSize, rhs: CGSize) -> CGSize in
            return CGSize(width: max(lhs.width, rhs.width), height: max(lhs.height, rhs.height))
        })
        
        return maxLabelWidth
    }
}