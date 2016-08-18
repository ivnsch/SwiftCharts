//
//  ChartAxisLabelsGeneratorNumber.swift
//  SwiftCharts
//
//  Created by ischuetz on 27/06/16.
//  Copyright © 2016 ivanschuetz. All rights reserved.
//

import Foundation

/// Generates a single formatted number for scalar
public class ChartAxisLabelsGeneratorNumber: ChartAxisLabelsGeneratorBase {
    
    public let labelSettings: ChartLabelSettings
    
    public let formatter: NSNumberFormatter
    
    public init(labelSettings: ChartLabelSettings, formatter: NSNumberFormatter = ChartAxisLabelsGeneratorNumber.defaultFormatter) {
        self.labelSettings = labelSettings
        self.formatter = formatter
    }
    
    public override func generate(scalar: Double) -> [ChartAxisLabel] {
        let text = formatter.stringFromNumber(scalar)!
        return [ChartAxisLabel(text: text, settings: labelSettings)]
    }
    
    static var defaultFormatter: NSNumberFormatter = {
        let formatter = NSNumberFormatter()
        formatter.maximumFractionDigits = 2
        return formatter
    }()
    
    public override func fonts(scalar: Double) -> [UIFont] {
        return [labelSettings.font]
    }
}
