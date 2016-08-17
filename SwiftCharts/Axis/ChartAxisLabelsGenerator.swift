//
//  ChartAxisLabelsGenerator.swift
//  SwiftCharts
//
//  Created by ischuetz on 27/06/16.
//  Copyright © 2016 ivanschuetz. All rights reserved.
//

import Foundation

/// Generates labels for an axis value. Note: Supports only one label per axis value (1 element array)
public protocol ChartAxisLabelsGenerator {

    /// If the complete label should disappear as soon as a part of it is outside of the axis edges
    var onlyShowCompleteLabels: Bool {get}
    
    /// Generates label for scalar without boundary checks
    func generate(scalar: Double, axis: ChartAxis) -> [ChartAxisLabel]
    
    /// Generates label for scalar with possible boundary checks
    func generateInBounds(scalar: Double, axis: ChartAxis) -> [ChartAxisLabel]
}

extension ChartAxisLabelsGenerator {
    
    public var onlyShowCompleteLabels: Bool {
        return true
    }

    public func generateInBounds(scalar: Double, axis: ChartAxis) -> [ChartAxisLabel] {
        let labels = generate(scalar, axis: axis)
        if onlyShowCompleteLabels {
            return labels.first.map {label in
                if axis.isInBoundaries(axis.screenLocForScalar(scalar), screenSize: label.textSize) {
                    return [label]
                } else {
                    return []
                }
            } ?? []
        } else {
            return labels
        }
    }
}