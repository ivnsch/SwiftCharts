//
//  ChartAxisModel.swift
//  SwiftCharts
//
//  Created by ischuetz on 22/04/15.
//  Copyright (c) 2015 ivanschuetz. All rights reserved.
//

import UIKit

public class ChartAxisModel {
    let axisValues: [ChartAxisValue]
    let lineColor: UIColor
    let axisTitleLabels: [ChartAxisLabel]

    public convenience init(axisValues: [ChartAxisValue], lineColor: UIColor = UIColor.blackColor(), axisTitleLabel: ChartAxisLabel) {
        self.init(axisValues: axisValues, lineColor: lineColor, axisTitleLabels: [axisTitleLabel])
    }
    
    public init(axisValues: [ChartAxisValue], lineColor: UIColor = UIColor.blackColor(), axisTitleLabels: [ChartAxisLabel] = []) {
        self.axisValues = axisValues
        self.lineColor = lineColor
        self.axisTitleLabels = axisTitleLabels
    }
}
