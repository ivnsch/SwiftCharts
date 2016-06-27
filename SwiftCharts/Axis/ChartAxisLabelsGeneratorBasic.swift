//
//  ChartAxisLabelsGeneratorBasic.swift
//  SwiftCharts
//
//  Created by ischuetz on 27/06/16.
//  Copyright © 2016 ivanschuetz. All rights reserved.
//

import Foundation

/// Generates a single unformatted label for scalar
public class ChartAxisLabelsGeneratorBasic: ChartAxisLabelsGenerator {

    let labelSettings: ChartLabelSettings
    
    public init(labelSettings: ChartLabelSettings) {
        self.labelSettings = labelSettings
    }
    
    public func generate(scalar: Double) -> [ChartAxisLabel] {
        return [ChartAxisLabel(text: "\(scalar)", settings: labelSettings)]
    }
}
