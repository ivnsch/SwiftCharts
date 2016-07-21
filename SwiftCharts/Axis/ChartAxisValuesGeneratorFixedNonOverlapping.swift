//
//  ChartAxisValuesGeneratorFixedNonOverlapping.swift
//  SwiftCharts
//
//  Created by ischuetz / Iain Bryson on 19/07/16.
//  Copyright © 2016 ivanschuetz. All rights reserved.
//

import UIKit

public class ChartAxisValuesGeneratorFixedNonOverlapping: ChartAxisValuesGeneratorFixed {
    
    public let axisValues: [ChartAxisValue]
    
    public let maxLabelSize: CGSize
    public let totalLabelSize: CGSize
    public let spacing: CGFloat
    
    private var isX: Bool
    
    init(axisValues: [ChartAxisValue], spacing: CGFloat, isX: Bool) {
        self.axisValues = axisValues
        self.spacing = spacing
        self.isX = isX
        
        (totalLabelSize, maxLabelSize) = ChartAxisValuesGeneratorFixedNonOverlapping.calculateLabelsDimensions(axisValues)
        
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
        values = selectNonOverlappingAxisLabels(axisValues, screenLength: axis.screenLength).map{$0.scalar}
    }
    
    private func selectNonOverlappingAxisLabels(axisValues: [ChartAxisValue], screenLength: CGFloat) -> [ChartAxisValue] {
        
        // Select only the x-axis labels which would prevent any overlap
        let spacePerTick = screenLength / CGFloat(axisValues.count)
        
        var filteredAxisValues: [ChartAxisValue] = []
        
        var coord: CGFloat = 0, currentLabelEnd: CGFloat = 0
        axisValues.forEach({axisValue in
            coord += spacePerTick
            if (currentLabelEnd <= coord) {
                filteredAxisValues.append(axisValue)
                currentLabelEnd = coord + (isX ? maxLabelSize.width : maxLabelSize.height) + spacing
            }
        })
        
        // Always show the last label
        if let filteredLast = filteredAxisValues.last, axisLabelLast = axisValues.last where filteredLast != axisLabelLast {
            filteredAxisValues[filteredAxisValues.count - 1] = axisLabelLast
        }
        
        return filteredAxisValues
    }
    
    private static func calculateLabelsDimensions(values: [ChartAxisValue]) -> (total: CGSize, max: CGSize) {
        return values.flatMap({
            guard let label = $0.labels.first else {return nil}
            return ChartUtils.textSize(label.text, font: label.settings.font)
        }).reduce((total: CGSizeZero, max: CGSizeZero), combine: {(lhs: (total: CGSize, max: CGSize), rhs: CGSize) in
            return (
                CGSize(width: lhs.total.width + rhs.width, height: lhs.total.height + rhs.height),
                CGSize(width: max(lhs.max.width, rhs.width), height: max(lhs.max.height, rhs.height))
            )
        })
    }
}