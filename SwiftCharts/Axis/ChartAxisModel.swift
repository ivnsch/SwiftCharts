//
//  ChartAxisModel.swift
//  SwiftCharts
//
//  Created by ischuetz on 22/04/15.
//  Copyright (c) 2015 ivanschuetz. All rights reserved.
//

import UIKit

/// This class models the contents of a chart axis
public class ChartAxisModel {
    
    let firstModelValue: Double
    let lastModelValue: Double
    
    let axisValuesGenerator: ChartAxisValuesGenerator
    let labelsGenerator: ChartAxisLabelsGenerator
    
    /// The color used to draw the axis lines
    let lineColor: UIColor

    /// The axis title lables
    let axisTitleLabels: [ChartAxisLabel]

    let labelsConflictSolver: ChartAxisLabelsConflictSolver?
    
    let addPaddingForFirstLabelSize: Bool
    let addPaddingForLastLabelSize: Bool
    
    public convenience init(axisValues: [ChartAxisValue], lineColor: UIColor = UIColor.blackColor(), axisTitleLabel: ChartAxisLabel, labelsConflictSolver: ChartAxisLabelsConflictSolver? = nil, addPaddingForFirstLabelSize: Bool = false, addPaddingForLastLabelSize: Bool = false) {
        self.init(axisValues: axisValues, lineColor: lineColor, axisTitleLabels: [axisTitleLabel], labelsConflictSolver: labelsConflictSolver, addPaddingForFirstLabelSize: addPaddingForFirstLabelSize, addPaddingForLastLabelSize: addPaddingForLastLabelSize)
    }

    /// Convenience initializer to pass a fixed axis value array. The array is mapped to axis values and label generators. 
    public convenience init(axisValues: [ChartAxisValue], lineColor: UIColor = UIColor.blackColor(), axisTitleLabels: [ChartAxisLabel] = [], labelsConflictSolver: ChartAxisLabelsConflictSolver? = nil, addPaddingForFirstLabelSize: Bool = false, addPaddingForLastLabelSize: Bool = false) {
        var scalars: [Double] = []
        var dict = [Double: [ChartAxisLabel]]()
        for axisValue in axisValues {
            if !axisValue.hidden {
                scalars.append(axisValue.scalar)
                dict[axisValue.scalar] = axisValue.labels
            }

        }
        let (firstModelValue, lastModelValue) = axisValues.isEmpty ? (0, 0) : (axisValues.first!.scalar, axisValues.last!.scalar)
        
        let fixedArrayGenerator = ChartAxisValuesGeneratorFixed(values: scalars)
        let fixedLabelGenerator = ChartAxisLabelsGeneratorFixed(dict: dict)
        
        self.init(lineColor: lineColor, firstModelValue: firstModelValue, lastModelValue: lastModelValue, axisTitleLabels: axisTitleLabels, axisValuesGenerator: fixedArrayGenerator, labelsGenerator: fixedLabelGenerator, labelsConflictSolver: labelsConflictSolver, addPaddingForFirstLabelSize: addPaddingForFirstLabelSize, addPaddingForLastLabelSize: addPaddingForLastLabelSize)
    }
    
    public convenience init(lineColor: UIColor = UIColor.blackColor(), firstModelValue: Double, lastModelValue: Double, axisTitleLabel: ChartAxisLabel, axisValuesGenerator: ChartAxisValuesGenerator, labelsGenerator: ChartAxisLabelsGenerator, labelsConflictSolver: ChartAxisLabelsConflictSolver? = nil, addPaddingForFirstLabelSize: Bool = false, addPaddingForLastLabelSize: Bool = false) {
        self.init(lineColor: lineColor, firstModelValue: firstModelValue, lastModelValue: lastModelValue, axisTitleLabels: [axisTitleLabel], axisValuesGenerator: axisValuesGenerator, labelsGenerator: labelsGenerator, labelsConflictSolver: labelsConflictSolver, addPaddingForFirstLabelSize: addPaddingForFirstLabelSize, addPaddingForLastLabelSize: addPaddingForLastLabelSize)
    }

    public init(lineColor: UIColor = UIColor.blackColor(), firstModelValue: Double, lastModelValue: Double, axisTitleLabels: [ChartAxisLabel] = [], axisValuesGenerator: ChartAxisValuesGenerator, labelsGenerator: ChartAxisLabelsGenerator, labelsConflictSolver: ChartAxisLabelsConflictSolver? = nil, addPaddingForFirstLabelSize: Bool = false, addPaddingForLastLabelSize: Bool = false) {
        
        self.lineColor = lineColor
        self.firstModelValue = firstModelValue
        self.lastModelValue = lastModelValue
        self.axisTitleLabels = axisTitleLabels
        self.axisValuesGenerator = axisValuesGenerator
        self.labelsGenerator = labelsGenerator
        self.labelsConflictSolver = labelsConflictSolver
        self.addPaddingForFirstLabelSize = addPaddingForFirstLabelSize
        self.addPaddingForLastLabelSize = addPaddingForLastLabelSize
    }
}
