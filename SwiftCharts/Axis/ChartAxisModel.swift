//
//  ChartAxisModel.swift
//  SwiftCharts
//
//  Created by ischuetz on 22/04/15.
//  Copyright (c) 2015 ivanschuetz. All rights reserved.
//

import UIKit

/// This class models the contents of a chart axis
open class ChartAxisModel {

    /// The values contained in the axis
    let axisValues: [ChartAxisValue]

    /// The color used to draw the axis lines
    let lineColor: UIColor

    /// The axis title lables
    let axisTitleLabels: [ChartAxisLabel]

    public convenience init(axisValues: [ChartAxisValue], lineColor: UIColor = UIColor.black, axisTitleLabel: ChartAxisLabel) {
        self.init(axisValues: axisValues, lineColor: lineColor, axisTitleLabels: [axisTitleLabel])
    }
    
    public init(axisValues: [ChartAxisValue], lineColor: UIColor = UIColor.black, axisTitleLabels: [ChartAxisLabel] = []) {
        self.axisValues = axisValues
        self.lineColor = lineColor
        self.axisTitleLabels = axisTitleLabels
    }
}
